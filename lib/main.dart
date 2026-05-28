import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/services/app_preferences_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final initialArguments = List<String>.of(args);

  if (initialArguments.isEmpty) {
    final startupPath = await AppPreferencesService().resolveStartupOpenPath();
    if (startupPath != null) {
      initialArguments.add(startupPath);
    }
  }

  final windowOptions = WindowOptions(
    size: const Size(1400, 900),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(OivApp(initialArguments: initialArguments));
}
