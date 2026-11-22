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
