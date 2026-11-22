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
}
