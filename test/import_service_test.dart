import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/library/data/services/file_system_import_service.dart';
import 'package:oiv/library/presentation/controllers/import_controller.dart';
import 'package:path/path.dart' as p;

import 'support/library_fakes.dart';

void main() {
  late Directory root;
  late String volumes;
  late String card;
  late String pictures;
  late FileSystemImportService service;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('oiv_import');
    volumes = p.join(root.path, 'Volumes');
    card = p.join(volumes, 'EOS_DIGITAL');
    pictures = p.join(root.path, 'Pictures');
    await Directory(p.join(volumes, 'USB_STICK')).create(recursive: true);
    service = FileSystemImportService(
      volumeRoots: () => [volumes],
      extensions: {'.jpg'},
    );
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<String> photo(String relative, {String? taken}) async {
    final image = img.Image(width: 4, height: 4);
    if (taken != null) {
      image.exif.exifIfd['DateTimeOriginal'] = img.IfdValueAscii(taken);
    }
    final file = File(p.join(card, relative));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(img.encodeJpg(image));
    return file.path;
  }

  test('finds only volumes with a DCIM folder', () async {
    await photo('DCIM/100CANON/IMG_0001.jpg');

    final sources = await service.findSources();

    expect(sources.map((s) => s.name), ['EOS_DIGITAL']);
  });

  test('scans DCIM, sorts by date and imports into dated folders', () async {
    await photo('DCIM/100CANON/IMG_0002.jpg', taken: '2023:12:31 23:00:00');
    await photo('DCIM/100CANON/IMG_0001.jpg', taken: '2023:06:01 10:00:00');
    await photo('MISC/not_a_photo.jpg');

    final candidates = await service.scan(card, pictures);
    expect(candidates.map((c) => p.basename(c.path)), [
      'IMG_0001.jpg',
      'IMG_0002.jpg',
    ]);

    final progress = await service.import(candidates, pictures).toList();

    expect(progress.last.done, isTrue);
    expect(progress.last.copied, 2);
    expect(
      await File(
        p.join(pictures, '2023', '2023-06-01', 'IMG_0001.jpg'),
      ).exists(),
      isTrue,
    );
    expect(
      await File(
        p.join(pictures, '2023', '2023-12-31', 'IMG_0002.jpg'),
      ).exists(),
      isTrue,
    );
    expect(
      await File(p.join(card, 'DCIM', '100CANON', 'IMG_0001.jpg')).exists(),
      isTrue,
      reason: 'the card is never changed',
    );
  });

  test('marks and skips photos imported before; never overwrites', () async {
    await photo('DCIM/100CANON/IMG_0001.jpg', taken: '2023:06:01 10:00:00');
    final day = Directory(p.join(pictures, '2023', '2023-06-01'));
    await service
        .import(await service.scan(card, pictures), pictures)
        .drain<void>();

    final rescan = await service.scan(card, pictures);
    expect(rescan.single.alreadyImported, isTrue);

    // A different file with the same name already sits in the folder.
    await File(p.join(day.path, 'IMG_0001.jpg')).writeAsString('other');
    final progress = await service.import(rescan, pictures).toList();

    expect(progress.last.copied, 1);
    expect(day.listSync().map((e) => p.basename(e.path)).toSet(), {
      'IMG_0001.jpg',
      'IMG_0001 (2).jpg',
    });
    expect(
      await File(p.join(day.path, 'IMG_0001.jpg')).readAsString(),
      'other',
    );
  });

  test(
    'controller pre-selects new photos and remembers the destination',
    () async {
      await photo('DCIM/100CANON/IMG_0001.jpg', taken: '2023:06:01 10:00:00');
      await photo('DCIM/100CANON/IMG_0002.jpg', taken: '2023:06:02 10:00:00');
      await service.import([
        (await service.scan(card, pictures)).first,
      ], pictures).drain<void>();
      final settings = InMemoryLibrarySettings();
      final controller = ImportController(
        service: service,
        settings: settings,
        defaultDestination: pictures,
      );
      addTearDown(controller.dispose);

      await controller.open();

      expect(controller.state.sourcePath, card);
      expect(controller.state.selected.map((c) => p.basename(c.path)), [
        'IMG_0002.jpg',
      ]);

      final result = await controller.startImport();
      expect(result?.copied, 1);
      expect(controller.state.isDone, isTrue);

      final elsewhere = p.join(root.path, 'Elsewhere');
      await controller.setDestination(elsewhere);
      expect(settings.destination, elsewhere);
      expect(controller.state.selection, hasLength(2));
    },
  );
}
