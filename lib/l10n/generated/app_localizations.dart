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
