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
}
