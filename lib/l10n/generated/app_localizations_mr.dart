// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'Picavi';

  @override
  String get emptyStateTitle => 'Picavi';

  @override
  String get emptyStateDescription =>
      'हलका आणि अनावश्यक गोष्टींशिवाय प्रतिमा दर्शक.';

  @override
  String get openImage => 'प्रतिमा उघडा';

  @override
  String get tipsText =>
      'सूचना: पॅन करण्यासाठी माऊस किंवा ट्रॅकपॅडने ड्रॅग करा, झूम करण्यासाठी पिंच किंवा स्क्रोल करा आणि फोल्डरमध्ये फिरण्यासाठी ← / → वापरा.';

  @override
  String get folderFallback => 'फोल्डर';

  @override
  String viewerPosition(Object directoryName, int current, int total) {
    return '$directoryName • $current / $total';
  }

  @override
  String get folderAccessDenied =>
      'फोल्डरची परवानगी दिली गेली नाही, त्यामुळे फक्त निवडलेली प्रतिमा दाखवता येईल.';

  @override
  String get folderAccessRequestFailed =>
      'फोल्डर परवानगीची विनंती करता आली नाही. फक्त निवडलेली प्रतिमा दाखवली जाईल.';

  @override
  String get nativeOpenViewerPrompt => 'दर्शक उघडा';

  @override
  String get nativeGrantFolderAccessPrompt => 'फोल्डर परवानगी द्या';

  @override
  String get nativeGrantFolderAccessMessage =>
      'या फोल्डरमधील शेजारील प्रतिमा वाचण्यासाठी Picavi ला परवानगी द्या.';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get defaultViewerTitle => 'डीफॉल्ट दर्शक';

  @override
  String get restoreLastOpenedImageTitle =>
      'अॅप सुरू होताना शेवटची उघडलेली प्रतिमा पुन्हा उघडा';

  @override
  String get restoreLastOpenedImageDescription =>
      'जेव्हा Picavi कोणतीही स्पष्ट फाइल न देता सुरू होते, तेव्हा शेवटची पाहिलेली प्रतिमा पुन्हा उघडा; प्रतिमा उपलब्ध नसेल तर तिचा फोल्डर उघडा.';

  @override
  String get showRecentFoldersTitle => 'सुरू करताना अलीकडील फोल्डर दाखवा';

  @override
  String get showRecentFoldersDescription =>
      'सुरुवातीच्या स्क्रीनवर अलीकडे उघडलेले फोल्डर प्रतिमेच्या पूर्वावलोकनासह दाखवा.';

  @override
  String get recentFoldersTitle => 'अलीकडील फोल्डर';

  @override
  String recentFolderImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा',
      one: '1 प्रतिमा',
      zero: 'प्रतिमा नाहीत',
    );
    return '$_temp0';
  }

  @override
  String get recentFolderRemoveTooltip => 'अलीकडील मधून काढा';

  @override
  String get versionTitle => 'आवृत्ती';

  @override
  String get defaultViewerActionSet => 'डीफॉल्ट दर्शक म्हणून सेट करा';

  @override
  String get defaultViewerActionOpenSystemSettings =>
      'डीफॉल्ट अॅप्स सेटिंग्ज उघडा';

  @override
  String get defaultViewerPromptTitle =>
      'तुम्हाला Picavi हा तुमचा डीफॉल्ट प्रतिमा दर्शक बनवायचा आहे का?';

  @override
  String get defaultViewerPromptMessage =>
      'तुम्ही Finder, File Explorer किंवा तुमच्या फाइल मॅनेजरमधून थेट Picavi मध्ये प्रतिमा उघडू शकता. हे तुम्ही नंतर सेटिंग्जमधून बदलू शकता.';

  @override
  String get notNowLabel => 'आत्ता नाही';

  @override
  String get defaultViewerHintTitle => 'Picavi हा डीफॉल्ट प्रतिमा दर्शक नाही.';

  @override
  String get defaultViewerChecking => 'तपासले जात आहे…';

  @override
  String get defaultViewerStatusDefault =>
      'समर्थित स्वरूपांसाठी Picavi हा सध्या तुमचा डीफॉल्ट प्रतिमा दर्शक आहे.';

  @override
  String get defaultViewerStatusNotDefault =>
      'Picavi अजून तुमचा डीफॉल्ट प्रतिमा दर्शक नाही.';

  @override
  String get defaultViewerGuidedHelp =>
      'उर्वरित टप्प्यांमध्ये तुमची ऑपरेटिंग सिस्टीम तुम्हाला मार्गदर्शन करेल.';

  @override
  String get defaultViewerSetSuccess =>
      'समर्थित स्वरूपांसाठी Picavi आता डीफॉल्ट प्रतिमा दर्शक आहे.';

  @override
  String get defaultViewerFlowOpened =>
      'सिस्टममधील डीफॉल्ट अॅप्स सेटिंग्ज उघडल्या गेल्या.';

  @override
  String get defaultViewerSetFailed =>
      'Picavi ला आपोआप डीफॉल्ट दर्शक म्हणून सेट करता आले नाही.';

  @override
  String get defaultViewerUnsupported =>
      'या प्लॅटफॉर्मवर डीफॉल्ट दर्शक सेटअप उपलब्ध नाही.';

  @override
  String get zoomOutTooltip => 'झूम आउट';

  @override
  String get zoomInTooltip => 'झूम इन';

  @override
  String get actualSizeTooltip => 'मूळ आकार (1:1)';

  @override
  String get rotateLeftTooltip => 'डावीकडे फिरवा';

  @override
  String get rotateRightTooltip => 'उजवीकडे फिरवा';

  @override
  String get showImageInfoTooltip => 'प्रतिमेची माहिती दाखवा';

  @override
  String get hideImageInfoTooltip => 'प्रतिमेची माहिती लपवा';

  @override
  String get previousImageTooltip => 'मागील प्रतिमा';

  @override
  String get nextImageTooltip => 'पुढील प्रतिमा';

  @override
  String get playSlideshowTooltip => 'स्लाइडशो सुरू करा';

  @override
  String get pauseSlideshowTooltip => 'स्लाइडशो थांबवा';

  @override
  String get imageLoadFailed => 'प्रतिमा लोड करता आली नाही';

  @override
  String get unknownValue => 'अज्ञात';

  @override
  String get loadingValue => 'लोड होत आहे…';

  @override
  String get infoImageLabel => 'प्रतिमा';

  @override
  String infoImagePosition(int current, int total) {
    return '$total पैकी $current';
  }

  @override
  String get infoTypeLabel => 'प्रकार';

  @override
  String get infoResolutionLabel => 'रिझोल्यूशन';

  @override
  String get infoFileSizeLabel => 'फाइल आकार';

  @override
  String get infoCapturedLabel => 'काढली';

  @override
  String get infoModifiedLabel => 'बदलली';

  @override
  String get infoCameraLabel => 'कॅमेरा';

  @override
  String get infoLensLabel => 'लेन्स';

  @override
  String get infoFocalLengthLabel => 'फोकल लांबी';

  @override
  String get infoApertureLabel => 'अपर्चर';

  @override
  String get infoExposureLabel => 'एक्सपोजर';

  @override
  String get infoIsoLabel => 'ISO';

  @override
  String get sortTooltip => 'प्रतिमा क्रमवार लावा';

  @override
  String get sortByName => 'नाव';

  @override
  String get sortByModified => 'बदलाची तारीख';

  @override
  String get sortBySize => 'फाइल आकार';

  @override
  String get sortByType => 'फाइल प्रकार';

  @override
  String get sortAscending => 'चढत्या क्रमाने';

  @override
  String get sortDescending => 'उतरत्या क्रमाने';

  @override
  String get keyboardShortcutsTitle => 'कीबोर्ड शॉर्टकट';

  @override
  String get shortcutNextPrevious => 'पुढील / मागील प्रतिमा';

  @override
  String get shortcutFirstLast => 'पहिली / शेवटची प्रतिमा';

  @override
  String get shortcutPlayPause => 'स्लाइडशो सुरू करा / थांबवा';

  @override
  String get shortcutZoom => 'झूम इन / आउट';

  @override
  String get shortcutActualSize => 'मूळ आकार (1:1)';

  @override
  String get shortcutFit => 'विंडोमध्ये बसवा';

  @override
  String get shortcutRotate => 'उजवीकडे / डावीकडे फिरवा';

  @override
  String get shortcutInfo => 'प्रतिमेची माहिती दाखवा / लपवा';

  @override
  String get shortcutHelp => 'कीबोर्ड शॉर्टकट दाखवा';

  @override
  String get shortcutClose => 'Picavi बंद करा';

  @override
  String get closeLabel => 'बंद करा';

  @override
  String get moreActionsTooltip => 'अधिक क्रिया';

  @override
  String get renameAction => 'नाव बदला…';

  @override
  String get renameDialogTitle => 'प्रतिमेचे नाव बदला';

  @override
  String get renameFieldLabel => 'फाइलचे नाव';

  @override
  String get renameConfirm => 'नाव बदला';

  @override
  String get cancelLabel => 'रद्द करा';

  @override
  String get renameErrorExists => 'या नावाची फाइल आधीच आहे.';

  @override
  String get renameErrorInvalid =>
      'हे नाव वापरता येणार नाही. / \\ : * ? \" < > | आणि सुरुवातीचा बिंदू टाळा.';

  @override
  String get renameErrorFailed => 'प्रतिमेचे नाव बदलता आले नाही.';

  @override
  String copyToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा फोल्डरमध्ये कॉपी करा…',
      one: 'फोल्डरमध्ये कॉपी करा…',
    );
    return '$_temp0';
  }

  @override
  String moveToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा फोल्डरमध्ये हलवा…',
      one: 'फोल्डरमध्ये हलवा…',
    );
    return '$_temp0';
  }

  @override
  String get copyHerePrompt => 'येथे कॉपी करा';

  @override
  String get moveHerePrompt => 'येथे हलवा';

  @override
  String get chooseDestinationMessage => 'प्रतिमांसाठी फोल्डर निवडा.';

  @override
  String get copyImageAction => 'प्रतिमा कॉपी करा';

  @override
  String get revealInFinderAction => 'Finder मध्ये दाखवा';

  @override
  String get revealInExplorerAction => 'फाइल एक्सप्लोररमध्ये दाखवा';

  @override
  String get revealInFileManagerAction => 'फोल्डरमध्ये दाखवा';

  @override
  String get openWithAction => 'यासह उघडा…';

  @override
  String get openWithPrompt => 'उघडा';

  @override
  String get trashName => 'कचरापेटी';

  @override
  String get recycleBinName => 'रीसायकल बिन';

  @override
  String moveToTrashAction(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा $bin मध्ये हलवा',
      one: '$bin मध्ये हलवा',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmTitle(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा $bin मध्ये हलवायच्या?',
      one: 'ही प्रतिमा $bin मध्ये हलवायची?',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmMessage(String bin) {
    return 'तुम्ही प्रतिमा $bin मधून परत आणू शकता.';
  }

  @override
  String movedToTrashNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा $bin मध्ये हलवल्या',
      one: '1 प्रतिमा $bin मध्ये हलवली',
    );
    return '$_temp0';
  }

  @override
  String trashFailedNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा $bin मध्ये हलवता आल्या नाहीत',
      one: '1 प्रतिमा $bin मध्ये हलवता आली नाही',
    );
    return '$_temp0';
  }

  @override
  String copiedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा कॉपी केल्या',
      one: '1 प्रतिमा कॉपी केली',
    );
    return '$_temp0';
  }

  @override
  String movedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा हलवल्या',
      one: '1 प्रतिमा हलवली',
    );
    return '$_temp0';
  }

  @override
  String copyFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा कॉपी करता आल्या नाहीत',
      one: '1 प्रतिमा कॉपी करता आली नाही',
    );
    return '$_temp0';
  }

  @override
  String moveFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा हलवता आल्या नाहीत',
      one: '1 प्रतिमा हलवता आली नाही',
    );
    return '$_temp0';
  }

  @override
  String get imageCopiedNotice => 'प्रतिमा क्लिपबोर्डवर कॉपी केली';

  @override
  String get clipboardFailedNotice => 'प्रतिमा क्लिपबोर्डवर कॉपी करता आली नाही';

  @override
  String get revealFailedNotice => 'प्रतिमा तिच्या फोल्डरमध्ये दाखवता आली नाही';

  @override
  String get openWithFailedNotice => 'प्रतिमा त्या ॲपमध्ये उघडता आली नाही';

  @override
  String selectionCount(int count) {
    return '$count निवडल्या';
  }

  @override
  String get clearSelectionTooltip => 'निवड काढा';

  @override
  String get shortcutRename => 'प्रतिमेचे नाव बदला';

  @override
  String shortcutTrash(String bin) {
    return '$bin मध्ये हलवा';
  }

  @override
  String get shortcutCopyImage => 'प्रतिमा कॉपी करा';

  @override
  String get shortcutSelectAll => 'सर्व प्रतिमा निवडा';

  @override
  String get shortcutSelect => 'निवडीत जोडा / वाढवा';

  @override
  String get shortcutEscape => 'निवड काढा, पूर्ण स्क्रीन सोडा किंवा बंद करा';

  @override
  String get clickLabel => 'क्लिक';

  @override
  String get slideshowSectionTitle => 'स्लाइडशो';

  @override
  String get slideshowIntervalTitle => 'प्रत्येक प्रतिमेसाठी वेळ';

  @override
  String slideshowIntervalValue(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds सेकंद',
      one: '1 सेकंद',
    );
    return '$_temp0';
  }

  @override
  String get slideshowShuffleTitle => 'शफल';

  @override
  String get slideshowShuffleDescription => 'प्रतिमा यादृच्छिक क्रमाने दाखवा.';

  @override
  String get slideshowLoopTitle => 'पुन्हा सुरू करा';

  @override
  String get slideshowLoopDescription =>
      'शेवटच्या प्रतिमेनंतर पुन्हा सुरू करा.';

  @override
  String get slideshowFullScreenTitle => 'स्लाइडशो दरम्यान पूर्ण स्क्रीन';

  @override
  String get slideshowFullScreenDescription =>
      'स्लाइडशो सुरू झाल्यावर पूर्ण स्क्रीनवर जा.';

  @override
  String get enterFullScreenTooltip => 'पूर्ण स्क्रीन';

  @override
  String get exitFullScreenTooltip => 'पूर्ण स्क्रीनमधून बाहेर पडा';

  @override
  String get fillWindowTooltip => 'विंडो भरा';

  @override
  String get fitWindowTooltip => 'विंडोमध्ये बसवा';

  @override
  String get shortcutFullScreen => 'पूर्ण स्क्रीन चालू / बंद';

  @override
  String get shortcutFitFill => 'विंडोमध्ये बसवा / भरा';

  @override
  String get dropToOpen => 'उघडण्यासाठी सोडा';

  @override
  String get saveRotationTooltip => 'फिरवणे जतन करा';

  @override
  String get rotationSavedNotice => 'फिरवणे जतन केले';

  @override
  String rotationUnsupportedNotice(String format) {
    return '$format प्रतिमांसाठी फिरवणे अजून जतन करता येत नाही';
  }

  @override
  String get rotationSaveFailedNotice =>
      'फिरवणे जतन करता आले नाही. मूळ फाइल बदललेली नाही.';

  @override
  String get shortcutSaveRotation => 'फिरवणे फाइलमध्ये जतन करा';

  @override
  String get editImageTooltip => 'प्रतिमा संपादित करा';

  @override
  String get editUnavailableTooltip => 'हा फाइल प्रकार संपादित करता येत नाही';

  @override
  String get shortcutEdit => 'प्रतिमा संपादित करा';

  @override
  String get editorTabFixes => 'मूलभूत सुधारणा';

  @override
  String get editorTabTuning => 'ट्यूनिंग';

  @override
  String get editorTabEffects => 'इफेक्ट्स';

  @override
  String get editorCrop => 'क्रॉप';

  @override
  String get editorStraighten => 'सरळ करा';

  @override
  String get editorRedEye => 'लाल डोळे';

  @override
  String get editorFeelingLucky => 'नशीब आजमवा';

  @override
  String get editorAutoContrast => 'स्वयं कॉन्ट्रास्ट';

  @override
  String get editorAutoColor => 'स्वयं रंग';

  @override
  String get editorTuneFillLight => 'फिल लाइट';

  @override
  String get editorTuneHighlights => 'हायलाइट्स';

  @override
  String get editorTuneShadows => 'सावल्या';

  @override
  String get editorTuneTemperature => 'रंग तापमान';

  @override
  String get editorApply => 'लागू करा';

  @override
  String get editorReset => 'रीसेट करा';

  @override
  String get editorClear => 'साफ करा';

  @override
  String get editorStrength => 'तीव्रता';

  @override
  String get effectBlackAndWhite => 'कृष्णधवल';

  @override
  String get effectSepia => 'सेपिया';

  @override
  String get effectWarmify => 'उबदार';

  @override
  String get effectSaturation => 'संपृक्तता';

  @override
  String get effectSharpen => 'धार वाढवा';

  @override
  String get effectSoftFocus => 'सॉफ्ट फोकस';

  @override
  String get effectGlow => 'झळाळी';

  @override
  String get effectFilmGrain => 'फिल्म ग्रेन';

  @override
  String get effectVignette => 'व्हिनेट';

  @override
  String get editorCropHint =>
      'काय ठेवायचे ते निवडण्यासाठी चौकट किंवा तिचे कोपरे ओढा.';

  @override
  String get editorCropSwapOrientation => 'पोर्ट्रेट / लँडस्केप';

  @override
  String get editorCropFree => 'मुक्त';

  @override
  String get editorCropOriginal => 'मूळ';

  @override
  String get editorCropSquare => 'चौरस';

  @override
  String get editorCrop4x6 => '4 × 6';

  @override
  String get editorCrop5x7 => '5 × 7';

  @override
  String get editorCrop8x10 => '8 × 10';

  @override
  String get editorCrop16x9 => '16:9';

  @override
  String get editorStraightenHint => 'क्षितिज जाळीशी जुळेपर्यंत स्लायडर सरकवा.';

  @override
  String editorDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get editorRedEyeHint =>
      'प्रत्येक लाल डोळ्याच्या मध्यभागी क्लिक करा. वर्तुळ खूप लहान किंवा मोठे असल्यास आधी आकार बदला.';

  @override
  String get editorRedEyeSize => 'आकार';

  @override
  String get editorUndo => 'पूर्ववत करा';

  @override
  String get editorRedo => 'पुन्हा करा';

  @override
  String get editorRevert => 'मूळ स्थितीत आणा';

  @override
  String get editorExport => 'निर्यात करा…';

  @override
  String get editorDone => 'झाले';

  @override
  String get editorLoadFailed => 'ही प्रतिमा संपादनासाठी उघडता आली नाही.';

  @override
  String get editorSaveFailed =>
      'या फोल्डरमध्ये तुमची संपादने जतन करता आली नाहीत. Picavi बंद केल्यावर ती हरवतील.';

  @override
  String editorExported(String name) {
    return 'प्रत $name म्हणून जतन केली';
  }

  @override
  String get editorExportFailed => 'प्रतिमा निर्यात करता आली नाही';

  @override
  String exportDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा निर्यात करा',
      one: 'प्रतिमा निर्यात करा',
    );
    return '$_temp0';
  }

  @override
  String get exportDialogDescription =>
      'संपादित प्रती नवीन फाइल्स म्हणून जतन होतात. तुमच्या मूळ फाइल्स कधीही बदलत नाहीत.';

  @override
  String get exportFormatLabel => 'फॉरमॅट';

  @override
  String get exportFormatJpeg => 'JPEG';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportSizeLabel => 'आकार';

  @override
  String get exportSizeOriginal => 'पूर्ण आकार';

  @override
  String exportSizePixels(int size) {
    return 'लांब बाजूला $size px';
  }

  @override
  String exportQualityLabel(int quality) {
    return 'गुणवत्ता: $quality';
  }

  @override
  String get exportChooseFolder => 'फोल्डर निवडा…';

  @override
  String exportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा निर्यात करा…',
      one: 'निर्यात करा…',
    );
    return '$_temp0';
  }

  @override
  String exportedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा निर्यात केल्या',
      one: '1 प्रतिमा निर्यात केली',
    );
    return '$_temp0';
  }

  @override
  String exportFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा निर्यात करता आल्या नाहीत',
      one: '1 प्रतिमा निर्यात करता आली नाही',
    );
    return '$_temp0';
  }

  @override
  String quickFixMenu(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमांची झटपट सुधारणा',
      one: 'झटपट सुधारणा',
    );
    return '$_temp0';
  }

  @override
  String get removeEditsAction => 'संपादने काढा';

  @override
  String quickFixAppliedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा संपादित केल्या',
      one: '1 प्रतिमा संपादित केली',
    );
    return '$_temp0';
  }

  @override
  String quickFixFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा संपादित करता आल्या नाहीत',
      one: '1 प्रतिमा संपादित करता आली नाही',
    );
    return '$_temp0';
  }

  @override
  String editsRemovedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमांची संपादने काढली',
      one: '1 प्रतिमेची संपादने काढली',
    );
    return '$_temp0';
  }

  @override
  String get rotationAddedToEditsNotice =>
      'फिरवणे या प्रतिमेच्या संपादनांसह जतन केले';

  @override
  String get editedBadgeTooltip => 'संपादित';

  @override
  String get starTooltip => 'स्टार द्या (S)';

  @override
  String get unstarTooltip => 'स्टार काढा (S)';

  @override
  String get starredBadgeTooltip => 'स्टार दिलेली';

  @override
  String get shortcutStar => 'स्टार द्या / काढा';

  @override
  String get captionTagsAction => 'कॅप्शन आणि टॅग…';

  @override
  String get captionTagsTitle => 'कॅप्शन आणि टॅग';

  @override
  String get captionLabel => 'कॅप्शन';

  @override
  String get tagsLabel => 'टॅग';

  @override
  String get tagsHint => 'टॅग स्वल्पविरामाने वेगळे करा';

  @override
  String get saveLabel => 'जतन करा';

  @override
  String hideFromLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा लायब्ररीतून लपवा',
      one: 'लायब्ररीतून लपवा',
    );
    return '$_temp0';
  }

  @override
  String showInLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा लायब्ररीत दाखवा',
      one: 'लायब्ररीत दाखवा',
    );
    return '$_temp0';
  }

  @override
  String get photoInfoSaveFailedNotice =>
      'या फोल्डरमध्ये स्टार, कॅप्शन किंवा टॅग जतन करता आले नाहीत';

  @override
  String get libraryTitle => 'लायब्ररी';

  @override
  String get shortcutLibrary => 'लायब्ररी उघडा';

  @override
  String get libraryAllPhotos => 'सर्व फोटो';

  @override
  String get libraryStarred => 'स्टार दिलेले';

  @override
  String get libraryAlbums => 'अल्बम';

  @override
  String get libraryFolders => 'फोल्डर';

  @override
  String get libraryNoAlbums => 'अजून अल्बम नाहीत';

  @override
  String get libraryNewAlbum => 'नवीन अल्बम';

  @override
  String get libraryAlbumName => 'अल्बमचे नाव';

  @override
  String get libraryCreate => 'तयार करा';

  @override
  String get libraryRenameAlbum => 'अल्बमचे नाव बदला';

  @override
  String get libraryDeleteAlbum => 'अल्बम हटवा';

  @override
  String libraryDeleteAlbumTitle(String name) {
    return '“$name” हटवायचा?';
  }

  @override
  String get libraryDeleteAlbumMessage =>
      'त्यातील फोटो जागेवरच राहतील; फक्त अल्बम हटेल.';

  @override
  String libraryAlbumCreated(String name) {
    return '“$name” अल्बम तयार केला';
  }

  @override
  String get libraryAddToAlbum => 'अल्बममध्ये जोडा';

  @override
  String get libraryRemoveFromAlbum => 'अल्बममधून काढा';

  @override
  String libraryAddedToAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो अल्बममध्ये जोडले',
      one: '1 फोटो अल्बममध्ये जोडला',
    );
    return '$_temp0';
  }

  @override
  String libraryRemovedFromAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो अल्बममधून काढले',
      one: '1 फोटो अल्बममधून काढला',
    );
    return '$_temp0';
  }

  @override
  String get libraryAddFolder => 'फोल्डर जोडा…';

  @override
  String get libraryRemoveFolder => 'लायब्ररीतून काढा';

  @override
  String get libraryRemoveFolderTitle => 'हा फोल्डर लायब्ररीतून काढायचा?';

  @override
  String libraryRemoveFolderMessage(String path) {
    return 'Picavi $path मधील फोटो दाखवणे थांबवेल. डिस्कवर काहीही बदलणार नाही.';
  }

  @override
  String get libraryHideFolder => 'फोल्डर लपवा';

  @override
  String get libraryShowFolder => 'फोल्डर दाखवा';

  @override
  String get libraryRevealFolder => 'फाइल मॅनेजरमध्ये दाखवा';

  @override
  String get libraryShowHidden => 'लपवलेले फोटो दाखवा';

  @override
  String get libraryHideHidden => 'लपवलेले फोटो दाखवू नका';

  @override
  String get libraryRescan => 'फोल्डर पुन्हा स्कॅन करा';

  @override
  String get libraryThumbnailSize => 'थंबनेलचा आकार';

  @override
  String get librarySearchHint => 'नावे, कॅप्शन, टॅग, तारखा शोधा…';

  @override
  String get libraryClearSearch => 'शोध साफ करा';

  @override
  String get libraryEmptyTitle => 'तुमची फोटो लायब्ररी तयार करा';

  @override
  String get libraryEmptyMessage =>
      'तुम्ही फोटो ठेवता ते फोल्डर जोडा. Picavi त्यातील प्रत्येक फोटो शोधून महिन्यानुसार लावतो आणि यादी अद्ययावत ठेवतो. तुमच्या फाइल्स जागेवरच राहतात.';

  @override
  String libraryScanning(int count) {
    return 'फोटो शोधत आहे… $count सापडले';
  }

  @override
  String get libraryNoMatches => 'तुमच्या शोधाशी जुळणारे फोटो नाहीत';

  @override
  String get libraryNothingHere => 'येथे फोटो नाहीत';

  @override
  String libraryPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो',
      one: '1 फोटो',
    );
    return '$_temp0';
  }

  @override
  String get libraryStar => 'स्टार द्या';

  @override
  String get libraryUnstar => 'स्टार काढा';

  @override
  String get duplicatesTitle => 'डुप्लिकेट शोधा';

  @override
  String get duplicatesSearching => 'फोटोंची तुलना करत आहे…';

  @override
  String get duplicatesNone => 'डुप्लिकेट फोटो सापडले नाहीत';

  @override
  String duplicatesSummary(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'एकसारख्या फोटोंचे $count गट. प्रत्येकाची एक प्रत ठेवा आणि बाकी $bin मध्ये हलवा.',
      one: 'एकसारख्या फोटोंचा 1 गट. एक प्रत ठेवा आणि बाकी $bin मध्ये हलवा.',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesKeepOnly => 'फक्त हे ठेवा';

  @override
  String get libraryPickFolderMessage =>
      'फोटो असलेला फोल्डर निवडा. त्याचे उप-फोल्डरही समाविष्ट होतील.';

  @override
  String get libraryOpenFailed => 'लायब्ररी उघडता आली नाही';

  @override
  String shareAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा शेअर करा…',
      one: 'शेअर करा…',
    );
    return '$_temp0';
  }

  @override
  String get shareFailedNotice => 'शेअर मेनू उघडता आला नाही';

  @override
  String get importTitle => 'फोटो आयात करा';

  @override
  String get importDevices => 'कॅमेरे आणि कार्ड';

  @override
  String get importRefreshDevices => 'कॅमेरे आणि कार्ड शोधा';

  @override
  String get importNoDevices =>
      'काहीही जोडलेले नाही. कॅमेरा जोडा किंवा मेमरी कार्ड घाला.';

  @override
  String get importFromFolder => 'फोल्डरमधून…';

  @override
  String get importChooseSource =>
      'डावीकडे कॅमेरा, कार्ड किंवा फोल्डर निवडा. फोटो तारखेच्या फोल्डरमध्ये कॉपी होतात; कार्डवर काहीही बदलत नाही.';

  @override
  String importDestination(String folder) {
    return '$folder / वर्ष / तारीख मध्ये';
  }

  @override
  String get importChangeDestination => 'बदला…';

  @override
  String get importNothingFound => 'येथे फोटो सापडले नाहीत';

  @override
  String get importAlreadyImported => 'आयात केलेला';

  @override
  String importSelectedCount(int selected, int total) {
    return '$total पैकी $selected निवडले';
  }

  @override
  String get importSelectNew => 'नवीन निवडा';

  @override
  String get importSelectNone => 'काहीही निवडू नका';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो आयात करा',
      one: '1 फोटो आयात करा',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$total पैकी $done कॉपी होत आहेत…';
  }

  @override
  String importDone(int copied, int skipped, int failed) {
    return '$copied आयात केले, आधीपासून असलेले $skipped वगळले, $failed अयशस्वी';
  }

  @override
  String get collageAction => 'कोलाज बनवा…';

  @override
  String get collageButton => 'कोलाज…';

  @override
  String collageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटोंचा कोलाज',
      one: '1 फोटोचा कोलाज',
    );
    return '$_temp0';
  }

  @override
  String get collageMosaic => 'मोझेक';

  @override
  String get collageGrid => 'ग्रिड';

  @override
  String get collageContactSheet => 'कॉन्टॅक्ट शीट';

  @override
  String get collageHint =>
      'मोझेक प्रत्येक फोटो पूर्ण ठेवतो; ग्रिड त्यांना समान चौकटींमध्ये कापतो.';

  @override
  String get collageContactSheetHint =>
      '35 थंबनेल आणि त्यांच्या फाइल नावांसह A4 पाने, छपाईसाठी तयार.';

  @override
  String get collageSpacing => 'अंतर';

  @override
  String get collageBackground => 'पार्श्वभूमी';

  @override
  String get collageWhite => 'पांढरा';

  @override
  String get collageBlack => 'काळा';

  @override
  String get collageCharcoal => 'गडद राखाडी';

  @override
  String collageSizeWide(int width, int height) {
    return 'वाइडस्क्रीन ($width × $height)';
  }

  @override
  String collageSizeLarge(int width, int height) {
    return 'मोठा 3:2 ($width × $height)';
  }

  @override
  String collageSizeSquare(int width, int height) {
    return 'चौरस ($width × $height)';
  }

  @override
  String collageSizePortrait(int width, int height) {
    return 'पोर्ट्रेट 2:3 ($width × $height)';
  }

  @override
  String get collageWorking => 'कोलाज तयार होत आहे…';

  @override
  String collageSaved(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name पासून सुरू होणारी $count पाने जतन केली',
      one: '$name जतन केले',
    );
    return '$_temp0';
  }

  @override
  String get collageFailed => 'कोलाज तयार करता आला नाही';

  @override
  String get collageFileName => 'कोलाज';

  @override
  String get contactSheetFileName => 'कॉन्टॅक्ट शीट';

  @override
  String get placesTitle => 'ठिकाणे';

  @override
  String get placesEmpty =>
      'अजून कोणत्याही फोटोला ठिकाण नाही. फोनच्या फोटोंना सहसा असते; इतरांसाठी ते निवडा आणि ठिकाण सेट करा निवडा.';

  @override
  String get placesSetLocation => 'ठिकाण सेट करा…';

  @override
  String get placesPickHint =>
      'फोटो जिथे काढले तिथे नकाशावर क्लिक करा. झूमसाठी स्क्रोल करा, हलवण्यासाठी ओढा. फोटो फाइल्स बदलत नाहीत.';

  @override
  String get placesNoPointYet => 'अजून ठिकाण निवडलेले नाही';

  @override
  String get placesRemoveLocation => 'ठिकाण काढा';

  @override
  String printAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिमा प्रिंट करा…',
      one: 'प्रिंट करा…',
    );
    return '$_temp0';
  }

  @override
  String printTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो प्रिंट करा',
      one: '1 फोटो प्रिंट करा',
    );
    return '$_temp0';
  }

  @override
  String get printPerPage => 'प्रति पान फोटो';

  @override
  String get printHint =>
      'फोटो न कापता त्यांच्या जागेत बसवले जातात, तुमच्या संपादनांसह. कागदाचा आकार आणि दिशा पुढील विंडोमध्ये निवडा.';

  @override
  String get printContinue => 'पुढे जा…';

  @override
  String get printPreparing => 'फोटो छपाईसाठी तयार होत आहेत…';

  @override
  String printJobName(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Picavi फोटो ($count)',
      one: 'Picavi फोटो',
    );
    return '$_temp0';
  }

  @override
  String get printFailed => 'हे फोटो प्रिंट करता आले नाहीत';
}
