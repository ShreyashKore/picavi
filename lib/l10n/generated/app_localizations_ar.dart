// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Picavi';

  @override
  String get emptyStateTitle => 'عارض الصور المكتبي Picavi';

  @override
  String get emptyStateDescription =>
      'افتح أي صورة مدعومة لبدء العارض الكثيف بملء الشاشة مع تكبير بالإيماءات وشريط صور مصغرة لكل ملفات المجلد.';

  @override
  String get openImage => 'افتح صورة';

  @override
  String get tipsText =>
      'نصائح: اسحب بالماوس أو لوحة اللمس للتحريك، واستخدم القرص أو الإيماءة للتكبير، واستعمل ← / → للتنقل داخل المجلد.';

  @override
  String get folderFallback => 'المجلد';

  @override
  String viewerPosition(Object directoryName, int current, int total) {
    return '$directoryName • $current / $total';
  }

  @override
  String get folderAccessDenied =>
      'لم يتم منح إذن الوصول إلى المجلد، لذلك يمكن عرض الصورة المحددة فقط.';

  @override
  String get folderAccessRequestFailed =>
      'تعذر طلب إذن الوصول إلى المجلد. سيتم عرض الصورة المحددة فقط.';

  @override
  String get nativeOpenViewerPrompt => 'افتح العارض';

  @override
  String get nativeGrantFolderAccessPrompt => 'امنح إذن الوصول إلى المجلد';

  @override
  String get nativeGrantFolderAccessMessage =>
      'اسمح لـ Picavi بقراءة الصور المجاورة داخل هذا المجلد.';
}
