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
  String get showRecentFoldersTitle => 'إظهار المجلدات الأخيرة عند التشغيل';

  @override
  String get showRecentFoldersDescription =>
      'اعرض في شاشة البداية المجلدات التي فُتحت مؤخرًا مع معاينات للصور.';

  @override
  String get recentFoldersTitle => 'المجلدات الأخيرة';

  @override
  String recentFolderImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صور',
      one: 'صورة واحدة',
      zero: 'لا توجد صور',
    );
    return '$_temp0';
  }

  @override
  String get recentFolderRemoveTooltip => 'إزالة من الأخيرة';

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

  @override
  String get zoomOutTooltip => 'تصغير';

  @override
  String get zoomInTooltip => 'تكبير';

  @override
  String get actualSizeTooltip => 'الحجم الفعلي (1:1)';

  @override
  String get rotateLeftTooltip => 'تدوير لليسار';

  @override
  String get rotateRightTooltip => 'تدوير لليمين';

  @override
  String get showImageInfoTooltip => 'إظهار معلومات الصورة';

  @override
  String get hideImageInfoTooltip => 'إخفاء معلومات الصورة';

  @override
  String get previousImageTooltip => 'الصورة السابقة';

  @override
  String get nextImageTooltip => 'الصورة التالية';

  @override
  String get playSlideshowTooltip => 'تشغيل عرض الشرائح';

  @override
  String get pauseSlideshowTooltip => 'إيقاف عرض الشرائح مؤقتًا';

  @override
  String get imageLoadFailed => 'تعذّر تحميل الصورة';

  @override
  String get unknownValue => 'غير معروف';

  @override
  String get loadingValue => 'جارٍ التحميل…';

  @override
  String get infoImageLabel => 'الصورة';

  @override
  String infoImagePosition(int current, int total) {
    return '$current من $total';
  }

  @override
  String get infoTypeLabel => 'النوع';

  @override
  String get infoResolutionLabel => 'الدقة';

  @override
  String get infoFileSizeLabel => 'حجم الملف';

  @override
  String get infoCapturedLabel => 'تاريخ الالتقاط';

  @override
  String get infoModifiedLabel => 'تاريخ التعديل';

  @override
  String get infoCameraLabel => 'الكاميرا';

  @override
  String get infoLensLabel => 'العدسة';

  @override
  String get infoFocalLengthLabel => 'البعد البؤري';

  @override
  String get infoApertureLabel => 'فتحة العدسة';

  @override
  String get infoExposureLabel => 'التعريض';

  @override
  String get infoIsoLabel => 'ISO';

  @override
  String get sortTooltip => 'ترتيب الصور';

  @override
  String get sortByName => 'الاسم';

  @override
  String get sortByModified => 'تاريخ التعديل';

  @override
  String get sortBySize => 'حجم الملف';

  @override
  String get sortByType => 'نوع الملف';

  @override
  String get sortAscending => 'تصاعدي';

  @override
  String get sortDescending => 'تنازلي';

  @override
  String get keyboardShortcutsTitle => 'اختصارات لوحة المفاتيح';

  @override
  String get shortcutNextPrevious => 'الصورة التالية / السابقة';

  @override
  String get shortcutFirstLast => 'الصورة الأولى / الأخيرة';

  @override
  String get shortcutPlayPause => 'تشغيل / إيقاف عرض الشرائح';

  @override
  String get shortcutZoom => 'تكبير / تصغير';

  @override
  String get shortcutActualSize => 'الحجم الفعلي (1:1)';

  @override
  String get shortcutFit => 'ملاءمة النافذة';

  @override
  String get shortcutRotate => 'تدوير لليمين / لليسار';

  @override
  String get shortcutInfo => 'إظهار / إخفاء معلومات الصورة';

  @override
  String get shortcutHelp => 'إظهار اختصارات لوحة المفاتيح';

  @override
  String get shortcutClose => 'إغلاق Picavi';

  @override
  String get closeLabel => 'إغلاق';

  @override
  String get moreActionsTooltip => 'إجراءات أخرى';

  @override
  String get renameAction => 'إعادة تسمية…';

  @override
  String get renameDialogTitle => 'إعادة تسمية الصورة';

  @override
  String get renameFieldLabel => 'اسم الملف';

  @override
  String get renameConfirm => 'إعادة تسمية';

  @override
  String get cancelLabel => 'إلغاء';

  @override
  String get renameErrorExists => 'يوجد ملف بهذا الاسم بالفعل.';

  @override
  String get renameErrorInvalid =>
      'لا يمكن استخدام هذا الاسم. تجنّب / \\ : * ? \" < > | والنقطة في البداية.';

  @override
  String get renameErrorFailed => 'تعذّرت إعادة تسمية الصورة.';

  @override
  String copyToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نسخ $count صور إلى مجلد…',
      one: 'نسخ إلى مجلد…',
    );
    return '$_temp0';
  }

  @override
  String moveToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نقل $count صور إلى مجلد…',
      one: 'نقل إلى مجلد…',
    );
    return '$_temp0';
  }

  @override
  String get copyHerePrompt => 'نسخ هنا';

  @override
  String get moveHerePrompt => 'نقل هنا';

  @override
  String get chooseDestinationMessage => 'اختر مجلدًا للصور.';

  @override
  String get copyImageAction => 'نسخ الصورة';

  @override
  String get revealInFinderAction => 'إظهار في Finder';

  @override
  String get revealInExplorerAction => 'إظهار في مستكشف الملفات';

  @override
  String get revealInFileManagerAction => 'إظهار في المجلد';

  @override
  String get openWithAction => 'فتح باستخدام…';

  @override
  String get openWithPrompt => 'فتح';

  @override
  String get trashName => 'سلة المهملات';

  @override
  String get recycleBinName => 'سلة المحذوفات';

  @override
  String moveToTrashAction(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نقل $count صور إلى $bin',
      one: 'نقل إلى $bin',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmTitle(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نقل $count صور إلى $bin؟',
      one: 'نقل هذه الصورة إلى $bin؟',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmMessage(String bin) {
    return 'يمكنك استعادة الصور من $bin.';
  }

  @override
  String movedToTrashNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم نقل $count صور إلى $bin',
      one: 'تم نقل صورة واحدة إلى $bin',
    );
    return '$_temp0';
  }

  @override
  String trashFailedNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذّر نقل $count صور إلى $bin',
      one: 'تعذّر نقل صورة واحدة إلى $bin',
    );
    return '$_temp0';
  }

  @override
  String copiedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم نسخ $count صور',
      one: 'تم نسخ صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String movedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم نقل $count صور',
      one: 'تم نقل صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String copyFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذّر نسخ $count صور',
      one: 'تعذّر نسخ صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String moveFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذّر نقل $count صور',
      one: 'تعذّر نقل صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get imageCopiedNotice => 'تم نسخ الصورة إلى الحافظة';

  @override
  String get clipboardFailedNotice => 'تعذّر نسخ الصورة إلى الحافظة';

  @override
  String get revealFailedNotice => 'تعذّر إظهار الصورة في مجلدها';

  @override
  String get openWithFailedNotice => 'تعذّر فتح الصورة في هذا التطبيق';

  @override
  String selectionCount(int count) {
    return '$count محددة';
  }

  @override
  String get clearSelectionTooltip => 'مسح التحديد';

  @override
  String get shortcutRename => 'إعادة تسمية الصورة';

  @override
  String shortcutTrash(String bin) {
    return 'نقل إلى $bin';
  }

  @override
  String get shortcutCopyImage => 'نسخ الصورة';

  @override
  String get shortcutSelectAll => 'تحديد كل الصور';

  @override
  String get shortcutSelect => 'إضافة إلى التحديد / توسيعه';

  @override
  String get shortcutEscape => 'مسح التحديد أو الخروج من ملء الشاشة أو الإغلاق';

  @override
  String get clickLabel => 'نقرة';

  @override
  String get slideshowSectionTitle => 'عرض الشرائح';

  @override
  String get slideshowIntervalTitle => 'مدة كل صورة';

  @override
  String slideshowIntervalValue(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds ثوانٍ',
      one: 'ثانية واحدة',
    );
    return '$_temp0';
  }

  @override
  String get slideshowShuffleTitle => 'ترتيب عشوائي';

  @override
  String get slideshowShuffleDescription => 'اعرض الصور بترتيب عشوائي.';

  @override
  String get slideshowLoopTitle => 'تكرار';

  @override
  String get slideshowLoopDescription => 'ابدأ من جديد بعد آخر صورة.';

  @override
  String get slideshowFullScreenTitle => 'ملء الشاشة أثناء عرض الشرائح';

  @override
  String get slideshowFullScreenDescription =>
      'التبديل إلى ملء الشاشة عند بدء عرض الشرائح.';

  @override
  String get enterFullScreenTooltip => 'ملء الشاشة';

  @override
  String get exitFullScreenTooltip => 'الخروج من ملء الشاشة';

  @override
  String get fillWindowTooltip => 'ملء النافذة';

  @override
  String get fitWindowTooltip => 'ملاءمة النافذة';

  @override
  String get shortcutFullScreen => 'تشغيل / إيقاف ملء الشاشة';

  @override
  String get shortcutFitFill => 'ملاءمة / ملء النافذة';

  @override
  String get dropToOpen => 'أفلت للفتح';

  @override
  String get saveRotationTooltip => 'حفظ التدوير';

  @override
  String get rotationSavedNotice => 'تم حفظ التدوير';

  @override
  String rotationUnsupportedNotice(String format) {
    return 'لا يمكن حفظ التدوير لصور $format بعد';
  }

  @override
  String get rotationSaveFailedNotice =>
      'تعذّر حفظ التدوير. لم يتغيّر الملف الأصلي.';

  @override
  String get shortcutSaveRotation => 'حفظ التدوير في الملف';

  @override
  String get editImageTooltip => 'تحرير الصورة';

  @override
  String get editUnavailableTooltip => 'لا يمكن تحرير هذا النوع من الملفات';

  @override
  String get shortcutEdit => 'تحرير الصورة';

  @override
  String get editorTabFixes => 'إصلاحات أساسية';

  @override
  String get editorTabTuning => 'ضبط';

  @override
  String get editorTabEffects => 'تأثيرات';

  @override
  String get editorCrop => 'اقتصاص';

  @override
  String get editorStraighten => 'تقويم';

  @override
  String get editorRedEye => 'العين الحمراء';

  @override
  String get editorFeelingLucky => 'أشعر بالحظ';

  @override
  String get editorAutoContrast => 'تباين تلقائي';

  @override
  String get editorAutoColor => 'لون تلقائي';

  @override
  String get editorTuneFillLight => 'إضاءة التعبئة';

  @override
  String get editorTuneHighlights => 'الإضاءات';

  @override
  String get editorTuneShadows => 'الظلال';

  @override
  String get editorTuneTemperature => 'حرارة اللون';

  @override
  String get editorApply => 'تطبيق';

  @override
  String get editorReset => 'إعادة تعيين';

  @override
  String get editorClear => 'مسح';

  @override
  String get editorStrength => 'الشدة';

  @override
  String get effectBlackAndWhite => 'أبيض وأسود';

  @override
  String get effectSepia => 'بني داكن';

  @override
  String get effectWarmify => 'دفء';

  @override
  String get effectSaturation => 'التشبع';

  @override
  String get effectSharpen => 'زيادة الحدة';

  @override
  String get effectSoftFocus => 'تركيز ناعم';

  @override
  String get effectGlow => 'توهج';

  @override
  String get effectFilmGrain => 'حبيبات الفيلم';

  @override
  String get effectVignette => 'تظليل الحواف';

  @override
  String get editorCropHint =>
      'اسحب الإطار أو زواياه لاختيار ما تريد الاحتفاظ به.';

  @override
  String get editorCropSwapOrientation => 'عمودي / أفقي';

  @override
  String get editorCropFree => 'حر';

  @override
  String get editorCropOriginal => 'الأصلي';

  @override
  String get editorCropSquare => 'مربع';

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
      'حرّك شريط التمرير حتى يتوافق الأفق مع الشبكة.';

  @override
  String editorDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get editorRedEyeHint =>
      'انقر على وسط كل عين حمراء. غيّر الحجم أولاً إذا كانت الدائرة صغيرة أو كبيرة جدًا.';

  @override
  String get editorRedEyeSize => 'الحجم';

  @override
  String get editorUndo => 'تراجع';

  @override
  String get editorRedo => 'إعادة';

  @override
  String get editorRevert => 'استعادة الأصل';

  @override
  String get editorExport => 'تصدير…';

  @override
  String get editorDone => 'تم';

  @override
  String get editorLoadFailed => 'تعذّر فتح هذه الصورة للتحرير.';

  @override
  String get editorSaveFailed =>
      'تعذّر حفظ التعديلات في هذا المجلد. ستُفقد عند إغلاق Picavi.';

  @override
  String editorExported(String name) {
    return 'تم حفظ نسخة باسم $name';
  }

  @override
  String get editorExportFailed => 'تعذّر تصدير الصورة';

  @override
  String exportDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تصدير $count صور',
      one: 'تصدير الصورة',
    );
    return '$_temp0';
  }

  @override
  String get exportDialogDescription =>
      'تُحفظ النسخ المعدّلة كملفات جديدة. لا تتغير الملفات الأصلية أبدًا.';

  @override
  String get exportFormatLabel => 'التنسيق';

  @override
  String get exportFormatJpeg => 'JPEG';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportSizeLabel => 'الحجم';

  @override
  String get exportSizeOriginal => 'الحجم الكامل';

  @override
  String exportSizePixels(int size) {
    return '$size بكسل للضلع الأطول';
  }

  @override
  String exportQualityLabel(int quality) {
    return 'الجودة: $quality';
  }

  @override
  String get exportChooseFolder => 'اختيار مجلد…';

  @override
  String exportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تصدير $count صور…',
      one: 'تصدير…',
    );
    return '$_temp0';
  }

  @override
  String exportedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تصدير $count صور',
      one: 'تم تصدير صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String exportFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذّر تصدير $count صور',
      one: 'تعذّر تصدير صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String quickFixMenu(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إصلاح سريع لـ $count صور',
      one: 'إصلاح سريع',
    );
    return '$_temp0';
  }

  @override
  String get removeEditsAction => 'إزالة التعديلات';

  @override
  String quickFixAppliedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تحرير $count صور',
      one: 'تم تحرير صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String quickFixFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذّر تحرير $count صور',
      one: 'تعذّر تحرير صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String editsRemovedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إزالة التعديلات من $count صور',
      one: 'تمت إزالة التعديلات من صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get rotationAddedToEditsNotice =>
      'تم حفظ التدوير مع تعديلات هذه الصورة';

  @override
  String get editedBadgeTooltip => 'معدّلة';
}
