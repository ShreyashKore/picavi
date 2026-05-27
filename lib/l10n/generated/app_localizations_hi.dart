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
}
