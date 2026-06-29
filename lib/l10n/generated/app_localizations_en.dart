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
  String get emptyStateTitle => 'Picavi';

  @override
  String get emptyStateDescription => 'Lightweight, No frills image viewer.';

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

  @override
  String get settingsTitle => 'Settings';

  @override
  String get defaultViewerTitle => 'Default viewer';

  @override
  String get restoreLastOpenedImageTitle =>
      'Restore last opened image on launch';

  @override
  String get restoreLastOpenedImageDescription =>
      'Reopen the last viewed image, or its folder if the image is no longer available, when Picavi starts without an explicit file.';

  @override
  String get showRecentFoldersTitle => 'Show recent folders on launch';

  @override
  String get showRecentFoldersDescription =>
      'List recently opened folders with image previews on the start screen.';

  @override
  String get recentFoldersTitle => 'Recent folders';

  @override
  String recentFolderImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images',
      one: '1 image',
      zero: 'No images',
    );
    return '$_temp0';
  }

  @override
  String get recentFolderRemoveTooltip => 'Remove from recent';

  @override
  String get versionTitle => 'Version';

  @override
  String get defaultViewerActionSet => 'Set default viewer';

  @override
  String get defaultViewerActionOpenSystemSettings =>
      'Open default apps settings';

  @override
  String get defaultViewerPromptTitle =>
      'Make Picavi your default image viewer?';

  @override
  String get defaultViewerPromptMessage =>
      'You can open images in Picavi directly from Finder, File Explorer, or your file manager. You can change this later from Settings.';

  @override
  String get notNowLabel => 'Not now';

  @override
  String get defaultViewerHintTitle =>
      'Picavi is not the default image viewer.';

  @override
  String get defaultViewerChecking => 'Checking…';

  @override
  String get defaultViewerStatusDefault =>
      'Picavi is currently your default image viewer for supported formats.';

  @override
  String get defaultViewerStatusNotDefault =>
      'Picavi is not your default image viewer yet.';

  @override
  String get defaultViewerGuidedHelp =>
      'Your operating system will guide you through the remaining steps.';

  @override
  String get defaultViewerSetSuccess =>
      'Picavi is now the default image viewer for supported formats.';

  @override
  String get defaultViewerFlowOpened =>
      'System default-app settings were opened.';

  @override
  String get defaultViewerSetFailed =>
      'Picavi couldn\'t be set as the default viewer automatically.';

  @override
  String get defaultViewerUnsupported =>
      'Default viewer setup is not available on this platform.';
}
