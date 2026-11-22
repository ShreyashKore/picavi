import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/core/sidecar/picavi_sidecar_store.dart';
import 'package:oiv/editor/data/repositories/sidecar_image_edit_repository.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/library/data/repositories/sidecar_photo_info_repository.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  const infoRepository = SidecarPhotoInfoRepository();
  final editRepository = SidecarImageEditRepository();
  const starred = PhotoInfo(
    starred: true,
    caption: 'Beach',
    tags: ['summer', 'family'],
  );
  const sepia = ImageEdits([EffectEdit(EffectKind.sepia, 1)]);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('oiv_info');
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  String image(String name) => p.join(root.path, name);

  test('round-trips stars, captions, tags and hidden', () async {
    await infoRepository.save(image('a.jpg'), starred);
    await infoRepository.save(image('b.jpg'), const PhotoInfo(hidden: true));

    expect(await infoRepository.load(image('a.jpg')), starred);
    expect(await infoRepository.loadDirectory(root.path), {
      image('a.jpg'): starred,
      image('b.jpg'): const PhotoInfo(hidden: true),
    });
  });

  test(
    'info and edits share one entry without overwriting each other',
    () async {
      await Future.wait([
        editRepository.save(image('a.jpg'), sepia),
        infoRepository.save(image('a.jpg'), starred),
      ]);

      expect(await editRepository.load(image('a.jpg')), sepia);
      expect(await infoRepository.load(image('a.jpg')), starred);

      await infoRepository.save(image('a.jpg'), PhotoInfo.none);
      expect(await editRepository.load(image('a.jpg')), sepia);
      expect(await infoRepository.loadDirectory(root.path), isEmpty);

      await editRepository.save(image('a.jpg'), ImageEdits.none);
      expect(
        await File(PicaviSidecarStore.sidecarPathFor(root.path)).exists(),
        isFalse,
      );
    },
  );

  test('moving info leaves the edits behind for the edit repository', () async {
    await editRepository.save(image('a.jpg'), sepia);
    await infoRepository.save(image('a.jpg'), starred);

    await infoRepository.move(image('a.jpg'), image('b.jpg'));
    await editRepository.move(image('a.jpg'), image('b.jpg'));

    expect(await infoRepository.load(image('b.jpg')), starred);
    expect(await editRepository.load(image('b.jpg')), sepia);
    expect(await infoRepository.loadDirectory(root.path), hasLength(1));
  });

  test('keeps fields it does not know about', () async {
    await File(
      PicaviSidecarStore.sidecarPathFor(root.path),
    ).writeAsString('{"version": 1, "images": {"a.jpg": {"faces": [1, 2]}}}');

    await infoRepository.save(image('a.jpg'), starred);
    await infoRepository.save(image('a.jpg'), PhotoInfo.none);

    final entries = await const PicaviSidecarStore().read(root.path);
    expect(entries['a.jpg'], {
      'faces': [1, 2],
    });
  });

  test('parses comma-separated tags', () {
    expect(PhotoInfo.parseTags(' Summer, beach,,summer , Goa '), [
      'Summer',
      'beach',
      'Goa',
    ]);
  });
}
