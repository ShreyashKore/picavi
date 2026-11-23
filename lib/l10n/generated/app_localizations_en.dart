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

  @override
  String get moreActionsTooltip => 'More actions';

  @override
  String get renameAction => 'Rename…';

  @override
  String get renameDialogTitle => 'Rename image';

  @override
  String get renameFieldLabel => 'File name';

  @override
  String get renameConfirm => 'Rename';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get renameErrorExists => 'A file with that name already exists.';

  @override
  String get renameErrorInvalid =>
      'That name can\'t be used. Avoid / \\ : * ? \" < > | and a leading dot.';

  @override
  String get renameErrorFailed => 'The image couldn\'t be renamed.';

  @override
  String copyToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copy $count images to folder…',
      one: 'Copy to folder…',
    );
    return '$_temp0';
  }

  @override
  String moveToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count images to folder…',
      one: 'Move to folder…',
    );
    return '$_temp0';
  }

  @override
  String get copyHerePrompt => 'Copy here';

  @override
  String get moveHerePrompt => 'Move here';

  @override
  String get chooseDestinationMessage => 'Choose a folder for the images.';

  @override
  String get copyImageAction => 'Copy image';

  @override
  String get revealInFinderAction => 'Show in Finder';

  @override
  String get revealInExplorerAction => 'Show in File Explorer';

  @override
  String get revealInFileManagerAction => 'Show in folder';

  @override
  String get openWithAction => 'Open with…';

  @override
  String get openWithPrompt => 'Open';

  @override
  String get trashName => 'Trash';

  @override
  String get recycleBinName => 'Recycle Bin';

  @override
  String moveToTrashAction(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count images to $bin',
      one: 'Move to $bin',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmTitle(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count images to the $bin?',
      one: 'Move this image to the $bin?',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmMessage(String bin) {
    return 'You can restore images from the $bin.';
  }

  @override
  String movedToTrashNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count images to the $bin',
      one: 'Moved 1 image to the $bin',
    );
    return '$_temp0';
  }

  @override
  String trashFailedNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images couldn\'t be moved to the $bin',
      one: '1 image couldn\'t be moved to the $bin',
    );
    return '$_temp0';
  }

  @override
  String copiedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $count images',
      one: 'Copied 1 image',
    );
    return '$_temp0';
  }

  @override
  String movedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count images',
      one: 'Moved 1 image',
    );
    return '$_temp0';
  }

  @override
  String copyFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images couldn\'t be copied',
      one: '1 image couldn\'t be copied',
    );
    return '$_temp0';
  }

  @override
  String moveFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images couldn\'t be moved',
      one: '1 image couldn\'t be moved',
    );
    return '$_temp0';
  }

  @override
  String get imageCopiedNotice => 'Image copied to the clipboard';

  @override
  String get clipboardFailedNotice =>
      'Couldn\'t copy the image to the clipboard';

  @override
  String get revealFailedNotice => 'Couldn\'t show the image in its folder';

  @override
  String get openWithFailedNotice => 'Couldn\'t open the image in that app';

  @override
  String selectionCount(int count) {
    return '$count selected';
  }

  @override
  String get clearSelectionTooltip => 'Clear selection';

  @override
  String get shortcutRename => 'Rename image';

  @override
  String shortcutTrash(String bin) {
    return 'Move to $bin';
  }

  @override
  String get shortcutCopyImage => 'Copy image';

  @override
  String get shortcutSelectAll => 'Select all images';

  @override
  String get shortcutSelect => 'Add to / extend selection';

  @override
  String get shortcutEscape => 'Clear selection, leave full screen, or close';

  @override
  String get clickLabel => 'Click';

  @override
  String get slideshowSectionTitle => 'Slideshow';

  @override
  String get slideshowIntervalTitle => 'Time per image';

  @override
  String slideshowIntervalValue(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get slideshowShuffleTitle => 'Shuffle';

  @override
  String get slideshowShuffleDescription =>
      'Show the images in a random order.';

  @override
  String get slideshowLoopTitle => 'Loop';

  @override
  String get slideshowLoopDescription => 'Start over after the last image.';

  @override
  String get slideshowFullScreenTitle => 'Full screen during slideshow';

  @override
  String get slideshowFullScreenDescription =>
      'Switch to full screen when a slideshow starts.';

  @override
  String get enterFullScreenTooltip => 'Full screen';

  @override
  String get exitFullScreenTooltip => 'Exit full screen';

  @override
  String get fillWindowTooltip => 'Fill window';

  @override
  String get fitWindowTooltip => 'Fit to window';

  @override
  String get shortcutFullScreen => 'Full screen on / off';

  @override
  String get shortcutFitFill => 'Fit / fill window';

  @override
  String get dropToOpen => 'Drop to open';

  @override
  String get saveRotationTooltip => 'Save rotation';

  @override
  String get rotationSavedNotice => 'Rotation saved';

  @override
  String rotationUnsupportedNotice(String format) {
    return 'Rotation can\'t be saved for $format images yet';
  }

  @override
  String get rotationSaveFailedNotice =>
      'Couldn\'t save the rotation. The original file is unchanged.';

  @override
  String get shortcutSaveRotation => 'Save rotation to the file';

  @override
  String get editImageTooltip => 'Edit image';

  @override
  String get editUnavailableTooltip => 'This file type can\'t be edited';

  @override
  String get shortcutEdit => 'Edit image';

  @override
  String get editorTabFixes => 'Basic fixes';

  @override
  String get editorTabTuning => 'Tuning';

  @override
  String get editorTabEffects => 'Effects';

  @override
  String get editorCrop => 'Crop';

  @override
  String get editorStraighten => 'Straighten';

  @override
  String get editorRedEye => 'Red-eye';

  @override
  String get editorFeelingLucky => 'I\'m Feeling Lucky';

  @override
  String get editorAutoContrast => 'Auto contrast';

  @override
  String get editorAutoColor => 'Auto color';

  @override
  String get editorTuneFillLight => 'Fill light';

  @override
  String get editorTuneHighlights => 'Highlights';

  @override
  String get editorTuneShadows => 'Shadows';

  @override
  String get editorTuneTemperature => 'Color temperature';

  @override
  String get editorApply => 'Apply';

  @override
  String get editorReset => 'Reset';

  @override
  String get editorClear => 'Clear';

  @override
  String get editorStrength => 'Strength';

  @override
  String get effectBlackAndWhite => 'Black & white';

  @override
  String get effectSepia => 'Sepia';

  @override
  String get effectWarmify => 'Warmify';

  @override
  String get effectSaturation => 'Saturation';

  @override
  String get effectSharpen => 'Sharpen';

  @override
  String get effectSoftFocus => 'Soft focus';

  @override
  String get effectGlow => 'Glow';

  @override
  String get effectFilmGrain => 'Film grain';

  @override
  String get effectVignette => 'Vignette';

  @override
  String get editorCropHint =>
      'Drag the frame or its corners to choose what to keep.';

  @override
  String get editorCropSwapOrientation => 'Portrait / landscape';

  @override
  String get editorCropFree => 'Free';

  @override
  String get editorCropOriginal => 'Original';

  @override
  String get editorCropSquare => 'Square';

  @override
  String get editorCrop4x6 => '4 × 6';

  @override
  String get editorCrop5x7 => '5 × 7';

  @override
  String get editorCrop8x10 => '8 × 10';

  @override
  String get editorCrop16x9 => '16:9';

  @override
  String get editorStraightenHint =>
      'Move the slider until the horizon lines up with the grid.';

  @override
  String editorDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get editorRedEyeHint =>
      'Click the centre of each red eye. Change the size first if the circle is too small or too big.';

  @override
  String get editorRedEyeSize => 'Size';

  @override
  String get editorUndo => 'Undo';

  @override
  String get editorRedo => 'Redo';

  @override
  String get editorRevert => 'Revert';

  @override
  String get editorExport => 'Export…';

  @override
  String get editorDone => 'Done';

  @override
  String get editorLoadFailed => 'This image can\'t be opened for editing.';

  @override
  String get editorSaveFailed =>
      'Couldn\'t save your edits in this folder. They\'ll be lost when you close Picavi.';

  @override
  String editorExported(String name) {
    return 'Saved a copy as $name';
  }

  @override
  String get editorExportFailed => 'Couldn\'t export the image';

  @override
  String exportDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Export $count images',
      one: 'Export image',
    );
    return '$_temp0';
  }

  @override
  String get exportDialogDescription =>
      'Edited copies are saved as new files. Your originals are never changed.';

  @override
  String get exportFormatLabel => 'Format';

  @override
  String get exportFormatJpeg => 'JPEG';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportSizeLabel => 'Size';

  @override
  String get exportSizeOriginal => 'Full size';

  @override
  String exportSizePixels(int size) {
    return '$size px on the long side';
  }

  @override
  String exportQualityLabel(int quality) {
    return 'Quality: $quality';
  }

  @override
  String get exportChooseFolder => 'Choose folder…';

  @override
  String exportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Export $count images…',
      one: 'Export…',
    );
    return '$_temp0';
  }

  @override
  String exportedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count images',
      one: 'Exported 1 image',
    );
    return '$_temp0';
  }

  @override
  String exportFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images couldn\'t be exported',
      one: '1 image couldn\'t be exported',
    );
    return '$_temp0';
  }

  @override
  String quickFixMenu(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quick fix $count images',
      one: 'Quick fix',
    );
    return '$_temp0';
  }

  @override
  String get removeEditsAction => 'Remove edits';

  @override
  String quickFixAppliedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Edited $count images',
      one: 'Edited 1 image',
    );
    return '$_temp0';
  }

  @override
  String quickFixFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images couldn\'t be edited',
      one: '1 image couldn\'t be edited',
    );
    return '$_temp0';
  }

  @override
  String editsRemovedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed the edits from $count images',
      one: 'Removed the edits from 1 image',
    );
    return '$_temp0';
  }

  @override
  String get rotationAddedToEditsNotice =>
      'Rotation saved with this image\'s edits';

  @override
  String get editedBadgeTooltip => 'Edited';

  @override
  String get starTooltip => 'Star (S)';

  @override
  String get unstarTooltip => 'Remove star (S)';

  @override
  String get starredBadgeTooltip => 'Starred';

  @override
  String get shortcutStar => 'Star / remove star';

  @override
  String get captionTagsAction => 'Caption and tags…';

  @override
  String get captionTagsTitle => 'Caption and tags';

  @override
  String get captionLabel => 'Caption';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'Separate tags with commas';

  @override
  String get saveLabel => 'Save';

  @override
  String hideFromLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hide $count images from library',
      one: 'Hide from library',
    );
    return '$_temp0';
  }

  @override
  String showInLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count images in library',
      one: 'Show in library',
    );
    return '$_temp0';
  }

  @override
  String get photoInfoSaveFailedNotice =>
      'Couldn\'t save the star, caption or tags in this folder';

  @override
  String get libraryTitle => 'Library';

  @override
  String get shortcutLibrary => 'Open the library';

  @override
  String get libraryAllPhotos => 'All photos';

  @override
  String get libraryStarred => 'Starred';

  @override
  String get libraryAlbums => 'Albums';

  @override
  String get libraryFolders => 'Folders';

  @override
  String get libraryNoAlbums => 'No albums yet';

  @override
  String get libraryNewAlbum => 'New album';

  @override
  String get libraryAlbumName => 'Album name';

  @override
  String get libraryCreate => 'Create';

  @override
  String get libraryRenameAlbum => 'Rename album';

  @override
  String get libraryDeleteAlbum => 'Delete album';

  @override
  String libraryDeleteAlbumTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get libraryDeleteAlbumMessage =>
      'The photos in it stay where they are; only the album goes.';

  @override
  String libraryAlbumCreated(String name) {
    return 'Created album “$name”';
  }

  @override
  String get libraryAddToAlbum => 'Add to album';

  @override
  String get libraryRemoveFromAlbum => 'Remove from album';

  @override
  String libraryAddedToAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count photos to the album',
      one: 'Added 1 photo to the album',
    );
    return '$_temp0';
  }

  @override
  String libraryRemovedFromAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed $count photos from the album',
      one: 'Removed 1 photo from the album',
    );
    return '$_temp0';
  }

  @override
  String get libraryAddFolder => 'Add folder…';

  @override
  String get libraryRemoveFolder => 'Remove from library';

  @override
  String get libraryRemoveFolderTitle => 'Remove this folder from the library?';

  @override
  String libraryRemoveFolderMessage(String path) {
    return 'Picavi will stop showing photos from $path. Nothing on disk is changed.';
  }

  @override
  String get libraryHideFolder => 'Hide folder';

  @override
  String get libraryShowFolder => 'Show folder';

  @override
  String get libraryRevealFolder => 'Show in file manager';

  @override
  String get libraryShowHidden => 'Show hidden photos';

  @override
  String get libraryHideHidden => 'Don\'t show hidden photos';

  @override
  String get libraryRescan => 'Scan folders again';

  @override
  String get libraryThumbnailSize => 'Thumbnail size';

  @override
  String get librarySearchHint => 'Search names, captions, tags, dates…';

  @override
  String get libraryClearSearch => 'Clear search';

  @override
  String get libraryEmptyTitle => 'Build your photo library';

  @override
  String get libraryEmptyMessage =>
      'Add the folders where you keep photos. Picavi finds every photo inside them, sorts them by month, and keeps the list up to date. Your files stay where they are.';

  @override
  String libraryScanning(int count) {
    return 'Looking for photos… $count found';
  }

  @override
  String get libraryNoMatches => 'No photos match your search';

  @override
  String get libraryNothingHere => 'No photos here';

  @override
  String libraryPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get libraryStar => 'Star';

  @override
  String get libraryUnstar => 'Remove star';

  @override
  String get duplicatesTitle => 'Find duplicates';

  @override
  String get duplicatesSearching => 'Comparing photos…';

  @override
  String get duplicatesNone => 'No duplicate photos found';

  @override
  String duplicatesSummary(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count sets of identical photos. Keep one copy of each and move the others to the $bin.',
      one:
          '1 set of identical photos. Keep one copy and move the others to the $bin.',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesKeepOnly => 'Keep only this';

  @override
  String get libraryPickFolderMessage =>
      'Choose a folder that holds photos. Its sub-folders are included.';

  @override
  String get libraryOpenFailed => 'Couldn\'t open the library';

  @override
  String shareAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Share $count images…',
      one: 'Share…',
    );
    return '$_temp0';
  }

  @override
  String get shareFailedNotice => 'Couldn\'t open the share menu';
}
