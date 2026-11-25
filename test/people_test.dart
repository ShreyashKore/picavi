import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/library/data/services/face_grouping.dart';
import 'package:oiv/library/data/services/face_scanner.dart';
import 'package:oiv/library/data/services/vision_face_detector_service.dart';
import 'package:oiv/library/domain/entities/catalog_image.dart';
import 'package:oiv/library/domain/entities/face.dart';
import 'package:oiv/library/domain/entities/library_query.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';
import 'package:oiv/library/presentation/controllers/people_controller.dart';

import 'support/editor_fakes.dart';
import 'support/library_fakes.dart';

CatalogFaceBuilder face(int id, int axis, {double noise = 0, String? name}) =>
    CatalogFaceBuilder(id, axis, noise, name);

class CatalogFaceBuilder {
  CatalogFaceBuilder(this.id, this.axis, this.noise, this.name);
  final int id;
  final int axis;
  final double noise;
  final String? name;

  CatalogFace build() => CatalogFace(
    id: id,
    path: '/p/$id.jpg',
    box: const FaceBox(0, 0, 0.1, 0.1),
    print: facePrint(axis, noise: noise),
    name: name,
  );
}

void main() {
  group('grouping', () {
    test('groups faces that look alike, largest group first', () {
      final faces = [
        face(1, 0).build(),
        face(2, 3).build(),
        face(3, 0, noise: 0.1).build(),
        face(4, 0, noise: 0.2).build(),
        face(5, 3, noise: 0.1).build(),
        CatalogFace(id: 6, path: '/p/6.jpg', box: const FaceBox(0, 0, 1, 1)),
      ];

      final groups = groupFaces(faces);

      expect(groups.map((g) => g.map((f) => f.id).toList()), [
        [1, 3, 4],
        [2, 5],
        [6],
      ]);
    });

    test('suggests close unnamed faces, best first', () {
      final alice = [face(1, 0, name: 'Alice').build()];
      final candidates = [
        face(2, 0, noise: 0.3).build(),
        face(3, 0, noise: 0.05).build(),
        face(4, 5).build(),
        face(5, 0, name: 'Bob').build(),
      ];

      expect(suggestFaces(alice, candidates).map((f) => f.id), [3, 2]);
    });

    test('distance of normalised prints', () {
      expect(
        faceDistance(
          normalizedPrint(facePrint(0)),
          normalizedPrint(facePrint(0)),
        ),
        0,
      );
      expect(
        faceDistance(
          normalizedPrint(facePrint(0)),
          normalizedPrint(facePrint(1)),
        ),
        closeTo(1.4142, 1e-3),
      );
    });
  });

  test('box overlap', () {
    const a = FaceBox(0, 0, 0.2, 0.2);
    expect(a.overlap(a), 1);
    expect(a.overlap(const FaceBox(0.5, 0.5, 0.2, 0.2)), 0);
    expect(a.overlap(const FaceBox(0.1, 0, 0.2, 0.2)), closeTo(1 / 3, 1e-9));
  });

  test('parses the native reply and skips broken faces', () {
    final faces = parseDetectedFaces({
      'width': 100,
      'height': 50,
      'faces': [
        {
          'left': 0.1,
          'top': 0.2,
          'width': 0.3,
          'height': 0.4,
          'crop': Uint8List(3),
          'print': Float32List(4),
        },
        {'left': 0.1},
        'junk',
      ],
    })!;

    expect(faces, hasLength(1));
    expect(faces.single.box, const FaceBox(0.1, 0.2, 0.3, 0.4));
    expect(faces.single.print, hasLength(4));
    expect(parseDetectedFaces(null), isNull);
  });

  group('catalog and scanner', () {
    late LibraryFixture fixture;

    setUp(() async {
      fixture = LibraryFixture([], roots: ['/p']);
      await fixture.catalog.upsert([
        catalogPhoto('/p/a.jpg'),
        catalogPhoto(
          '/p/b.jpg',
          info: const PhotoInfo(
            people: [PersonTag('Alice', FaceBox(0.1, 0.1, 0.2, 0.2))],
          ),
        ),
      ]);
    });

    tearDown(() => fixture.catalog.close());

    test('scans new photos once, matching saved names', () async {
      final detector = FakeFaceDetector({
        '/p/a.jpg': [detectedFace(0), detectedFace(3, left: 0.6)],
        '/p/b.jpg': [detectedFace(0, left: 0.12)],
      });
      final scanner = FaceScanner(fixture.catalog, detector);

      final progress = await scanner.scan().toList();
      expect(progress.last.done, isTrue);
      expect(progress.last.processed, 2);

      final all = await fixture.catalog.faces(withPrints: true);
      expect(all, hasLength(3));
      expect(all.where((f) => f.name == 'Alice').single.path, '/p/b.jpg');
      expect(all.first.print, hasLength(8));
      expect(all.first.crop, isNotNull);

      await scanner.scan().drain<void>();
      expect(
        detector.calls,
        hasLength(2),
        reason: 'unchanged photos are skipped',
      );

      expect((await fixture.catalog.people()).single.name, 'Alice');
      expect(
        (await fixture.catalog.search(
          const LibraryQuery(person: 'Alice'),
        )).single.path,
        '/p/b.jpg',
      );
      expect(
        (await fixture.catalog.search(
          const LibraryQuery(text: 'alice'),
        )).single.path,
        '/p/b.jpg',
      );
    });

    test('a failed scan is tried again', () async {
      final detector = FakeFaceDetector({
        '/p/a.jpg': [detectedFace(0)],
      })..failing.add('/p/a.jpg');
      final scanner = FaceScanner(fixture.catalog, detector);

      final progress = await scanner.scan().toList();
      expect(progress.last.done, isTrue);
      expect(progress.last.processed, 2);
      expect(await fixture.catalog.faces(), isEmpty);
      expect((await fixture.catalog.faceScanStamps()).keys, ['/p/b.jpg']);

      detector
        ..failing.clear()
        ..calls.clear();
      await scanner.scan().drain<void>();
      expect(detector.calls, ['/p/a.jpg']);
      expect((await fixture.catalog.faces()).single.path, '/p/a.jpg');
    });

    test('a failed scan of a changed photo keeps its faces', () async {
      final detector = FakeFaceDetector({
        '/p/a.jpg': [detectedFace(0)],
      });
      final scanner = FaceScanner(fixture.catalog, detector);
      await scanner.scan().drain<void>();
      final before = await fixture.catalog.faceScanStamps();

      // Scanned when the file was different.
      await fixture.catalog.replaceFaces('/p/a.jpg', const FileStamp(1, 1), [
        (detectedFace(0), 'Alice'),
      ]);
      detector.failing.add('/p/a.jpg');
      await scanner.scan().drain<void>();
      expect((await fixture.catalog.faces()).single.name, 'Alice');

      detector.failing.clear();
      await scanner.scan().drain<void>();
      expect(await fixture.catalog.faceScanStamps(), before);
    });

    test('SVGs are not scanned', () async {
      await fixture.catalog.upsert([catalogPhoto('/p/logo.SVG')]);
      final detector = FakeFaceDetector({});

      await FaceScanner(fixture.catalog, detector).scan().drain<void>();

      expect(detector.calls, unorderedEquals(['/p/a.jpg', '/p/b.jpg']));
    });

    test('removing photos drops their faces', () async {
      await FaceScanner(
        fixture.catalog,
        FakeFaceDetector({
          '/p/a.jpg': [detectedFace(0)],
        }),
      ).scan().drain<void>();

      await fixture.catalog.remove(['/p/a.jpg']);

      expect(await fixture.catalog.faces(), isEmpty);
      expect((await fixture.catalog.faceScanStamps()).keys, ['/p/b.jpg']);
    });
  });

  group('PeopleController', () {
    late LibraryFixture fixture;
    late InMemoryPhotoInfoRepository info;
    late PeopleController controller;

    setUp(() async {
      fixture = LibraryFixture([], roots: ['/p']);
      await fixture.catalog.upsert([
        catalogPhoto('/p/a.jpg'),
        catalogPhoto('/p/b.jpg'),
        catalogPhoto('/p/c.jpg'),
      ]);
      info = InMemoryPhotoInfoRepository();
      controller = PeopleController(
        catalog: fixture.catalog,
        detector: FakeFaceDetector({
          '/p/a.jpg': [detectedFace(0)],
          '/p/b.jpg': [detectedFace(0, noise: 0.1), detectedFace(4, left: 0.6)],
          '/p/c.jpg': [detectedFace(0, noise: 0.7)],
        }),
        photoInfo: info,
      );
      await controller.open();
      await pumpEventQueue(times: 50);
    });

    tearDown(() async {
      controller.dispose();
      await fixture.catalog.close();
    });

    test('groups unnamed faces after scanning', () {
      expect(controller.state.isScanning, isFalse);
      expect(controller.state.groups.map((g) => g.length), [2, 1, 1]);
      expect(controller.state.unnamedCount, 4);
    });

    test('naming saves to the sidecar and suggests look-alikes', () async {
      final group = controller.state.groups.first;

      await controller.nameFaces(group, ' Alice ');

      expect(controller.state.people.single.name, 'Alice');
      expect(controller.state.people.single.photoCount, 2);
      expect(info.stored['/p/a.jpg']?.people.single.name, 'Alice');
      expect(
        (await fixture.catalog.image('/p/b.jpg'))!.info.people.single.name,
        'Alice',
      );

      await controller.openPerson('Alice');
      expect(controller.state.personImages, hasLength(2));
      final suggestion = controller.state.suggestions.single;
      expect(suggestion.path, '/p/c.jpg');

      controller.rejectSuggestion(suggestion);
      expect(controller.state.suggestions, isEmpty);
      await controller.reload();
      expect(controller.state.suggestions, isEmpty, reason: 'stays rejected');
    });

    test('accepting a suggestion, renaming and forgetting', () async {
      await controller.nameFaces(controller.state.groups.first, 'Alice');
      await controller.openPerson('Alice');
      await controller.acceptSuggestion(controller.state.suggestions.single);
      expect(controller.state.personImages, hasLength(3));

      await controller.renamePerson('Alice', 'Alicia');
      expect(controller.state.person, 'Alicia');
      expect(controller.state.people.single.name, 'Alicia');
      expect(info.stored['/p/c.jpg']?.people.single.name, 'Alicia');

      await controller.removePerson('Alicia');
      expect(controller.state.people, isEmpty);
      expect(controller.state.person, isNull);
      expect(info.stored, isEmpty);
    });

    test('picked faces narrow actions; ignored faces disappear', () async {
      final group = controller.state.groups.first;
      controller.toggleFace(group.first.id);
      expect(controller.targetsIn(group), [group.first]);

      await controller.ignoreFaces(controller.targetsIn(group));

      expect(controller.state.unnamedCount, 3);
      expect(controller.state.selectedFaces, isEmpty);
    });
  });
}
