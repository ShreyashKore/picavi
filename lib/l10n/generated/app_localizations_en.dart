// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Picavi';

  @override
  String get emptyStateTitle => 'Picavi desktop viewer';

  @override
  String get emptyStateDescription =>
      'Open any supported image to launch the dense, fullscreen viewer with gesture zoom and a folder-wide thumbnail rail.';

  @override
  String get openImage => 'Open image';

  @override
  String get tipsText =>
      'Tips: drag with the mouse or trackpad to pan, pinch or scroll to zoom, and use ← / → to move through the folder.';

  @override
  String get folderFallback => 'Folder';

  @override
  String viewerPosition(Object directoryName, int current, int total) {
    return '$directoryName • $current / $total';
  }

  @override
  String get folderAccessDenied =>
      'Folder access was not granted, so only the selected image can be shown.';

  @override
  String get folderAccessRequestFailed =>
      'Folder access could not be requested. Showing only the selected image.';

  @override
  String get nativeOpenViewerPrompt => 'Open viewer';

  @override
  String get nativeGrantFolderAccessPrompt => 'Grant folder access';

  @override
  String get nativeGrantFolderAccessMessage =>
      'Allow Picavi to read sibling images in this folder.';
}
