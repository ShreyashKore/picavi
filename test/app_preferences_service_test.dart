import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/core/services/app_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesService', () {
    late AppPreferencesService service;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      service = AppPreferencesService();
    });

    test('restore last opened image is enabled by default', () async {
      expect(await service.isRestoreLastOpenedImageEnabled(), isTrue);
      expect(await service.resolveStartupOpenPath(), isNull);
    });

    test(
      'resolveStartupOpenPath returns saved image path when it exists',
      () async {
        final tempDirectory = await Directory.systemTemp.createTemp(
          'oiv-prefs-file-',
        );
        addTearDown(() async {
          if (await tempDirectory.exists()) {
            await tempDirectory.delete(recursive: true);
          }
        });

        final imageFile = File('${tempDirectory.path}/photo.png');
        await imageFile.writeAsBytes(const <int>[0]);

        await service.setRestoreLastOpenedImageEnabled(true);
        await service.setLastOpenedImagePath(imageFile.path);

        expect(await service.resolveStartupOpenPath(), imageFile.absolute.path);
      },
    );

    test(
      'resolveStartupOpenPath falls back to parent folder when file is gone',
      () async {
        final tempDirectory = await Directory.systemTemp.createTemp(
          'oiv-prefs-folder-',
        );
        addTearDown(() async {
          if (await tempDirectory.exists()) {
            await tempDirectory.delete(recursive: true);
          }
        });

        final missingImagePath = '${tempDirectory.path}/missing.png';

        await service.setRestoreLastOpenedImageEnabled(true);
        await service.setLastOpenedImagePath(missingImagePath);

        expect(
          await service.resolveStartupOpenPath(),
          Directory(tempDirectory.path).absolute.path,
        );
      },
    );

    test('disabling restore clears the saved last opened image path', () async {
      await service.setRestoreLastOpenedImageEnabled(true);
      await service.setLastOpenedImagePath('/tmp/example.png');

      await service.setRestoreLastOpenedImageEnabled(false);

      expect(await service.getLastOpenedImagePath(), isNull);
      expect(await service.resolveStartupOpenPath(), isNull);
    });
  });
}
