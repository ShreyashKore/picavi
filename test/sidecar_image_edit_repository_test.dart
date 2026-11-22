import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/editor/data/repositories/sidecar_image_edit_repository.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late SidecarImageEditRepository repository;
  const sepia = ImageEdits([EffectEdit(EffectKind.sepia, 1)]);
  const crop = ImageEdits([CropEdit(NormalizedRect(0, 0, 0.5, 1))]);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('oiv_sidecar');
    repository = SidecarImageEditRepository();
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  String image(String name) => p.join(root.path, name);
  File sidecar() =>
      File(p.join(root.path, SidecarImageEditRepository.fileName));

  test('saves and loads edits per image', () async {
    expect(await repository.save(image('a.jpg'), sepia), isTrue);
    expect(await repository.save(image('b.jpg'), crop), isTrue);

    expect(await repository.load(image('a.jpg')), sepia);
    expect(await repository.loadDirectory(root.path), {
      image('a.jpg'): sepia,
      image('b.jpg'): crop,
    });
    final json = jsonDecode(await sidecar().readAsString()) as Map;
    expect(json['version'], 1);
    expect((json['images'] as Map).keys, ['a.jpg', 'b.jpg']);
  });

  test('missing or corrupt sidecars read as no edits', () async {
    expect(await repository.load(image('a.jpg')), ImageEdits.none);

    await sidecar().writeAsString('{not json');

    expect(await repository.loadDirectory(root.path), isEmpty);
  });

  test('saving no edits removes the entry, then the file', () async {
    await repository.save(image('a.jpg'), sepia);
    await repository.save(image('b.jpg'), crop);

    await repository.save(image('a.jpg'), ImageEdits.none);
    expect((await repository.loadDirectory(root.path)).keys, [image('b.jpg')]);

    await repository.save(image('b.jpg'), ImageEdits.none);
    expect(await sidecar().exists(), isFalse);
  });

  test('concurrent saves are not lost', () async {
    await Future.wait([
      for (var i = 0; i < 10; i++) repository.save(image('$i.jpg'), sepia),
    ]);

    expect(await repository.loadDirectory(root.path), hasLength(10));
    expect(root.listSync(), hasLength(1));
  });

  test('edits follow a rename or move, and copies get them too', () async {
    final other = await Directory(p.join(root.path, 'other')).create();
    await repository.save(image('a.jpg'), sepia);

    await repository.move(image('a.jpg'), image('renamed.jpg'));
    expect(await repository.load(image('a.jpg')), ImageEdits.none);
    expect(await repository.load(image('renamed.jpg')), sepia);

    await repository.copy(image('renamed.jpg'), p.join(other.path, 'c.jpg'));
    await repository.move(image('renamed.jpg'), p.join(other.path, 'm.jpg'));
    expect(await repository.loadDirectory(other.path), {
      p.join(other.path, 'c.jpg'): sepia,
      p.join(other.path, 'm.jpg'): sepia,
    });
    expect(await sidecar().exists(), isFalse);
  });

  test('fails soft when the folder is missing', () async {
    final missing = p.join(root.path, 'gone', 'a.jpg');

    expect(await repository.save(missing, sepia), isFalse);
    expect(await repository.load(missing), ImageEdits.none);
  });
}
