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
}
