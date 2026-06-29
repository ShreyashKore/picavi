import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
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
    size: await _resolveInitialWindowSize(),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(OivApp(initialArguments: initialArguments));
}

/// Returns the preferred window size, clamped so it never exceeds the visible
/// area of the primary display. Without this, a window wider than the screen is
/// centered with a negative origin, pushing the macOS traffic lights off the
/// left edge of the screen.
Future<Size> _resolveInitialWindowSize() async {
  const preferredSize = Size(1366, 900);
  try {
    final display = await screenRetriever.getPrimaryDisplay();
    final visibleSize = display.visibleSize ?? display.size;
    return Size(visibleSize.width, visibleSize.height);
  } catch (_) {
    return preferredSize;
  }
}
