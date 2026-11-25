import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/import_models.dart';
import '../../domain/repositories/library_settings_repository.dart';
import '../../domain/services/import_service.dart';

class ImportState {
  const ImportState({
    this.sources = const <ImportSource>[],
    this.sourcePath,
    this.isScanning = false,
    this.candidates = const <ImportCandidate>[],
    this.selection = const <String>{},
    this.destination = '',
    this.progress,
  });

  /// Cameras and cards found on this computer.
  final List<ImportSource> sources;

  /// The device or folder being imported from.
  final String? sourcePath;
  final bool isScanning;
  final List<ImportCandidate> candidates;
  final Set<String> selection;
  final String destination;

  /// Non-null once importing has started.
  final ImportProgress? progress;

  bool get isImporting => progress != null && !progress!.done;
  bool get isDone => progress?.done ?? false;

  List<ImportCandidate> get selected => [
    for (final candidate in candidates)
      if (selection.contains(candidate.path)) candidate,
  ];

  ImportState copyWith({
    List<ImportSource>? sources,
    String? sourcePath,
    bool? isScanning,
    List<ImportCandidate>? candidates,
    Set<String>? selection,
    String? destination,
    ImportProgress? Function()? progress,
  }) {
    return ImportState(
      sources: sources ?? this.sources,
      sourcePath: sourcePath ?? this.sourcePath,
      isScanning: isScanning ?? this.isScanning,
      candidates: candidates ?? this.candidates,
      selection: selection ?? this.selection,
      destination: destination ?? this.destination,
      progress: progress != null ? progress() : this.progress,
    );
  }
}

/// Picks a source, chooses photos (new ones are pre-selected) and copies
/// them into dated folders.
class ImportController extends ChangeNotifier {
  ImportController({
    required ImportService service,
    required LibrarySettingsRepository settings,
    required String defaultDestination,
  }) : _service = service,
       _settings = settings,
       _state = ImportState(destination: defaultDestination);

  final ImportService _service;
  final LibrarySettingsRepository _settings;
  ImportState _state;
  int _scanGeneration = 0;
  bool _isDisposed = false;

  ImportState get state => _state;

  Future<void> open() async {
    final destination = await _settings.importDestination();
    if (destination != null && destination.isNotEmpty) {
      _setState(_state.copyWith(destination: destination));
    }
    await refreshSources();
    if (_state.sources.length == 1) {
      await chooseSource(_state.sources.single.path);
    }
  }

  Future<void> refreshSources() async {
    _setState(_state.copyWith(sources: await _service.findSources()));
  }

  Future<void> chooseSource(String path) async {
    if (_state.isImporting) {
      return;
    }
    final generation = ++_scanGeneration;
    _setState(
      _state.copyWith(
        sourcePath: path,
        isScanning: true,
        candidates: const [],
        selection: const {},
        progress: () => null,
      ),
    );
    final candidates = await _service.scan(path, _state.destination);
    if (_isDisposed || generation != _scanGeneration) {
      return;
    }
    _setState(
      _state.copyWith(
        isScanning: false,
        candidates: candidates,
        selection: {
          for (final candidate in candidates)
            if (!candidate.alreadyImported) candidate.path,
        },
      ),
    );
  }

  Future<void> setDestination(String folder) async {
    await _settings.setImportDestination(folder);
    _setState(_state.copyWith(destination: folder));
    final source = _state.sourcePath;
    if (source != null) {
      await chooseSource(source);
    }
  }

  void toggle(String path) {
    final next = {..._state.selection};
    next.contains(path) ? next.remove(path) : next.add(path);
    _setState(_state.copyWith(selection: next));
  }

  void selectNew() => _setState(
    _state.copyWith(
      selection: {
        for (final candidate in _state.candidates)
          if (!candidate.alreadyImported) candidate.path,
      },
    ),
  );

  void selectAll() => _setState(
    _state.copyWith(
      selection: {for (final candidate in _state.candidates) candidate.path},
    ),
  );

  void selectNone() => _setState(_state.copyWith(selection: const {}));

  String folderFor(ImportCandidate candidate) =>
      _service.destinationFolder(candidate, _state.destination);

  /// Copies the selected photos. Completes when done.
  Future<ImportProgress?> startImport() async {
    final selected = _state.selected;
    if (selected.isEmpty || _state.isImporting) {
      return null;
    }
    ImportProgress? last;
    await for (final progress in _service.import(
      selected,
      _state.destination,
    )) {
      last = progress;
      _setState(_state.copyWith(progress: () => progress));
    }
    return last;
  }

  void _setState(ImportState state) {
    if (_isDisposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
