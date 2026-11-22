import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/viewer/data/services/desktop_file_operations_service.dart';
import 'package:oiv/viewer/data/services/native_file_channel_service.dart';
import 'package:oiv/viewer/domain/services/file_operations_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Directory source;
  late Directory destination;
  final service = DesktopFileOperationsService(
    nativeChannel: NativeFileChannelService(),
  );

  setUp(() async {
    root = await Directory.systemTemp.createTemp('oiv_file_ops');
    source = await Directory(p.join(root.path, 'source')).create();
    destination = await Directory(p.join(root.path, 'dest')).create();
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<String> write(Directory directory, String name, [String body = 'x']) {
    final file = File(p.join(directory.path, name));
    return file.writeAsString(body).then((_) => file.path);
  }

  List<String> namesIn(Directory directory) =>
      directory.listSync().map((entity) => p.basename(entity.path)).toList()
        ..sort();

  group('rename', () {
    test('renames within the same folder', () async {
      final path = await write(source, 'a.png');

      final renamed = await service.rename(path, 'beach.png');

      expect(renamed, p.join(source.path, 'beach.png'));
      expect(namesIn(source), <String>['beach.png']);
    });

    test('refuses to overwrite an existing file', () async {
      final path = await write(source, 'a.png', 'first');
      await write(source, 'b.png', 'second');

      await expectLater(
        service.rename(path, 'b.png'),
        throwsA(
          isA<FileOperationException>().having(
            (error) => error.error,
            'error',
            FileOperationError.alreadyExists,
          ),
        ),
      );
      expect(await File(p.join(source.path, 'b.png')).readAsString(), 'second');
    });

    test('rejects names with separators or a leading dot', () async {
      final path = await write(source, 'a.png');

      for (final name in <String>['../a.png', 'x/y.png', '.hidden.png', ' ']) {
        await expectLater(
          service.rename(path, name),
          throwsA(
            isA<FileOperationException>().having(
              (error) => error.error,
              'error',
              FileOperationError.invalidName,
            ),
          ),
        );
      }
      expect(namesIn(source), <String>['a.png']);
    });

    test('allows changing only the letter case', () async {
      final path = await write(source, 'photo.png');

      final renamed = await service.rename(path, 'Photo.png');

      expect(p.basename(renamed), 'Photo.png');
      expect(namesIn(source), <String>['Photo.png']);
    });
  });

  group('copy and move', () {
    test('copy never overwrites and numbers duplicates', () async {
      final a = await write(source, 'a.png', 'new');
      await write(destination, 'a.png', 'old');

      final copied = await service.copyTo([a], destination.path);

      expect(copied, {a: p.join(destination.path, 'a (2).png')});
      expect(namesIn(destination), <String>['a (2).png', 'a.png']);
      expect(
        await File(p.join(destination.path, 'a.png')).readAsString(),
        'old',
      );
      expect(namesIn(source), <String>['a.png']);
    });

    test('move takes files out of the source folder', () async {
      final a = await write(source, 'a.png');
      final b = await write(source, 'b.png');

      final moved = await service.moveTo([a, b], destination.path);

      expect(moved.keys, [a, b]);
      expect(moved[a], p.join(destination.path, 'a.png'));
      expect(namesIn(source), isEmpty);
      expect(namesIn(destination), <String>['a.png', 'b.png']);
    });

    test('moving into the same folder is a no-op', () async {
      final a = await write(source, 'a.png');

      final moved = await service.moveTo([a], source.path);

      expect(moved, isEmpty);
      expect(namesIn(source), <String>['a.png']);
    });

    test('missing files are skipped, not fatal', () async {
      final a = await write(source, 'a.png');
      final missing = p.join(source.path, 'gone.png');

      final copied = await service.copyTo([missing, a], destination.path);

      expect(copied.keys, [a]);
    });
  });
}
