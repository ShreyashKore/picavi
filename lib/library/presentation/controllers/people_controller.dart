import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../../data/services/face_grouping.dart';
import '../../data/services/face_scanner.dart';
import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/face.dart';
import '../../domain/entities/library_query.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/photo_info_repository.dart';
import '../../domain/services/face_detector.dart';

class PeopleState {
  const PeopleState({
    this.isAvailable = true,
    this.isLoading = true,
    this.scan,
    this.people = const <PersonSummary>[],
    this.groups = const <List<CatalogFace>>[],
    this.person,
    this.personImages = const <CatalogImage>[],
    this.personFaces = const <CatalogFace>[],
    this.suggestions = const <CatalogFace>[],
    this.selectedFaces = const <int>{},
    this.saveFailed = false,
  });

  /// Face detection works on this platform.
  final bool isAvailable;
  final bool isLoading;

  /// Non-null while photos are being scanned for faces.
  final IndexProgress? scan;
  final List<PersonSummary> people;

  /// Unnamed faces grouped by likeness, biggest group first.
  final List<List<CatalogFace>> groups;

  /// The person being looked at, if any.
  final String? person;
  final List<CatalogImage> personImages;
  final List<CatalogFace> personFaces;

  /// Unnamed faces that might be [person].
  final List<CatalogFace> suggestions;

  /// Faces picked in the unnamed groups.
  final Set<int> selectedFaces;

  /// The last change couldn't be saved next to a photo.
  final bool saveFailed;

  bool get isScanning => scan != null && !scan!.done;

  int get unnamedCount =>
      groups.fold<int>(0, (count, group) => count + group.length);

  PeopleState copyWith({
    bool? isAvailable,
    bool? isLoading,
    IndexProgress? Function()? scan,
    List<PersonSummary>? people,
    List<List<CatalogFace>>? groups,
    String? Function()? person,
    List<CatalogImage>? personImages,
    List<CatalogFace>? personFaces,
    List<CatalogFace>? suggestions,
    Set<int>? selectedFaces,
    bool? saveFailed,
  }) {
    return PeopleState(
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
      scan: scan != null ? scan() : this.scan,
      people: people ?? this.people,
      groups: groups ?? this.groups,
      person: person != null ? person() : this.person,
      personImages: personImages ?? this.personImages,
      personFaces: personFaces ?? this.personFaces,
      suggestions: suggestions ?? this.suggestions,
      selectedFaces: selectedFaces ?? this.selectedFaces,
      saveFailed: saveFailed ?? this.saveFailed,
    );
  }
}

/// Finds faces, groups the unnamed ones, and names people. Names are saved
/// next to each photo (its sidecar) and mirrored into the catalog.
class PeopleController extends ChangeNotifier {
  PeopleController({
    required CatalogRepository catalog,
    required FaceDetectorService detector,
    required PhotoInfoRepository photoInfo,
  }) : _catalog = catalog,
       _detector = detector,
       _photoInfo = photoInfo,
       _state = PeopleState(isAvailable: detector.isAvailable);

  final CatalogRepository _catalog;
  final FaceDetectorService _detector;
  final PhotoInfoRepository _photoInfo;
  PeopleState _state;
  StreamSubscription<IndexProgress>? _scanning;
  final Set<(String, int)> _rejected = {};
  bool _isDisposed = false;

  PeopleState get state => _state;

  /// Shows what is known, then looks for faces in new photos.
  Future<void> open() async {
    await reload();
    _setState(_state.copyWith(isLoading: false));
    if (_state.isAvailable) {
      scan();
    }
  }

  /// Scans photos that are new or changed since their last scan.
  void scan() {
    if (!_state.isAvailable || _state.isScanning) {
      return;
    }
    var lastReload = DateTime.now();
    _scanning = FaceScanner(_catalog, _detector).scan().listen(
      (progress) {
        _setState(_state.copyWith(scan: () => progress));
        final now = DateTime.now();
        if (progress.done ||
            now.difference(lastReload) > const Duration(seconds: 3)) {
          lastReload = now;
          unawaited(reload());
        }
      },
      onError: (Object error) {
        debugPrint('Face scan failed: $error');
        _setState(_state.copyWith(scan: () => null));
      },
      onDone: () => _setState(_state.copyWith(scan: () => null)),
    );
  }

  Future<void> reload() async {
    final people = await _catalog.people();
    final unnamed = await _catalog.faces(unnamedOnly: true, withPrints: true);
    // Comparing fingerprints is heavy for big libraries: keep it off the
    // UI thread.
    final groups = await Isolate.run(() => groupFaces(unnamed));
    final present = {for (final face in unnamed) face.id};
    _setState(
      _state.copyWith(
        people: people,
        groups: groups,
        selectedFaces: _state.selectedFaces.intersection(present),
      ),
    );
    final person = _state.person;
    if (person != null) {
      await _loadPerson(person, unnamed);
    }
  }

  // -------------------------------------------------------------------------
  // Unnamed faces

  void toggleFace(int id) {
    final next = {..._state.selectedFaces};
    next.contains(id) ? next.remove(id) : next.add(id);
    _setState(_state.copyWith(selectedFaces: next));
  }

  void clearSelection() =>
      _setState(_state.copyWith(selectedFaces: const <int>{}));

  /// The faces of [group] an action applies to: the picked ones, or all.
  List<CatalogFace> targetsIn(List<CatalogFace> group) {
    final picked = [
      for (final face in group)
        if (_state.selectedFaces.contains(face.id)) face,
    ];
    return picked.isEmpty ? group : picked;
  }

  Future<void> nameFaces(List<CatalogFace> faces, String name) async {
    final trimmed = name.trim();
    if (faces.isEmpty || trimmed.isEmpty) {
      return;
    }
    await _catalog.nameFaces([for (final face in faces) face.id], trimmed);
    await _saveNames({for (final face in faces) face.path});
    _setState(_state.copyWith(selectedFaces: const <int>{}));
    await reload();
  }

  /// Hides faces that aren't worth naming (strangers, statues, posters).
  Future<void> ignoreFaces(List<CatalogFace> faces) async {
    if (faces.isEmpty) {
      return;
    }
    await _catalog.setFacesIgnored([for (final face in faces) face.id], true);
    await _saveNames({for (final face in faces) face.path});
    _setState(_state.copyWith(selectedFaces: const <int>{}));
    await reload();
  }

  // -------------------------------------------------------------------------
  // One person

  Future<void> openPerson(String? name) async {
    _setState(
      _state.copyWith(
        person: () => name,
        personImages: const [],
        personFaces: const [],
        suggestions: const [],
      ),
    );
    if (name != null) {
      await _loadPerson(
        name,
        await _catalog.faces(unnamedOnly: true, withPrints: true),
      );
    }
  }

  Future<void> _loadPerson(String name, List<CatalogFace> unnamed) async {
    final faces = await _catalog.faces(name: name, withPrints: true);
    final images = await _catalog.search(
      LibraryQuery(person: name, includeHidden: true),
    );
    final suggestions = suggestFaces(
      faces,
      unnamed,
    ).where((face) => !_rejected.contains((name, face.id))).toList();
    if (_state.person != name) {
      return;
    }
    _setState(
      _state.copyWith(
        personFaces: faces,
        personImages: images,
        suggestions: suggestions,
      ),
    );
  }

  Future<void> acceptSuggestion(CatalogFace face) async {
    final person = _state.person;
    if (person != null) {
      await nameFaces([face], person);
    }
  }

  /// "Not them": stops suggesting [face] for this person (this session).
  void rejectSuggestion(CatalogFace face) {
    final person = _state.person;
    if (person == null) {
      return;
    }
    _rejected.add((person, face.id));
    _setState(
      _state.copyWith(
        suggestions: [
          for (final other in _state.suggestions)
            if (other.id != face.id) other,
        ],
      ),
    );
  }

  /// Renames a person; naming them as someone who exists merges the two.
  Future<void> renamePerson(String from, String to) async {
    final faces = await _catalog.faces(name: from);
    await nameFaces(faces, to);
    if (_state.person == from) {
      await openPerson(to.trim());
    }
  }

  /// Forgets a person's name; their faces go back to the unnamed groups.
  Future<void> removePerson(String name) async {
    final faces = await _catalog.faces(name: name);
    await _catalog.nameFaces([for (final face in faces) face.id], null);
    await _saveNames({for (final face in faces) face.path});
    await openPerson(null);
    await reload();
  }

  // -------------------------------------------------------------------------

  /// Writes each photo's named faces to its sidecar and the catalog.
  Future<void> _saveNames(Set<String> paths) async {
    var failed = false;
    for (final path in paths) {
      final tags = [
        for (final face in await _catalog.faces(path: path))
          if (face.name != null) PersonTag(face.name!, face.box),
      ];
      final info = (await _photoInfo.load(path)).copyWith(people: tags);
      if (await _photoInfo.save(path, info)) {
        await _catalog.updateInfo(path, info);
      } else {
        failed = true;
      }
    }
    _setState(_state.copyWith(saveFailed: failed));
  }

  void _setState(PeopleState state) {
    if (_isDisposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_scanning?.cancel());
    super.dispose();
  }
}
