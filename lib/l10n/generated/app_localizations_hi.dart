// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Picavi';

  @override
  String get emptyStateTitle => 'Picavi';

  @override
  String get emptyStateDescription => 'हल्का और बिना झंझट वाला इमेज व्यूअर।';

  @override
  String get openImage => 'छवि खोलें';

  @override
  String get tipsText =>
      'सुझाव: पैन करने के लिए माउस या ट्रैकपैड से खींचें, ज़ूम करने के लिए पिंच या स्क्रॉल करें, और फ़ोल्डर में आगे-पीछे जाने के लिए ← / → का उपयोग करें।';

  @override
  String get folderFallback => 'फ़ोल्डर';

  @override
  String viewerPosition(Object directoryName, int current, int total) {
    return '$directoryName • $current / $total';
  }

  @override
  String get folderAccessDenied =>
      'फ़ोल्डर एक्सेस नहीं दिया गया, इसलिए केवल चुनी हुई छवि दिखाई जा सकती है।';

  @override
  String get folderAccessRequestFailed =>
      'फ़ोल्डर एक्सेस का अनुरोध नहीं किया जा सका। केवल चुनी हुई छवि दिखाई जा रही है।';

  @override
  String get nativeOpenViewerPrompt => 'व्यूअर खोलें';

  @override
  String get nativeGrantFolderAccessPrompt => 'फ़ोल्डर एक्सेस दें';

  @override
  String get nativeGrantFolderAccessMessage =>
      'Picavi को इस फ़ोल्डर की अन्य छवियाँ पढ़ने की अनुमति दें।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get defaultViewerTitle => 'डिफ़ॉल्ट व्यूअर';

  @override
  String get restoreLastOpenedImageTitle =>
      'ऐप खुलने पर पिछली खोली गई छवि बहाल करें';

  @override
  String get restoreLastOpenedImageDescription =>
      'जब Picavi बिना किसी स्पष्ट फ़ाइल के शुरू हो, तो आख़िरी देखी गई छवि खोलें; अगर वह उपलब्ध न हो तो उसका फ़ोल्डर खोलें।';

  @override
  String get showRecentFoldersTitle => 'लॉन्च पर हाल के फ़ोल्डर दिखाएं';

  @override
  String get showRecentFoldersDescription =>
      'प्रारंभ स्क्रीन पर हाल ही में खोले गए फ़ोल्डर छवि पूर्वावलोकन के साथ दिखाएं।';

  @override
  String get recentFoldersTitle => 'हाल के फ़ोल्डर';

  @override
  String recentFolderImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ',
      one: '1 छवि',
      zero: 'कोई छवि नहीं',
    );
    return '$_temp0';
  }

  @override
  String get recentFolderRemoveTooltip => 'हाल से हटाएं';

  @override
  String get versionTitle => 'संस्करण';

  @override
  String get defaultViewerActionSet => 'डिफ़ॉल्ट व्यूअर के रूप में सेट करें';

  @override
  String get defaultViewerActionOpenSystemSettings =>
      'डिफ़ॉल्ट ऐप्स सेटिंग्स खोलें';

  @override
  String get defaultViewerPromptTitle =>
      'क्या आप Picavi को अपना डिफ़ॉल्ट इमेज व्यूअर बनाना चाहते हैं?';

  @override
  String get defaultViewerPromptMessage =>
      'आप Finder, File Explorer या अपने फ़ाइल मैनेजर से सीधे Picavi में छवियाँ खोल सकते हैं। आप इसे बाद में सेटिंग्स से बदल सकते हैं।';

  @override
  String get notNowLabel => 'अभी नहीं';

  @override
  String get defaultViewerHintTitle => 'Picavi डिफ़ॉल्ट इमेज व्यूअर नहीं है।';

  @override
  String get defaultViewerChecking => 'जाँचा जा रहा है…';

  @override
  String get defaultViewerStatusDefault =>
      'समर्थित फ़ॉर्मैट्स के लिए Picavi इस समय आपका डिफ़ॉल्ट इमेज व्यूअर है।';

  @override
  String get defaultViewerStatusNotDefault =>
      'Picavi अभी तक आपका डिफ़ॉल्ट इमेज व्यूअर नहीं है।';

  @override
  String get defaultViewerGuidedHelp =>
      'आपका ऑपरेटिंग सिस्टम बाकी चरणों में आपका मार्गदर्शन करेगा।';

  @override
  String get defaultViewerSetSuccess =>
      'समर्थित फ़ॉर्मैट्स के लिए Picavi अब डिफ़ॉल्ट इमेज व्यूअर है।';

  @override
  String get defaultViewerFlowOpened =>
      'सिस्टम की डिफ़ॉल्ट ऐप्स सेटिंग्स खोल दी गई हैं।';

  @override
  String get defaultViewerSetFailed =>
      'Picavi को अपने-आप डिफ़ॉल्ट व्यूअर के रूप में सेट नहीं किया जा सका।';

  @override
  String get defaultViewerUnsupported =>
      'इस प्लेटफ़ॉर्म पर डिफ़ॉल्ट व्यूअर सेटअप उपलब्ध नहीं है।';

  @override
  String get zoomOutTooltip => 'ज़ूम आउट';

  @override
  String get zoomInTooltip => 'ज़ूम इन';

  @override
  String get actualSizeTooltip => 'वास्तविक आकार (1:1)';

  @override
  String get rotateLeftTooltip => 'बाएँ घुमाएँ';

  @override
  String get rotateRightTooltip => 'दाएँ घुमाएँ';

  @override
  String get showImageInfoTooltip => 'छवि जानकारी दिखाएँ';

  @override
  String get hideImageInfoTooltip => 'छवि जानकारी छिपाएँ';

  @override
  String get previousImageTooltip => 'पिछली छवि';

  @override
  String get nextImageTooltip => 'अगली छवि';

  @override
  String get playSlideshowTooltip => 'स्लाइड शो चलाएँ';

  @override
  String get pauseSlideshowTooltip => 'स्लाइड शो रोकें';

  @override
  String get imageLoadFailed => 'छवि लोड नहीं हो सकी';

  @override
  String get unknownValue => 'अज्ञात';

  @override
  String get loadingValue => 'लोड हो रहा है…';

  @override
  String get infoImageLabel => 'छवि';

  @override
  String infoImagePosition(int current, int total) {
    return '$total में से $current';
  }

  @override
  String get infoTypeLabel => 'प्रकार';

  @override
  String get infoResolutionLabel => 'रिज़ॉल्यूशन';

  @override
  String get infoFileSizeLabel => 'फ़ाइल आकार';

  @override
  String get infoCapturedLabel => 'लिया गया';

  @override
  String get infoModifiedLabel => 'संशोधित';

  @override
  String get infoCameraLabel => 'कैमरा';

  @override
  String get infoLensLabel => 'लेंस';

  @override
  String get infoFocalLengthLabel => 'फ़ोकल लंबाई';

  @override
  String get infoApertureLabel => 'एपर्चर';

  @override
  String get infoExposureLabel => 'एक्सपोज़र';

  @override
  String get infoIsoLabel => 'ISO';

  @override
  String get sortTooltip => 'छवियाँ क्रमबद्ध करें';

  @override
  String get sortByName => 'नाम';

  @override
  String get sortByModified => 'संशोधन तिथि';

  @override
  String get sortBySize => 'फ़ाइल आकार';

  @override
  String get sortByType => 'फ़ाइल प्रकार';

  @override
  String get sortAscending => 'आरोही';

  @override
  String get sortDescending => 'अवरोही';

  @override
  String get keyboardShortcutsTitle => 'कीबोर्ड शॉर्टकट';

  @override
  String get shortcutNextPrevious => 'अगली / पिछली छवि';

  @override
  String get shortcutFirstLast => 'पहली / अंतिम छवि';

  @override
  String get shortcutPlayPause => 'स्लाइड शो चलाएँ / रोकें';

  @override
  String get shortcutZoom => 'ज़ूम इन / आउट';

  @override
  String get shortcutActualSize => 'वास्तविक आकार (1:1)';

  @override
  String get shortcutFit => 'विंडो में फ़िट करें';

  @override
  String get shortcutRotate => 'दाएँ / बाएँ घुमाएँ';

  @override
  String get shortcutInfo => 'छवि जानकारी दिखाएँ / छिपाएँ';

  @override
  String get shortcutHelp => 'कीबोर्ड शॉर्टकट दिखाएँ';

  @override
  String get shortcutClose => 'Picavi बंद करें';

  @override
  String get closeLabel => 'बंद करें';

  @override
  String get moreActionsTooltip => 'और क्रियाएँ';

  @override
  String get renameAction => 'नाम बदलें…';

  @override
  String get renameDialogTitle => 'छवि का नाम बदलें';

  @override
  String get renameFieldLabel => 'फ़ाइल का नाम';

  @override
  String get renameConfirm => 'नाम बदलें';

  @override
  String get cancelLabel => 'रद्द करें';

  @override
  String get renameErrorExists => 'इस नाम की फ़ाइल पहले से मौजूद है।';

  @override
  String get renameErrorInvalid =>
      'यह नाम इस्तेमाल नहीं हो सकता। / \\ : * ? \" < > | और शुरुआती बिंदु से बचें।';

  @override
  String get renameErrorFailed => 'छवि का नाम नहीं बदला जा सका।';

  @override
  String copyToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ फ़ोल्डर में कॉपी करें…',
      one: 'फ़ोल्डर में कॉपी करें…',
    );
    return '$_temp0';
  }

  @override
  String moveToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ फ़ोल्डर में ले जाएँ…',
      one: 'फ़ोल्डर में ले जाएँ…',
    );
    return '$_temp0';
  }

  @override
  String get copyHerePrompt => 'यहाँ कॉपी करें';

  @override
  String get moveHerePrompt => 'यहाँ ले जाएँ';

  @override
  String get chooseDestinationMessage => 'छवियों के लिए एक फ़ोल्डर चुनें।';

  @override
  String get copyImageAction => 'छवि कॉपी करें';

  @override
  String get revealInFinderAction => 'Finder में दिखाएँ';

  @override
  String get revealInExplorerAction => 'फ़ाइल एक्सप्लोरर में दिखाएँ';

  @override
  String get revealInFileManagerAction => 'फ़ोल्डर में दिखाएँ';

  @override
  String get openWithAction => 'इसके साथ खोलें…';

  @override
  String get openWithPrompt => 'खोलें';

  @override
  String get trashName => 'ट्रैश';

  @override
  String get recycleBinName => 'रीसायकल बिन';

  @override
  String moveToTrashAction(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ $bin में ले जाएँ',
      one: '$bin में ले जाएँ',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmTitle(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ $bin में ले जाएँ?',
      one: 'यह छवि $bin में ले जाएँ?',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmMessage(String bin) {
    return 'आप छवियों को $bin से वापस ला सकते हैं।';
  }

  @override
  String movedToTrashNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ $bin में ले जाई गईं',
      one: '1 छवि $bin में ले जाई गई',
    );
    return '$_temp0';
  }

  @override
  String trashFailedNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ $bin में नहीं ले जाई जा सकीं',
      one: '1 छवि $bin में नहीं ले जाई जा सकी',
    );
    return '$_temp0';
  }

  @override
  String copiedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ कॉपी की गईं',
      one: '1 छवि कॉपी की गई',
    );
    return '$_temp0';
  }

  @override
  String movedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ ले जाई गईं',
      one: '1 छवि ले जाई गई',
    );
    return '$_temp0';
  }

  @override
  String copyFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ कॉपी नहीं हो सकीं',
      one: '1 छवि कॉपी नहीं हो सकी',
    );
    return '$_temp0';
  }

  @override
  String moveFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ नहीं ले जाई जा सकीं',
      one: '1 छवि नहीं ले जाई जा सकी',
    );
    return '$_temp0';
  }

  @override
  String get imageCopiedNotice => 'छवि क्लिपबोर्ड पर कॉपी की गई';

  @override
  String get clipboardFailedNotice => 'छवि क्लिपबोर्ड पर कॉपी नहीं हो सकी';

  @override
  String get revealFailedNotice => 'छवि उसके फ़ोल्डर में नहीं दिखाई जा सकी';

  @override
  String get openWithFailedNotice => 'छवि उस ऐप में नहीं खुल सकी';

  @override
  String selectionCount(int count) {
    return '$count चयनित';
  }

  @override
  String get clearSelectionTooltip => 'चयन हटाएँ';

  @override
  String get shortcutRename => 'छवि का नाम बदलें';

  @override
  String shortcutTrash(String bin) {
    return '$bin में ले जाएँ';
  }

  @override
  String get shortcutCopyImage => 'छवि कॉपी करें';

  @override
  String get shortcutSelectAll => 'सभी छवियाँ चुनें';

  @override
  String get shortcutSelect => 'चयन में जोड़ें / बढ़ाएँ';

  @override
  String get shortcutEscape => 'चयन हटाएँ, फ़ुल स्क्रीन छोड़ें या बंद करें';

  @override
  String get clickLabel => 'क्लिक';

  @override
  String get slideshowSectionTitle => 'स्लाइड शो';

  @override
  String get slideshowIntervalTitle => 'प्रति छवि समय';

  @override
  String slideshowIntervalValue(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds सेकंड',
      one: '1 सेकंड',
    );
    return '$_temp0';
  }

  @override
  String get slideshowShuffleTitle => 'शफ़ल';

  @override
  String get slideshowShuffleDescription =>
      'छवियों को यादृच्छिक क्रम में दिखाएँ।';

  @override
  String get slideshowLoopTitle => 'दोहराएँ';

  @override
  String get slideshowLoopDescription => 'अंतिम छवि के बाद फिर से शुरू करें।';

  @override
  String get slideshowFullScreenTitle => 'स्लाइड शो के दौरान फ़ुल स्क्रीन';

  @override
  String get slideshowFullScreenDescription =>
      'स्लाइड शो शुरू होने पर फ़ुल स्क्रीन पर जाएँ।';

  @override
  String get enterFullScreenTooltip => 'फ़ुल स्क्रीन';

  @override
  String get exitFullScreenTooltip => 'फ़ुल स्क्रीन से बाहर निकलें';

  @override
  String get fillWindowTooltip => 'विंडो भरें';

  @override
  String get fitWindowTooltip => 'विंडो में फ़िट करें';

  @override
  String get shortcutFullScreen => 'फ़ुल स्क्रीन चालू / बंद';

  @override
  String get shortcutFitFill => 'विंडो में फ़िट / भरें';

  @override
  String get dropToOpen => 'खोलने के लिए छोड़ें';

  @override
  String get saveRotationTooltip => 'घुमाव सहेजें';

  @override
  String get rotationSavedNotice => 'घुमाव सहेजा गया';

  @override
  String rotationUnsupportedNotice(String format) {
    return '$format छवियों के लिए घुमाव अभी सहेजा नहीं जा सकता';
  }

  @override
  String get rotationSaveFailedNotice =>
      'घुमाव सहेजा नहीं जा सका। मूल फ़ाइल नहीं बदली।';

  @override
  String get shortcutSaveRotation => 'घुमाव फ़ाइल में सहेजें';

  @override
  String get editImageTooltip => 'छवि संपादित करें';

  @override
  String get editUnavailableTooltip =>
      'यह फ़ाइल प्रकार संपादित नहीं किया जा सकता';

  @override
  String get shortcutEdit => 'छवि संपादित करें';

  @override
  String get editorTabFixes => 'बुनियादी सुधार';

  @override
  String get editorTabTuning => 'ट्यूनिंग';

  @override
  String get editorTabEffects => 'इफ़ेक्ट';

  @override
  String get editorCrop => 'क्रॉप';

  @override
  String get editorStraighten => 'सीधा करें';

  @override
  String get editorRedEye => 'लाल आँख';

  @override
  String get editorFeelingLucky => 'भाग्य आज़माएँ';

  @override
  String get editorAutoContrast => 'स्वतः कंट्रास्ट';

  @override
  String get editorAutoColor => 'स्वतः रंग';

  @override
  String get editorTuneFillLight => 'फ़िल लाइट';

  @override
  String get editorTuneHighlights => 'हाइलाइट्स';

  @override
  String get editorTuneShadows => 'छायाएँ';

  @override
  String get editorTuneTemperature => 'रंग तापमान';

  @override
  String get editorApply => 'लागू करें';

  @override
  String get editorReset => 'रीसेट करें';

  @override
  String get editorClear => 'साफ़ करें';

  @override
  String get editorStrength => 'तीव्रता';

  @override
  String get effectBlackAndWhite => 'ब्लैक एंड व्हाइट';

  @override
  String get effectSepia => 'सीपिया';

  @override
  String get effectWarmify => 'गर्माहट';

  @override
  String get effectSaturation => 'संतृप्ति';

  @override
  String get effectSharpen => 'शार्प करें';

  @override
  String get effectSoftFocus => 'सॉफ़्ट फ़ोकस';

  @override
  String get effectGlow => 'चमक';

  @override
  String get effectFilmGrain => 'फ़िल्म ग्रेन';

  @override
  String get effectVignette => 'विनेट';

  @override
  String get editorCropHint =>
      'क्या रखना है चुनने के लिए फ़्रेम या उसके कोने खींचें।';

  @override
  String get editorCropSwapOrientation => 'पोर्ट्रेट / लैंडस्केप';

  @override
  String get editorCropFree => 'मुक्त';

  @override
  String get editorCropOriginal => 'मूल';

  @override
  String get editorCropSquare => 'वर्गाकार';

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
      'स्लाइडर तब तक खिसकाएँ जब तक क्षितिज ग्रिड से न मिल जाए।';

  @override
  String editorDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get editorRedEyeHint =>
      'हर लाल आँख के बीच में क्लिक करें। अगर घेरा बहुत छोटा या बड़ा हो, तो पहले आकार बदलें।';

  @override
  String get editorRedEyeSize => 'आकार';

  @override
  String get editorUndo => 'पूर्ववत करें';

  @override
  String get editorRedo => 'फिर से करें';

  @override
  String get editorRevert => 'मूल पर लौटें';

  @override
  String get editorExport => 'निर्यात करें…';

  @override
  String get editorDone => 'हो गया';

  @override
  String get editorLoadFailed => 'इस छवि को संपादन के लिए नहीं खोला जा सका।';

  @override
  String get editorSaveFailed =>
      'इस फ़ोल्डर में आपके संपादन सहेजे नहीं जा सके। Picavi बंद करने पर वे खो जाएँगे।';

  @override
  String editorExported(String name) {
    return 'प्रति $name के रूप में सहेजी गई';
  }

  @override
  String get editorExportFailed => 'छवि निर्यात नहीं हो सकी';

  @override
  String exportDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ निर्यात करें',
      one: 'छवि निर्यात करें',
    );
    return '$_temp0';
  }

  @override
  String get exportDialogDescription =>
      'संपादित प्रतियाँ नई फ़ाइलों के रूप में सहेजी जाती हैं। आपकी मूल फ़ाइलें कभी नहीं बदलतीं।';

  @override
  String get exportFormatLabel => 'फ़ॉर्मैट';

  @override
  String get exportFormatJpeg => 'JPEG';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportSizeLabel => 'आकार';

  @override
  String get exportSizeOriginal => 'पूरा आकार';

  @override
  String exportSizePixels(int size) {
    return 'लंबी तरफ़ $size px';
  }

  @override
  String exportQualityLabel(int quality) {
    return 'गुणवत्ता: $quality';
  }

  @override
  String get exportChooseFolder => 'फ़ोल्डर चुनें…';

  @override
  String exportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ निर्यात करें…',
      one: 'निर्यात करें…',
    );
    return '$_temp0';
  }

  @override
  String exportedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ निर्यात की गईं',
      one: '1 छवि निर्यात की गई',
    );
    return '$_temp0';
  }

  @override
  String exportFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ निर्यात नहीं हो सकीं',
      one: '1 छवि निर्यात नहीं हो सकी',
    );
    return '$_temp0';
  }

  @override
  String quickFixMenu(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियों का त्वरित सुधार',
      one: 'त्वरित सुधार',
    );
    return '$_temp0';
  }

  @override
  String get removeEditsAction => 'संपादन हटाएँ';

  @override
  String quickFixAppliedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ संपादित की गईं',
      one: '1 छवि संपादित की गई',
    );
    return '$_temp0';
  }

  @override
  String quickFixFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ संपादित नहीं हो सकीं',
      one: '1 छवि संपादित नहीं हो सकी',
    );
    return '$_temp0';
  }

  @override
  String editsRemovedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियों के संपादन हटाए गए',
      one: '1 छवि के संपादन हटाए गए',
    );
    return '$_temp0';
  }

  @override
  String get rotationAddedToEditsNotice =>
      'घुमाव इस छवि के संपादनों के साथ सहेजा गया';

  @override
  String get editedBadgeTooltip => 'संपादित';

  @override
  String get starTooltip => 'स्टार लगाएँ (S)';

  @override
  String get unstarTooltip => 'स्टार हटाएँ (S)';

  @override
  String get starredBadgeTooltip => 'स्टार लगी';

  @override
  String get shortcutStar => 'स्टार लगाएँ / हटाएँ';

  @override
  String get captionTagsAction => 'कैप्शन और टैग…';

  @override
  String get captionTagsTitle => 'कैप्शन और टैग';

  @override
  String get captionLabel => 'कैप्शन';

  @override
  String get tagsLabel => 'टैग';

  @override
  String get tagsHint => 'टैग को अल्पविराम से अलग करें';

  @override
  String get saveLabel => 'सहेजें';

  @override
  String hideFromLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ लाइब्रेरी से छिपाएँ',
      one: 'लाइब्रेरी से छिपाएँ',
    );
    return '$_temp0';
  }

  @override
  String showInLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ लाइब्रेरी में दिखाएँ',
      one: 'लाइब्रेरी में दिखाएँ',
    );
    return '$_temp0';
  }

  @override
  String get photoInfoSaveFailedNotice =>
      'इस फ़ोल्डर में स्टार, कैप्शन या टैग सहेजे नहीं जा सके';

  @override
  String get libraryTitle => 'लाइब्रेरी';

  @override
  String get shortcutLibrary => 'लाइब्रेरी खोलें';

  @override
  String get libraryAllPhotos => 'सभी फ़ोटो';

  @override
  String get libraryStarred => 'स्टार लगी';

  @override
  String get libraryAlbums => 'एल्बम';

  @override
  String get libraryFolders => 'फ़ोल्डर';

  @override
  String get libraryNoAlbums => 'अभी कोई एल्बम नहीं';

  @override
  String get libraryNewAlbum => 'नया एल्बम';

  @override
  String get libraryAlbumName => 'एल्बम का नाम';

  @override
  String get libraryCreate => 'बनाएँ';

  @override
  String get libraryRenameAlbum => 'एल्बम का नाम बदलें';

  @override
  String get libraryDeleteAlbum => 'एल्बम हटाएँ';

  @override
  String libraryDeleteAlbumTitle(String name) {
    return '“$name” हटाएँ?';
  }

  @override
  String get libraryDeleteAlbumMessage =>
      'इसकी फ़ोटो जहाँ हैं वहीं रहेंगी; केवल एल्बम हटेगा।';

  @override
  String libraryAlbumCreated(String name) {
    return 'एल्बम “$name” बनाया गया';
  }

  @override
  String get libraryAddToAlbum => 'एल्बम में जोड़ें';

  @override
  String get libraryRemoveFromAlbum => 'एल्बम से हटाएँ';

  @override
  String libraryAddedToAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो एल्बम में जोड़ी गईं',
      one: '1 फ़ोटो एल्बम में जोड़ी गई',
    );
    return '$_temp0';
  }

  @override
  String libraryRemovedFromAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो एल्बम से हटाई गईं',
      one: '1 फ़ोटो एल्बम से हटाई गई',
    );
    return '$_temp0';
  }

  @override
  String get libraryAddFolder => 'फ़ोल्डर जोड़ें…';

  @override
  String get libraryRemoveFolder => 'लाइब्रेरी से हटाएँ';

  @override
  String get libraryRemoveFolderTitle => 'इस फ़ोल्डर को लाइब्रेरी से हटाएँ?';

  @override
  String libraryRemoveFolderMessage(String path) {
    return 'Picavi $path की फ़ोटो दिखाना बंद कर देगा। डिस्क पर कुछ नहीं बदलेगा।';
  }

  @override
  String get libraryHideFolder => 'फ़ोल्डर छिपाएँ';

  @override
  String get libraryShowFolder => 'फ़ोल्डर दिखाएँ';

  @override
  String get libraryRevealFolder => 'फ़ाइल मैनेजर में दिखाएँ';

  @override
  String get libraryShowHidden => 'छिपी फ़ोटो दिखाएँ';

  @override
  String get libraryHideHidden => 'छिपी फ़ोटो न दिखाएँ';

  @override
  String get libraryRescan => 'फ़ोल्डर फिर से स्कैन करें';

  @override
  String get libraryThumbnailSize => 'थंबनेल का आकार';

  @override
  String get librarySearchHint => 'नाम, कैप्शन, टैग, तारीखें खोजें…';

  @override
  String get libraryClearSearch => 'खोज साफ़ करें';

  @override
  String get libraryEmptyTitle => 'अपनी फ़ोटो लाइब्रेरी बनाएँ';

  @override
  String get libraryEmptyMessage =>
      'वे फ़ोल्डर जोड़ें जिनमें आप फ़ोटो रखते हैं। Picavi उनमें हर फ़ोटो ढूँढकर महीने के अनुसार लगाता है और सूची अपडेट रखता है। आपकी फ़ाइलें जहाँ हैं वहीं रहती हैं।';

  @override
  String libraryScanning(int count) {
    return 'फ़ोटो खोजी जा रही हैं… $count मिलीं';
  }

  @override
  String get libraryNoMatches => 'आपकी खोज से कोई फ़ोटो मेल नहीं खाती';

  @override
  String get libraryNothingHere => 'यहाँ कोई फ़ोटो नहीं';

  @override
  String libraryPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो',
      one: '1 फ़ोटो',
    );
    return '$_temp0';
  }

  @override
  String get libraryStar => 'स्टार लगाएँ';

  @override
  String get libraryUnstar => 'स्टार हटाएँ';

  @override
  String get duplicatesTitle => 'डुप्लिकेट खोजें';

  @override
  String get duplicatesSearching => 'फ़ोटो की तुलना हो रही है…';

  @override
  String get duplicatesNone => 'कोई डुप्लिकेट फ़ोटो नहीं मिली';

  @override
  String duplicatesSummary(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'एक जैसी फ़ोटो के $count समूह। हर एक की एक प्रति रखें और बाकी को $bin में भेजें।',
      one: 'एक जैसी फ़ोटो का 1 समूह। एक प्रति रखें और बाकी को $bin में भेजें।',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesKeepOnly => 'केवल इसे रखें';

  @override
  String get libraryPickFolderMessage =>
      'फ़ोटो वाला फ़ोल्डर चुनें। इसके उप-फ़ोल्डर भी शामिल होंगे।';

  @override
  String get libraryOpenFailed => 'लाइब्रेरी नहीं खुल सकी';

  @override
  String shareAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छवियाँ साझा करें…',
      one: 'साझा करें…',
    );
    return '$_temp0';
  }

  @override
  String get shareFailedNotice => 'साझा करने का मेनू नहीं खुल सका';

  @override
  String get importTitle => 'फ़ोटो इंपोर्ट करें';

  @override
  String get importDevices => 'कैमरे और कार्ड';

  @override
  String get importRefreshDevices => 'कैमरे और कार्ड खोजें';

  @override
  String get importNoDevices =>
      'कोई जुड़ा नहीं है। कैमरा लगाएँ या मेमोरी कार्ड डालें।';

  @override
  String get importFromFolder => 'किसी फ़ोल्डर से…';

  @override
  String get importChooseSource =>
      'बाईं ओर कैमरा, कार्ड या फ़ोल्डर चुनें। फ़ोटो तारीख वाले फ़ोल्डरों में कॉपी होती हैं; कार्ड पर कुछ नहीं बदलता।';

  @override
  String importDestination(String folder) {
    return '$folder / वर्ष / तारीख में';
  }

  @override
  String get importChangeDestination => 'बदलें…';

  @override
  String get importNothingFound => 'यहाँ कोई फ़ोटो नहीं मिली';

  @override
  String get importAlreadyImported => 'इंपोर्ट की गई';

  @override
  String importSelectedCount(int selected, int total) {
    return '$total में से $selected चुनी गईं';
  }

  @override
  String get importSelectNew => 'नई चुनें';

  @override
  String get importSelectNone => 'कोई नहीं चुनें';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो इंपोर्ट करें',
      one: '1 फ़ोटो इंपोर्ट करें',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$total में से $done कॉपी हो रही हैं…';
  }

  @override
  String importDone(int copied, int skipped, int failed) {
    return '$copied इंपोर्ट हुईं, पहले से मौजूद $skipped छोड़ी गईं, $failed विफल';
  }

  @override
  String get collageAction => 'कोलाज बनाएँ…';

  @override
  String get collageButton => 'कोलाज…';

  @override
  String collageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो का कोलाज',
      one: '1 फ़ोटो का कोलाज',
    );
    return '$_temp0';
  }

  @override
  String get collageMosaic => 'मोज़ेक';

  @override
  String get collageGrid => 'ग्रिड';

  @override
  String get collageContactSheet => 'कॉन्टैक्ट शीट';

  @override
  String get collageHint =>
      'मोज़ेक हर फ़ोटो को पूरा रखता है; ग्रिड उन्हें बराबर खानों में काटता है।';

  @override
  String get collageContactSheetHint =>
      '35 थंबनेल और उनके फ़ाइल नामों वाले A4 पेज, प्रिंट के लिए तैयार।';

  @override
  String get collageSpacing => 'अंतराल';

  @override
  String get collageBackground => 'पृष्ठभूमि';

  @override
  String get collageWhite => 'सफ़ेद';

  @override
  String get collageBlack => 'काला';

  @override
  String get collageCharcoal => 'गहरा स्लेटी';

  @override
  String collageSizeWide(int width, int height) {
    return 'वाइडस्क्रीन ($width × $height)';
  }

  @override
  String collageSizeLarge(int width, int height) {
    return 'बड़ा 3:2 ($width × $height)';
  }

  @override
  String collageSizeSquare(int width, int height) {
    return 'वर्गाकार ($width × $height)';
  }

  @override
  String collageSizePortrait(int width, int height) {
    return 'पोर्ट्रेट 2:3 ($width × $height)';
  }

  @override
  String get collageWorking => 'कोलाज बन रहा है…';

  @override
  String collageSaved(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name से शुरू होकर $count पेज सहेजे गए',
      one: '$name सहेजा गया',
    );
    return '$_temp0';
  }

  @override
  String get collageFailed => 'कोलाज नहीं बन सका';

  @override
  String get collageFileName => 'कोलाज';

  @override
  String get contactSheetFileName => 'कॉन्टैक्ट शीट';
}
