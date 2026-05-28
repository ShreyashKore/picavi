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
  String get emptyStateTitle => 'Picavi';

  @override
  String get emptyStateDescription => 'عارض صور خفيف وبسيط بلا تعقيد.';

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

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get defaultViewerTitle => 'العارض الافتراضي';

  @override
  String get restoreLastOpenedImageTitle =>
      'استعادة آخر صورة تم فتحها عند التشغيل';

  @override
  String get restoreLastOpenedImageDescription =>
      'أعد فتح آخر صورة تمت مشاهدتها، أو مجلدها إذا لم تعد الصورة متاحة، عندما يبدأ Picavi بدون ملف محدد صراحةً.';

  @override
  String get versionTitle => 'الإصدار';

  @override
  String get defaultViewerActionSet => 'تعيين كعارض افتراضي';

  @override
  String get defaultViewerActionOpenSystemSettings =>
      'افتح إعدادات التطبيقات الافتراضية';

  @override
  String get defaultViewerPromptTitle =>
      'هل تريد جعل Picavi عارض الصور الافتراضي؟';

  @override
  String get defaultViewerPromptMessage =>
      'يمكنك فتح الصور في Picavi مباشرةً من Finder أو File Explorer أو مدير الملفات لديك. ويمكنك تغيير ذلك لاحقًا من الإعدادات.';

  @override
  String get notNowLabel => 'ليس الآن';

  @override
  String get defaultViewerHintTitle => 'Picavi ليس عارض الصور الافتراضي.';

  @override
  String get defaultViewerChecking => 'جارٍ التحقق…';

  @override
  String get defaultViewerStatusDefault =>
      'Picavi هو حاليًا عارض الصور الافتراضي للتنسيقات المدعومة.';

  @override
  String get defaultViewerStatusNotDefault =>
      'Picavi ليس عارض الصور الافتراضي لديك بعد.';

  @override
  String get defaultViewerGuidedHelp =>
      'سيقوم نظام التشغيل لديك بإرشادك خلال الخطوات المتبقية.';

  @override
  String get defaultViewerSetSuccess =>
      'أصبح Picavi الآن عارض الصور الافتراضي للتنسيقات المدعومة.';

  @override
  String get defaultViewerFlowOpened =>
      'تم فتح إعدادات التطبيقات الافتراضية في النظام.';

  @override
  String get defaultViewerSetFailed =>
      'تعذر تعيين Picavi كعارض افتراضي تلقائيًا.';

  @override
  String get defaultViewerUnsupported =>
      'إعداد العارض الافتراضي غير متاح على هذه المنصة.';
}
