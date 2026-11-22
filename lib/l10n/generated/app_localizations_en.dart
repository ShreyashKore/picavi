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

  @override
  String get zoomOutTooltip => 'Zoom out';

  @override
  String get zoomInTooltip => 'Zoom in';

  @override
  String get actualSizeTooltip => 'Actual size (1:1)';

  @override
  String get rotateLeftTooltip => 'Rotate left';

  @override
  String get rotateRightTooltip => 'Rotate right';

  @override
  String get showImageInfoTooltip => 'Show image info';

  @override
  String get hideImageInfoTooltip => 'Hide image info';

  @override
  String get previousImageTooltip => 'Previous image';

  @override
  String get nextImageTooltip => 'Next image';

  @override
  String get playSlideshowTooltip => 'Play slideshow';

  @override
  String get pauseSlideshowTooltip => 'Pause slideshow';

  @override
  String get imageLoadFailed => 'Failed to load image';

  @override
  String get unknownValue => 'Unknown';

  @override
  String get loadingValue => 'Loading…';

  @override
  String get infoImageLabel => 'Image';

  @override
  String infoImagePosition(int current, int total) {
    return '$current of $total';
  }

  @override
  String get infoTypeLabel => 'Type';

  @override
  String get infoResolutionLabel => 'Resolution';

  @override
  String get infoFileSizeLabel => 'File size';

  @override
  String get infoCapturedLabel => 'Captured';

  @override
  String get infoModifiedLabel => 'Modified';

  @override
  String get infoCameraLabel => 'Camera';

  @override
  String get infoLensLabel => 'Lens';

  @override
  String get infoFocalLengthLabel => 'Focal length';

  @override
  String get infoApertureLabel => 'Aperture';

  @override
  String get infoExposureLabel => 'Exposure';

  @override
  String get infoIsoLabel => 'ISO';

  @override
  String get sortTooltip => 'Sort images';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByModified => 'Date modified';

  @override
  String get sortBySize => 'File size';

  @override
  String get sortByType => 'File type';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get keyboardShortcutsTitle => 'Keyboard shortcuts';

  @override
  String get shortcutNextPrevious => 'Next / previous image';

  @override
  String get shortcutFirstLast => 'First / last image';

  @override
  String get shortcutPlayPause => 'Play / pause slideshow';

  @override
  String get shortcutZoom => 'Zoom in / out';

  @override
  String get shortcutActualSize => 'Actual size (1:1)';

  @override
  String get shortcutFit => 'Fit to window';

  @override
  String get shortcutRotate => 'Rotate right / left';

  @override
  String get shortcutInfo => 'Show / hide image info';

  @override
  String get shortcutHelp => 'Show keyboard shortcuts';

  @override
  String get shortcutClose => 'Close Picavi';

  @override
  String get closeLabel => 'Close';
}
