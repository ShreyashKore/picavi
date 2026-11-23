import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('mr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Picavi'**
  String get appTitle;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Picavi'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateDescription.
  ///
  /// In en, this message translates to:
  /// **'Lightweight, No frills image viewer.'**
  String get emptyStateDescription;

  /// No description provided for @openImage.
  ///
  /// In en, this message translates to:
  /// **'Open image'**
  String get openImage;

  /// No description provided for @tipsText.
  ///
  /// In en, this message translates to:
  /// **'Tips: drag with the mouse or trackpad to pan, pinch or scroll to zoom, and use ← / → to move through the folder.'**
  String get tipsText;

  /// No description provided for @folderFallback.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folderFallback;

  /// No description provided for @viewerPosition.
  ///
  /// In en, this message translates to:
  /// **'{directoryName} • {current} / {total}'**
  String viewerPosition(Object directoryName, int current, int total);

  /// No description provided for @folderAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Folder access was not granted, so only the selected image can be shown.'**
  String get folderAccessDenied;

  /// No description provided for @folderAccessRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Folder access could not be requested. Showing only the selected image.'**
  String get folderAccessRequestFailed;

  /// No description provided for @nativeOpenViewerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Open viewer'**
  String get nativeOpenViewerPrompt;

  /// No description provided for @nativeGrantFolderAccessPrompt.
  ///
  /// In en, this message translates to:
  /// **'Grant folder access'**
  String get nativeGrantFolderAccessPrompt;

  /// No description provided for @nativeGrantFolderAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow Picavi to read sibling images in this folder.'**
  String get nativeGrantFolderAccessMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @defaultViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Default viewer'**
  String get defaultViewerTitle;

  /// No description provided for @restoreLastOpenedImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore last opened image on launch'**
  String get restoreLastOpenedImageTitle;

  /// No description provided for @restoreLastOpenedImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Reopen the last viewed image, or its folder if the image is no longer available, when Picavi starts without an explicit file.'**
  String get restoreLastOpenedImageDescription;

  /// No description provided for @showRecentFoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Show recent folders on launch'**
  String get showRecentFoldersTitle;

  /// No description provided for @showRecentFoldersDescription.
  ///
  /// In en, this message translates to:
  /// **'List recently opened folders with image previews on the start screen.'**
  String get showRecentFoldersDescription;

  /// No description provided for @recentFoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent folders'**
  String get recentFoldersTitle;

  /// No description provided for @recentFolderImageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No images} =1{1 image} other{{count} images}}'**
  String recentFolderImageCount(int count);

  /// No description provided for @recentFolderRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from recent'**
  String get recentFolderRemoveTooltip;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @defaultViewerActionSet.
  ///
  /// In en, this message translates to:
  /// **'Set default viewer'**
  String get defaultViewerActionSet;

  /// No description provided for @defaultViewerActionOpenSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open default apps settings'**
  String get defaultViewerActionOpenSystemSettings;

  /// No description provided for @defaultViewerPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Make Picavi your default image viewer?'**
  String get defaultViewerPromptTitle;

  /// No description provided for @defaultViewerPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'You can open images in Picavi directly from Finder, File Explorer, or your file manager. You can change this later from Settings.'**
  String get defaultViewerPromptMessage;

  /// No description provided for @notNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowLabel;

  /// No description provided for @defaultViewerHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Picavi is not the default image viewer.'**
  String get defaultViewerHintTitle;

  /// No description provided for @defaultViewerChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get defaultViewerChecking;

  /// No description provided for @defaultViewerStatusDefault.
  ///
  /// In en, this message translates to:
  /// **'Picavi is currently your default image viewer for supported formats.'**
  String get defaultViewerStatusDefault;

  /// No description provided for @defaultViewerStatusNotDefault.
  ///
  /// In en, this message translates to:
  /// **'Picavi is not your default image viewer yet.'**
  String get defaultViewerStatusNotDefault;

  /// No description provided for @defaultViewerGuidedHelp.
  ///
  /// In en, this message translates to:
  /// **'Your operating system will guide you through the remaining steps.'**
  String get defaultViewerGuidedHelp;

  /// No description provided for @defaultViewerSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Picavi is now the default image viewer for supported formats.'**
  String get defaultViewerSetSuccess;

  /// No description provided for @defaultViewerFlowOpened.
  ///
  /// In en, this message translates to:
  /// **'System default-app settings were opened.'**
  String get defaultViewerFlowOpened;

  /// No description provided for @defaultViewerSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Picavi couldn\'t be set as the default viewer automatically.'**
  String get defaultViewerSetFailed;

  /// No description provided for @defaultViewerUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Default viewer setup is not available on this platform.'**
  String get defaultViewerUnsupported;

  /// Tooltip for the zoom-out button.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOutTooltip;

  /// Tooltip for the zoom-in button.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomInTooltip;

  /// Tooltip for the 1:1 button that shows the image at its actual pixel size.
  ///
  /// In en, this message translates to:
  /// **'Actual size (1:1)'**
  String get actualSizeTooltip;

  /// Tooltip for the rotate-left button.
  ///
  /// In en, this message translates to:
  /// **'Rotate left'**
  String get rotateLeftTooltip;

  /// Tooltip for the rotate-right button.
  ///
  /// In en, this message translates to:
  /// **'Rotate right'**
  String get rotateRightTooltip;

  /// Tooltip for the button that shows the image info panel.
  ///
  /// In en, this message translates to:
  /// **'Show image info'**
  String get showImageInfoTooltip;

  /// Tooltip for the button that hides the image info panel.
  ///
  /// In en, this message translates to:
  /// **'Hide image info'**
  String get hideImageInfoTooltip;

  /// Tooltip for the previous-image button.
  ///
  /// In en, this message translates to:
  /// **'Previous image'**
  String get previousImageTooltip;

  /// Tooltip for the next-image button.
  ///
  /// In en, this message translates to:
  /// **'Next image'**
  String get nextImageTooltip;

  /// Tooltip for the button that starts the slideshow.
  ///
  /// In en, this message translates to:
  /// **'Play slideshow'**
  String get playSlideshowTooltip;

  /// Tooltip for the button that pauses the slideshow.
  ///
  /// In en, this message translates to:
  /// **'Pause slideshow'**
  String get pauseSlideshowTooltip;

  /// Shown in place of an image that could not be decoded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadFailed;

  /// Placeholder when a value (file size, version) is unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownValue;

  /// Placeholder while a value is still loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingValue;

  /// Info panel label for the image position in the folder.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get infoImageLabel;

  /// Info panel value: position of the image in the folder.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String infoImagePosition(int current, int total);

  /// Info panel label for the file type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get infoTypeLabel;

  /// Info panel label for the pixel resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get infoResolutionLabel;

  /// Info panel label for the file size.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get infoFileSizeLabel;

  /// Info panel label for the date the photo was taken.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get infoCapturedLabel;

  /// Info panel label for the file modification date.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get infoModifiedLabel;

  /// Info panel label for the camera model.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get infoCameraLabel;

  /// Info panel label for the lens model.
  ///
  /// In en, this message translates to:
  /// **'Lens'**
  String get infoLensLabel;

  /// Info panel label for the focal length.
  ///
  /// In en, this message translates to:
  /// **'Focal length'**
  String get infoFocalLengthLabel;

  /// Info panel label for the aperture (f-number).
  ///
  /// In en, this message translates to:
  /// **'Aperture'**
  String get infoApertureLabel;

  /// Info panel label for the exposure time.
  ///
  /// In en, this message translates to:
  /// **'Exposure'**
  String get infoExposureLabel;

  /// Info panel label for the ISO sensitivity.
  ///
  /// In en, this message translates to:
  /// **'ISO'**
  String get infoIsoLabel;

  /// Tooltip for the menu that changes how the folder is sorted.
  ///
  /// In en, this message translates to:
  /// **'Sort images'**
  String get sortTooltip;

  /// Sort option: by file name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// Sort option: by date modified.
  ///
  /// In en, this message translates to:
  /// **'Date modified'**
  String get sortByModified;

  /// Sort option: by file size.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get sortBySize;

  /// Sort option: by file type (extension).
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get sortByType;

  /// Sort direction: ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// Sort direction: descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// Title of the keyboard shortcuts dialog and its button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get keyboardShortcutsTitle;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Next / previous image'**
  String get shortcutNextPrevious;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'First / last image'**
  String get shortcutFirstLast;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Play / pause slideshow'**
  String get shortcutPlayPause;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Zoom in / out'**
  String get shortcutZoom;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Actual size (1:1)'**
  String get shortcutActualSize;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Fit to window'**
  String get shortcutFit;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Rotate right / left'**
  String get shortcutRotate;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Show / hide image info'**
  String get shortcutInfo;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Show keyboard shortcuts'**
  String get shortcutHelp;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Close Picavi'**
  String get shortcutClose;

  /// Generic close button label.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// Tooltip for the menu with file actions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActionsTooltip;

  /// Menu item that renames the current image.
  ///
  /// In en, this message translates to:
  /// **'Rename…'**
  String get renameAction;

  /// Title of the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename image'**
  String get renameDialogTitle;

  /// Label of the file name field in the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get renameFieldLabel;

  /// Confirm button in the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameConfirm;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// Rename error: target name is taken.
  ///
  /// In en, this message translates to:
  /// **'A file with that name already exists.'**
  String get renameErrorExists;

  /// Rename error: name has forbidden characters.
  ///
  /// In en, this message translates to:
  /// **'That name can\'t be used. Avoid / \\ : * ? \" < > | and a leading dot.'**
  String get renameErrorInvalid;

  /// Rename error: generic failure.
  ///
  /// In en, this message translates to:
  /// **'The image couldn\'t be renamed.'**
  String get renameErrorFailed;

  /// Menu item: copy images to another folder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copy to folder…} other{Copy {count} images to folder…}}'**
  String copyToFolderAction(int count);

  /// Menu item: move images to another folder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move to folder…} other{Move {count} images to folder…}}'**
  String moveToFolderAction(int count);

  /// Confirm button of the folder picker when copying.
  ///
  /// In en, this message translates to:
  /// **'Copy here'**
  String get copyHerePrompt;

  /// Confirm button of the folder picker when moving.
  ///
  /// In en, this message translates to:
  /// **'Move here'**
  String get moveHerePrompt;

  /// Message in the folder picker for copy/move.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder for the images.'**
  String get chooseDestinationMessage;

  /// Menu item: copy the image to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy image'**
  String get copyImageAction;

  /// Menu item (macOS): show the file in Finder.
  ///
  /// In en, this message translates to:
  /// **'Show in Finder'**
  String get revealInFinderAction;

  /// Menu item (Windows): show the file in File Explorer.
  ///
  /// In en, this message translates to:
  /// **'Show in File Explorer'**
  String get revealInExplorerAction;

  /// Menu item (Linux): show the file in the file manager.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get revealInFileManagerAction;

  /// Menu item: open the image in another app.
  ///
  /// In en, this message translates to:
  /// **'Open with…'**
  String get openWithAction;

  /// Confirm button of the app picker for Open with.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openWithPrompt;

  /// Name of the macOS/Linux trash, used inside other messages.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashName;

  /// Name of the Windows Recycle Bin, used inside other messages.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBinName;

  /// Menu item: move images to the trash. {bin} is trashName or recycleBinName.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move to {bin}} other{Move {count} images to {bin}}}'**
  String moveToTrashAction(int count, String bin);

  /// Title of the confirmation before moving to the trash.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move this image to the {bin}?} other{Move {count} images to the {bin}?}}'**
  String trashConfirmTitle(int count, String bin);

  /// Body of the confirmation before moving to the trash.
  ///
  /// In en, this message translates to:
  /// **'You can restore images from the {bin}.'**
  String trashConfirmMessage(String bin);

  /// Snackbar after moving images to the trash.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 image to the {bin}} other{Moved {count} images to the {bin}}}'**
  String movedToTrashNotice(int count, String bin);

  /// Snackbar when some images could not be moved to the trash.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 image couldn\'t be moved to the {bin}} other{{count} images couldn\'t be moved to the {bin}}}'**
  String trashFailedNotice(int count, String bin);

  /// Snackbar after copying images to a folder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copied 1 image} other{Copied {count} images}}'**
  String copiedNotice(int count);

  /// Snackbar after moving images to a folder.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 image} other{Moved {count} images}}'**
  String movedNotice(int count);

  /// Snackbar when some images could not be copied.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 image couldn\'t be copied} other{{count} images couldn\'t be copied}}'**
  String copyFailedNotice(int count);

  /// Snackbar when some images could not be moved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 image couldn\'t be moved} other{{count} images couldn\'t be moved}}'**
  String moveFailedNotice(int count);

  /// Snackbar after copying the image to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Image copied to the clipboard'**
  String get imageCopiedNotice;

  /// Snackbar when copying to the clipboard failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy the image to the clipboard'**
  String get clipboardFailedNotice;

  /// Snackbar when showing the file in its folder failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t show the image in its folder'**
  String get revealFailedNotice;

  /// Snackbar when opening in another app failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the image in that app'**
  String get openWithFailedNotice;

  /// Label showing how many images are selected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectionCount(int count);

  /// Tooltip for the button that clears the selection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelectionTooltip;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Rename image'**
  String get shortcutRename;

  /// Shortcut description. {bin} is trashName or recycleBinName.
  ///
  /// In en, this message translates to:
  /// **'Move to {bin}'**
  String shortcutTrash(String bin);

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Copy image'**
  String get shortcutCopyImage;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Select all images'**
  String get shortcutSelectAll;

  /// Shortcut description for modifier-clicking thumbnails.
  ///
  /// In en, this message translates to:
  /// **'Add to / extend selection'**
  String get shortcutSelect;

  /// Shortcut description for Esc.
  ///
  /// In en, this message translates to:
  /// **'Clear selection, leave full screen, or close'**
  String get shortcutEscape;

  /// Word for a mouse click, shown on keycaps like "⌘ Click".
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get clickLabel;

  /// Settings section heading for slideshow options.
  ///
  /// In en, this message translates to:
  /// **'Slideshow'**
  String get slideshowSectionTitle;

  /// Setting: how long each image is shown.
  ///
  /// In en, this message translates to:
  /// **'Time per image'**
  String get slideshowIntervalTitle;

  /// Value in the time-per-image dropdown.
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{1 second} other{{seconds} seconds}}'**
  String slideshowIntervalValue(int seconds);

  /// Setting: random order.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get slideshowShuffleTitle;

  /// Description of the shuffle setting.
  ///
  /// In en, this message translates to:
  /// **'Show the images in a random order.'**
  String get slideshowShuffleDescription;

  /// Setting: repeat the slideshow.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get slideshowLoopTitle;

  /// Description of the loop setting.
  ///
  /// In en, this message translates to:
  /// **'Start over after the last image.'**
  String get slideshowLoopDescription;

  /// Setting: go full screen for slideshows.
  ///
  /// In en, this message translates to:
  /// **'Full screen during slideshow'**
  String get slideshowFullScreenTitle;

  /// Description of the slideshow full screen setting.
  ///
  /// In en, this message translates to:
  /// **'Switch to full screen when a slideshow starts.'**
  String get slideshowFullScreenDescription;

  /// Tooltip for the button that enters full screen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get enterFullScreenTooltip;

  /// Tooltip for the button that leaves full screen.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get exitFullScreenTooltip;

  /// Tooltip for the button that zooms the image to fill the window.
  ///
  /// In en, this message translates to:
  /// **'Fill window'**
  String get fillWindowTooltip;

  /// Tooltip for the button that fits the whole image in the window.
  ///
  /// In en, this message translates to:
  /// **'Fit to window'**
  String get fitWindowTooltip;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Full screen on / off'**
  String get shortcutFullScreen;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Fit / fill window'**
  String get shortcutFitFill;

  /// Shown while files are dragged over the window.
  ///
  /// In en, this message translates to:
  /// **'Drop to open'**
  String get dropToOpen;

  /// Tooltip for the button that writes the current rotation into the file.
  ///
  /// In en, this message translates to:
  /// **'Save rotation'**
  String get saveRotationTooltip;

  /// Snackbar after the rotation was written to the file.
  ///
  /// In en, this message translates to:
  /// **'Rotation saved'**
  String get rotationSavedNotice;

  /// Snackbar when the format cannot be rotated on disk. {format} is like PNG or WEBP.
  ///
  /// In en, this message translates to:
  /// **'Rotation can\'t be saved for {format} images yet'**
  String rotationUnsupportedNotice(String format);

  /// Snackbar when writing the rotation failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the rotation. The original file is unchanged.'**
  String get rotationSaveFailedNotice;

  /// Shortcut description.
  ///
  /// In en, this message translates to:
  /// **'Save rotation to the file'**
  String get shortcutSaveRotation;

  /// Tooltip for the button that opens the editor.
  ///
  /// In en, this message translates to:
  /// **'Edit image'**
  String get editImageTooltip;

  /// Tooltip on the edit button for a file type the editor cannot open.
  ///
  /// In en, this message translates to:
  /// **'This file type can\'t be edited'**
  String get editUnavailableTooltip;

  /// Keyboard shortcuts list: open the editor.
  ///
  /// In en, this message translates to:
  /// **'Edit image'**
  String get shortcutEdit;

  /// Editor tab with crop, straighten, red-eye and one-click fixes.
  ///
  /// In en, this message translates to:
  /// **'Basic fixes'**
  String get editorTabFixes;

  /// Editor tab with light and colour sliders.
  ///
  /// In en, this message translates to:
  /// **'Tuning'**
  String get editorTabTuning;

  /// Editor tab with effects such as sepia.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get editorTabEffects;

  /// Editor tool: crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get editorCrop;

  /// Editor tool: straighten (rotate by a small angle).
  ///
  /// In en, this message translates to:
  /// **'Straighten'**
  String get editorStraighten;

  /// Editor tool: red-eye removal.
  ///
  /// In en, this message translates to:
  /// **'Red-eye'**
  String get editorRedEye;

  /// One-click fix that improves contrast and colour automatically.
  ///
  /// In en, this message translates to:
  /// **'I\'m Feeling Lucky'**
  String get editorFeelingLucky;

  /// One-click fix: automatic contrast.
  ///
  /// In en, this message translates to:
  /// **'Auto contrast'**
  String get editorAutoContrast;

  /// One-click fix: automatic colour balance.
  ///
  /// In en, this message translates to:
  /// **'Auto color'**
  String get editorAutoColor;

  /// Tuning slider that brightens dark areas.
  ///
  /// In en, this message translates to:
  /// **'Fill light'**
  String get editorTuneFillLight;

  /// Tuning slider for highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get editorTuneHighlights;

  /// Tuning slider that deepens shadows.
  ///
  /// In en, this message translates to:
  /// **'Shadows'**
  String get editorTuneShadows;

  /// Tuning slider from cooler to warmer colours.
  ///
  /// In en, this message translates to:
  /// **'Color temperature'**
  String get editorTuneTemperature;

  /// Button that applies the current tool.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get editorApply;

  /// Button that resets the tuning sliders.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get editorReset;

  /// Button that removes the red-eye spots placed so far.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get editorClear;

  /// Slider label for how strong an effect is.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get editorStrength;

  /// Effect: black and white.
  ///
  /// In en, this message translates to:
  /// **'Black & white'**
  String get effectBlackAndWhite;

  /// Effect: sepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get effectSepia;

  /// Effect: warmer colours.
  ///
  /// In en, this message translates to:
  /// **'Warmify'**
  String get effectWarmify;

  /// Effect: colour saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get effectSaturation;

  /// Effect: sharpen.
  ///
  /// In en, this message translates to:
  /// **'Sharpen'**
  String get effectSharpen;

  /// Effect: soft focus around the edges.
  ///
  /// In en, this message translates to:
  /// **'Soft focus'**
  String get effectSoftFocus;

  /// Effect: glow.
  ///
  /// In en, this message translates to:
  /// **'Glow'**
  String get effectGlow;

  /// Effect: film grain.
  ///
  /// In en, this message translates to:
  /// **'Film grain'**
  String get effectFilmGrain;

  /// Effect: darker corners.
  ///
  /// In en, this message translates to:
  /// **'Vignette'**
  String get effectVignette;

  /// Hint in the crop tool.
  ///
  /// In en, this message translates to:
  /// **'Drag the frame or its corners to choose what to keep.'**
  String get editorCropHint;

  /// Button that swaps the crop between portrait and landscape.
  ///
  /// In en, this message translates to:
  /// **'Portrait / landscape'**
  String get editorCropSwapOrientation;

  /// Crop shape: any shape.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get editorCropFree;

  /// Crop shape: same as the photo.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get editorCropOriginal;

  /// Crop shape: square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get editorCropSquare;

  /// Crop shape: 4×6 print.
  ///
  /// In en, this message translates to:
  /// **'4 × 6'**
  String get editorCrop4x6;

  /// Crop shape: 5×7 print.
  ///
  /// In en, this message translates to:
  /// **'5 × 7'**
  String get editorCrop5x7;

  /// Crop shape: 8×10 print.
  ///
  /// In en, this message translates to:
  /// **'8 × 10'**
  String get editorCrop8x10;

  /// Crop shape: widescreen.
  ///
  /// In en, this message translates to:
  /// **'16:9'**
  String get editorCrop16x9;

  /// Hint in the straighten tool.
  ///
  /// In en, this message translates to:
  /// **'Move the slider until the horizon lines up with the grid.'**
  String get editorStraightenHint;

  /// Straighten angle in degrees.
  ///
  /// In en, this message translates to:
  /// **'{degrees}°'**
  String editorDegrees(String degrees);

  /// Hint in the red-eye tool.
  ///
  /// In en, this message translates to:
  /// **'Click the centre of each red eye. Change the size first if the circle is too small or too big.'**
  String get editorRedEyeHint;

  /// Slider for the size of red-eye circles.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get editorRedEyeSize;

  /// Editor toolbar: undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get editorUndo;

  /// Editor toolbar: redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get editorRedo;

  /// Editor toolbar: remove every edit.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get editorRevert;

  /// Editor toolbar: save an edited copy.
  ///
  /// In en, this message translates to:
  /// **'Export…'**
  String get editorExport;

  /// Editor toolbar: close the editor.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editorDone;

  /// Shown when the editor cannot decode the image.
  ///
  /// In en, this message translates to:
  /// **'This image can\'t be opened for editing.'**
  String get editorLoadFailed;

  /// Shown when the edits file next to the image cannot be written.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your edits in this folder. They\'ll be lost when you close Picavi.'**
  String get editorSaveFailed;

  /// Shown after an edited copy was written.
  ///
  /// In en, this message translates to:
  /// **'Saved a copy as {name}'**
  String editorExported(String name);

  /// Shown when exporting failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the image'**
  String get editorExportFailed;

  /// Title of the export options dialog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Export image} other{Export {count} images}}'**
  String exportDialogTitle(int count);

  /// Explains that export writes new files.
  ///
  /// In en, this message translates to:
  /// **'Edited copies are saved as new files. Your originals are never changed.'**
  String get exportDialogDescription;

  /// Export dialog: file format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get exportFormatLabel;

  /// Export format: JPEG.
  ///
  /// In en, this message translates to:
  /// **'JPEG'**
  String get exportFormatJpeg;

  /// Export format: PNG.
  ///
  /// In en, this message translates to:
  /// **'PNG'**
  String get exportFormatPng;

  /// Export dialog: image size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get exportSizeLabel;

  /// Export size: keep the full size.
  ///
  /// In en, this message translates to:
  /// **'Full size'**
  String get exportSizeOriginal;

  /// Export size: longest side in pixels.
  ///
  /// In en, this message translates to:
  /// **'{size} px on the long side'**
  String exportSizePixels(int size);

  /// Export dialog: JPEG quality.
  ///
  /// In en, this message translates to:
  /// **'Quality: {quality}'**
  String exportQualityLabel(int quality);

  /// Export dialog button that continues to the folder picker.
  ///
  /// In en, this message translates to:
  /// **'Choose folder…'**
  String get exportChooseFolder;

  /// Viewer actions menu: export edited copies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Export…} other{Export {count} images…}}'**
  String exportAction(int count);

  /// Viewer notice after exporting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 image} other{Exported {count} images}}'**
  String exportedNotice(int count);

  /// Viewer notice when some exports failed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 image couldn\'t be exported} other{{count} images couldn\'t be exported}}'**
  String exportFailedNotice(int count);

  /// Viewer actions submenu with one-click edits for the selected images.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Quick fix} other{Quick fix {count} images}}'**
  String quickFixMenu(int count);

  /// Quick-fix menu item that removes all edits.
  ///
  /// In en, this message translates to:
  /// **'Remove edits'**
  String get removeEditsAction;

  /// Viewer notice after a quick fix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Edited 1 image} other{Edited {count} images}}'**
  String quickFixAppliedNotice(int count);

  /// Viewer notice when a quick fix failed for some images.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 image couldn\'t be edited} other{{count} images couldn\'t be edited}}'**
  String quickFixFailedNotice(int count);

  /// Viewer notice after removing edits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Removed the edits from 1 image} other{Removed the edits from {count} images}}'**
  String editsRemovedNotice(int count);

  /// Viewer notice: the rotation of an edited image was saved with its other edits instead of rewriting the file.
  ///
  /// In en, this message translates to:
  /// **'Rotation saved with this image\'s edits'**
  String get rotationAddedToEditsNotice;

  /// Tooltip on the small mark of an image that has edits.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get editedBadgeTooltip;

  /// Tooltip on the star button of an unstarred photo.
  ///
  /// In en, this message translates to:
  /// **'Star (S)'**
  String get starTooltip;

  /// Tooltip on the star button of a starred photo.
  ///
  /// In en, this message translates to:
  /// **'Remove star (S)'**
  String get unstarTooltip;

  /// Tooltip on the star mark of a starred thumbnail.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get starredBadgeTooltip;

  /// Keyboard shortcuts list: star or unstar.
  ///
  /// In en, this message translates to:
  /// **'Star / remove star'**
  String get shortcutStar;

  /// Menu item that edits the caption and tags.
  ///
  /// In en, this message translates to:
  /// **'Caption and tags…'**
  String get captionTagsAction;

  /// Title of the caption and tags dialog.
  ///
  /// In en, this message translates to:
  /// **'Caption and tags'**
  String get captionTagsTitle;

  /// Label for a photo caption.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionLabel;

  /// Label for a photo's tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// Helper text under the tags field.
  ///
  /// In en, this message translates to:
  /// **'Separate tags with commas'**
  String get tagsHint;

  /// Generic save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// Menu item that hides photos from the library.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Hide from library} other{Hide {count} images from library}}'**
  String hideFromLibraryAction(int count);

  /// Menu item that shows hidden photos in the library again.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show in library} other{Show {count} images in library}}'**
  String showInLibraryAction(int count);

  /// Shown when a star, caption or tags could not be saved.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the star, caption or tags in this folder'**
  String get photoInfoSaveFailedNotice;

  /// Name of the library (all photos in watched folders).
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Keyboard shortcuts list: open the library.
  ///
  /// In en, this message translates to:
  /// **'Open the library'**
  String get shortcutLibrary;

  /// Library sidebar: every photo, by month.
  ///
  /// In en, this message translates to:
  /// **'All photos'**
  String get libraryAllPhotos;

  /// Library sidebar: starred photos.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get libraryStarred;

  /// Library sidebar heading for albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get libraryAlbums;

  /// Library sidebar heading for folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get libraryFolders;

  /// Shown under Albums when there are none.
  ///
  /// In en, this message translates to:
  /// **'No albums yet'**
  String get libraryNoAlbums;

  /// Button and dialog title: create an album.
  ///
  /// In en, this message translates to:
  /// **'New album'**
  String get libraryNewAlbum;

  /// Field label for an album name.
  ///
  /// In en, this message translates to:
  /// **'Album name'**
  String get libraryAlbumName;

  /// Button that creates something.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get libraryCreate;

  /// Menu item and dialog title: rename an album.
  ///
  /// In en, this message translates to:
  /// **'Rename album'**
  String get libraryRenameAlbum;

  /// Menu item: delete an album.
  ///
  /// In en, this message translates to:
  /// **'Delete album'**
  String get libraryDeleteAlbum;

  /// Confirmation title before deleting an album.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String libraryDeleteAlbumTitle(String name);

  /// Explains that deleting an album keeps the photos.
  ///
  /// In en, this message translates to:
  /// **'The photos in it stay where they are; only the album goes.'**
  String get libraryDeleteAlbumMessage;

  /// Notice after creating an album.
  ///
  /// In en, this message translates to:
  /// **'Created album “{name}”'**
  String libraryAlbumCreated(String name);

  /// Button that adds the selected photos to an album.
  ///
  /// In en, this message translates to:
  /// **'Add to album'**
  String get libraryAddToAlbum;

  /// Button that removes the selected photos from the open album.
  ///
  /// In en, this message translates to:
  /// **'Remove from album'**
  String get libraryRemoveFromAlbum;

  /// Notice after adding photos to an album.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 photo to the album} other{Added {count} photos to the album}}'**
  String libraryAddedToAlbum(int count);

  /// Notice after removing photos from an album.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Removed 1 photo from the album} other{Removed {count} photos from the album}}'**
  String libraryRemovedFromAlbum(int count);

  /// Button that adds a watched folder to the library.
  ///
  /// In en, this message translates to:
  /// **'Add folder…'**
  String get libraryAddFolder;

  /// Menu item that stops watching a folder.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get libraryRemoveFolder;

  /// Confirmation title before removing a watched folder.
  ///
  /// In en, this message translates to:
  /// **'Remove this folder from the library?'**
  String get libraryRemoveFolderTitle;

  /// Explains that removing a folder keeps the files.
  ///
  /// In en, this message translates to:
  /// **'Picavi will stop showing photos from {path}. Nothing on disk is changed.'**
  String libraryRemoveFolderMessage(String path);

  /// Menu item that hides a folder from the library.
  ///
  /// In en, this message translates to:
  /// **'Hide folder'**
  String get libraryHideFolder;

  /// Menu item that shows a hidden folder again.
  ///
  /// In en, this message translates to:
  /// **'Show folder'**
  String get libraryShowFolder;

  /// Menu item that opens a folder in the file manager.
  ///
  /// In en, this message translates to:
  /// **'Show in file manager'**
  String get libraryRevealFolder;

  /// Tooltip: also show hidden photos and folders.
  ///
  /// In en, this message translates to:
  /// **'Show hidden photos'**
  String get libraryShowHidden;

  /// Tooltip: stop showing hidden photos and folders.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show hidden photos'**
  String get libraryHideHidden;

  /// Tooltip: scan the watched folders again.
  ///
  /// In en, this message translates to:
  /// **'Scan folders again'**
  String get libraryRescan;

  /// Tooltip on the thumbnail size slider.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail size'**
  String get libraryThumbnailSize;

  /// Hint in the library search box.
  ///
  /// In en, this message translates to:
  /// **'Search names, captions, tags, dates…'**
  String get librarySearchHint;

  /// Tooltip: clear the search box.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get libraryClearSearch;

  /// Library empty state title.
  ///
  /// In en, this message translates to:
  /// **'Build your photo library'**
  String get libraryEmptyTitle;

  /// Library empty state explanation.
  ///
  /// In en, this message translates to:
  /// **'Add the folders where you keep photos. Picavi finds every photo inside them, sorts them by month, and keeps the list up to date. Your files stay where they are.'**
  String get libraryEmptyMessage;

  /// Shown while the first scan has found photos but none are listed yet.
  ///
  /// In en, this message translates to:
  /// **'Looking for photos… {count} found'**
  String libraryScanning(int count);

  /// Shown when a search finds nothing.
  ///
  /// In en, this message translates to:
  /// **'No photos match your search'**
  String get libraryNoMatches;

  /// Shown when the chosen folder, album or filter has no photos.
  ///
  /// In en, this message translates to:
  /// **'No photos here'**
  String get libraryNothingHere;

  /// Number of photos in a month section.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String libraryPhotoCount(int count);

  /// Selection bar button: star photos.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get libraryStar;

  /// Selection bar button: remove stars.
  ///
  /// In en, this message translates to:
  /// **'Remove star'**
  String get libraryUnstar;

  /// Title of the duplicate finder.
  ///
  /// In en, this message translates to:
  /// **'Find duplicates'**
  String get duplicatesTitle;

  /// Shown while comparing files.
  ///
  /// In en, this message translates to:
  /// **'Comparing photos…'**
  String get duplicatesSearching;

  /// Shown when no duplicates were found.
  ///
  /// In en, this message translates to:
  /// **'No duplicate photos found'**
  String get duplicatesNone;

  /// Explains the list of duplicate groups.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set of identical photos. Keep one copy and move the others to the {bin}.} other{{count} sets of identical photos. Keep one copy of each and move the others to the {bin}.}}'**
  String duplicatesSummary(int count, String bin);

  /// Button: keep this copy, move the other copies to the Trash.
  ///
  /// In en, this message translates to:
  /// **'Keep only this'**
  String get duplicatesKeepOnly;

  /// Folder picker message when adding a library folder.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder that holds photos. Its sub-folders are included.'**
  String get libraryPickFolderMessage;

  /// Shown when the library database cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the library'**
  String get libraryOpenFailed;

  /// Menu item / button that opens the system share menu.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Share…} other{Share {count} images…}}'**
  String shareAction(int count);

  /// Shown when the share menu could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the share menu'**
  String get shareFailedNotice;

  /// Title/tooltip: import photos from a camera or card.
  ///
  /// In en, this message translates to:
  /// **'Import photos'**
  String get importTitle;

  /// Sidebar heading for cameras and memory cards.
  ///
  /// In en, this message translates to:
  /// **'Cameras and cards'**
  String get importDevices;

  /// Tooltip: look for cameras and cards again.
  ///
  /// In en, this message translates to:
  /// **'Look for cameras and cards'**
  String get importRefreshDevices;

  /// Shown when no camera or card is connected.
  ///
  /// In en, this message translates to:
  /// **'None connected. Plug in a camera or insert a memory card.'**
  String get importNoDevices;

  /// Import source: any folder.
  ///
  /// In en, this message translates to:
  /// **'From a folder…'**
  String get importFromFolder;

  /// Shown before a source is chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose a camera, card or folder on the left. Photos are copied into dated folders; nothing on the card is changed.'**
  String get importChooseSource;

  /// Shows where photos will be copied.
  ///
  /// In en, this message translates to:
  /// **'Into {folder} / year / date'**
  String importDestination(String folder);

  /// Button that changes the import folder.
  ///
  /// In en, this message translates to:
  /// **'Change…'**
  String get importChangeDestination;

  /// Shown when the source has no photos.
  ///
  /// In en, this message translates to:
  /// **'No photos found here'**
  String get importNothingFound;

  /// Label on photos imported before.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importAlreadyImported;

  /// Selection count in the import screen.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String importSelectedCount(int selected, int total);

  /// Button: select photos not imported yet.
  ///
  /// In en, this message translates to:
  /// **'Select new'**
  String get importSelectNew;

  /// Button: select nothing.
  ///
  /// In en, this message translates to:
  /// **'Select none'**
  String get importSelectNone;

  /// Button that starts importing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 photo} other{Import {count} photos}}'**
  String importButton(int count);

  /// Progress while importing.
  ///
  /// In en, this message translates to:
  /// **'Copying {done} of {total}…'**
  String importProgress(int done, int total);

  /// Summary after importing.
  ///
  /// In en, this message translates to:
  /// **'Imported {copied}, skipped {skipped} already there, {failed} failed'**
  String importDone(int copied, int skipped, int failed);

  /// Viewer menu item: make a collage of the selection or folder.
  ///
  /// In en, this message translates to:
  /// **'Make a collage…'**
  String get collageAction;

  /// Library selection bar button: make a collage.
  ///
  /// In en, this message translates to:
  /// **'Collage…'**
  String get collageButton;

  /// Collage dialog title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collage of 1 photo} other{Collage of {count} photos}}'**
  String collageTitle(int count);

  /// Collage layout: justified rows.
  ///
  /// In en, this message translates to:
  /// **'Mosaic'**
  String get collageMosaic;

  /// Collage layout: equal cells.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get collageGrid;

  /// Collage layout: contact sheet pages.
  ///
  /// In en, this message translates to:
  /// **'Contact sheet'**
  String get collageContactSheet;

  /// Explains grid and mosaic.
  ///
  /// In en, this message translates to:
  /// **'Mosaic keeps each photo whole; grid crops them to equal cells.'**
  String get collageHint;

  /// Explains contact sheets.
  ///
  /// In en, this message translates to:
  /// **'A4 pages of 35 thumbnails with their file names, ready to print.'**
  String get collageContactSheetHint;

  /// Collage option: gap between photos.
  ///
  /// In en, this message translates to:
  /// **'Spacing'**
  String get collageSpacing;

  /// Collage option: background colour.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get collageBackground;

  /// Background colour: white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get collageWhite;

  /// Background colour: black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get collageBlack;

  /// Background colour: dark grey.
  ///
  /// In en, this message translates to:
  /// **'Charcoal'**
  String get collageCharcoal;

  /// Collage size option.
  ///
  /// In en, this message translates to:
  /// **'Widescreen ({width} × {height})'**
  String collageSizeWide(int width, int height);

  /// Collage size option.
  ///
  /// In en, this message translates to:
  /// **'Large 3:2 ({width} × {height})'**
  String collageSizeLarge(int width, int height);

  /// Collage size option.
  ///
  /// In en, this message translates to:
  /// **'Square ({width} × {height})'**
  String collageSizeSquare(int width, int height);

  /// Collage size option.
  ///
  /// In en, this message translates to:
  /// **'Portrait 2:3 ({width} × {height})'**
  String collageSizePortrait(int width, int height);

  /// Shown while the collage is made.
  ///
  /// In en, this message translates to:
  /// **'Making the collage…'**
  String get collageWorking;

  /// Notice after a collage was saved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved {name}} other{Saved {count} pages, starting with {name}}}'**
  String collageSaved(int count, String name);

  /// Notice when the collage could not be made.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t make the collage'**
  String get collageFailed;

  /// File name (without extension) for a saved collage.
  ///
  /// In en, this message translates to:
  /// **'Collage'**
  String get collageFileName;

  /// File name (without extension) for saved contact sheets.
  ///
  /// In en, this message translates to:
  /// **'Contact sheet'**
  String get contactSheetFileName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'hi',
    'mr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
