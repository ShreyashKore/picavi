// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Picavi';

  @override
  String get emptyStateTitle => 'Picavi';

  @override
  String get emptyStateDescription => '轻量、简洁、不花哨的图片查看器。';

  @override
  String get openImage => '打开图片';

  @override
  String get tipsText => '提示：使用鼠标或触控板拖动可平移，捏合或滚动可缩放，使用 ← / → 可在文件夹中切换。';

  @override
  String get folderFallback => '文件夹';

  @override
  String viewerPosition(Object directoryName, int current, int total) {
    return '$directoryName • $current / $total';
  }

  @override
  String get folderAccessDenied => '未授予文件夹访问权限，因此只能显示所选图片。';

  @override
  String get folderAccessRequestFailed => '无法请求文件夹访问权限。仅显示所选图片。';

  @override
  String get nativeOpenViewerPrompt => '打开查看器';

  @override
  String get nativeGrantFolderAccessPrompt => '授予文件夹访问权限';

  @override
  String get nativeGrantFolderAccessMessage => '允许 Picavi 读取此文件夹中的同级图片。';

  @override
  String get settingsTitle => '设置';

  @override
  String get defaultViewerTitle => '默认查看器';

  @override
  String get restoreLastOpenedImageTitle => '启动时恢复上次打开的图片';

  @override
  String get restoreLastOpenedImageDescription =>
      '当 Picavi 在没有明确指定文件的情况下启动时，重新打开上次查看的图片；如果该图片已不存在，则打开其所在文件夹。';

  @override
  String get showRecentFoldersTitle => '启动时显示最近的文件夹';

  @override
  String get showRecentFoldersDescription => '在起始屏幕上列出最近打开的文件夹及其图片预览。';

  @override
  String get recentFoldersTitle => '最近的文件夹';

  @override
  String recentFolderImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张图片',
      one: '1 张图片',
      zero: '没有图片',
    );
    return '$_temp0';
  }

  @override
  String get recentFolderRemoveTooltip => '从最近列表中移除';

  @override
  String get versionTitle => '版本';

  @override
  String get defaultViewerActionSet => '设为默认查看器';

  @override
  String get defaultViewerActionOpenSystemSettings => '打开默认应用设置';

  @override
  String get defaultViewerPromptTitle => '要将 Picavi 设为默认图片查看器吗？';

  @override
  String get defaultViewerPromptMessage =>
      '你可以直接从 Finder、文件资源管理器或文件管理器中用 Picavi 打开图片。你也可以稍后在“设置”中更改此项。';

  @override
  String get notNowLabel => '暂不';

  @override
  String get defaultViewerHintTitle => 'Picavi 不是默认图片查看器。';

  @override
  String get defaultViewerChecking => '正在检查…';

  @override
  String get defaultViewerStatusDefault => '对于受支持的格式，Picavi 当前是你的默认图片查看器。';

  @override
  String get defaultViewerStatusNotDefault => 'Picavi 还不是你的默认图片查看器。';

  @override
  String get defaultViewerGuidedHelp => '你的操作系统会引导你完成剩余步骤。';

  @override
  String get defaultViewerSetSuccess => '对于受支持的格式，Picavi 现在已是默认图片查看器。';

  @override
  String get defaultViewerFlowOpened => '系统默认应用设置已打开。';

  @override
  String get defaultViewerSetFailed => '无法自动将 Picavi 设为默认查看器。';

  @override
  String get defaultViewerUnsupported => '此平台不支持默认查看器设置。';

  @override
  String get zoomOutTooltip => '缩小';

  @override
  String get zoomInTooltip => '放大';

  @override
  String get actualSizeTooltip => '实际大小 (1:1)';

  @override
  String get rotateLeftTooltip => '向左旋转';

  @override
  String get rotateRightTooltip => '向右旋转';

  @override
  String get showImageInfoTooltip => '显示图片信息';

  @override
  String get hideImageInfoTooltip => '隐藏图片信息';

  @override
  String get previousImageTooltip => '上一张';

  @override
  String get nextImageTooltip => '下一张';

  @override
  String get playSlideshowTooltip => '播放幻灯片';

  @override
  String get pauseSlideshowTooltip => '暂停幻灯片';

  @override
  String get imageLoadFailed => '无法加载图片';

  @override
  String get unknownValue => '未知';

  @override
  String get loadingValue => '正在加载…';

  @override
  String get infoImageLabel => '图片';

  @override
  String infoImagePosition(int current, int total) {
    return '第 $current 张，共 $total 张';
  }

  @override
  String get infoTypeLabel => '类型';

  @override
  String get infoResolutionLabel => '分辨率';

  @override
  String get infoFileSizeLabel => '文件大小';

  @override
  String get infoCapturedLabel => '拍摄时间';

  @override
  String get infoModifiedLabel => '修改时间';

  @override
  String get infoCameraLabel => '相机';

  @override
  String get infoLensLabel => '镜头';

  @override
  String get infoFocalLengthLabel => '焦距';

  @override
  String get infoApertureLabel => '光圈';

  @override
  String get infoExposureLabel => '曝光';

  @override
  String get infoIsoLabel => 'ISO';

  @override
  String get sortTooltip => '排序图片';

  @override
  String get sortByName => '名称';

  @override
  String get sortByModified => '修改日期';

  @override
  String get sortBySize => '文件大小';

  @override
  String get sortByType => '文件类型';

  @override
  String get sortAscending => '升序';

  @override
  String get sortDescending => '降序';

  @override
  String get keyboardShortcutsTitle => '键盘快捷键';

  @override
  String get shortcutNextPrevious => '下一张 / 上一张';

  @override
  String get shortcutFirstLast => '第一张 / 最后一张';

  @override
  String get shortcutPlayPause => '播放 / 暂停幻灯片';

  @override
  String get shortcutZoom => '放大 / 缩小';

  @override
  String get shortcutActualSize => '实际大小 (1:1)';

  @override
  String get shortcutFit => '适应窗口';

  @override
  String get shortcutRotate => '向右 / 向左旋转';

  @override
  String get shortcutInfo => '显示 / 隐藏图片信息';

  @override
  String get shortcutHelp => '显示键盘快捷键';

  @override
  String get shortcutClose => '关闭 Picavi';

  @override
  String get closeLabel => '关闭';

  @override
  String get moreActionsTooltip => '更多操作';

  @override
  String get renameAction => '重命名…';

  @override
  String get renameDialogTitle => '重命名图片';

  @override
  String get renameFieldLabel => '文件名';

  @override
  String get renameConfirm => '重命名';

  @override
  String get cancelLabel => '取消';

  @override
  String get renameErrorExists => '已存在同名文件。';

  @override
  String get renameErrorInvalid => '无法使用该名称。请避免 / \\ : * ? \" < > | 以及开头的点。';

  @override
  String get renameErrorFailed => '无法重命名该图片。';

  @override
  String copyToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将 $count 张图片复制到文件夹…',
      one: '复制到文件夹…',
    );
    return '$_temp0';
  }

  @override
  String moveToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将 $count 张图片移动到文件夹…',
      one: '移动到文件夹…',
    );
    return '$_temp0';
  }

  @override
  String get copyHerePrompt => '复制到此处';

  @override
  String get moveHerePrompt => '移动到此处';

  @override
  String get chooseDestinationMessage => '为图片选择一个文件夹。';

  @override
  String get copyImageAction => '复制图片';

  @override
  String get revealInFinderAction => '在访达中显示';

  @override
  String get revealInExplorerAction => '在文件资源管理器中显示';

  @override
  String get revealInFileManagerAction => '在文件夹中显示';

  @override
  String get openWithAction => '打开方式…';

  @override
  String get openWithPrompt => '打开';

  @override
  String get trashName => '废纸篓';

  @override
  String get recycleBinName => '回收站';

  @override
  String moveToTrashAction(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将 $count 张图片移到$bin',
      one: '移到$bin',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmTitle(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将 $count 张图片移到$bin？',
      one: '将此图片移到$bin？',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmMessage(String bin) {
    return '你可以从$bin中恢复图片。';
  }

  @override
  String movedToTrashNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 张图片移到$bin',
      one: '已将 1 张图片移到$bin',
    );
    return '$_temp0';
  }

  @override
  String trashFailedNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 张图片无法移到$bin',
      one: '有 1 张图片无法移到$bin',
    );
    return '$_temp0';
  }

  @override
  String copiedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已复制 $count 张图片',
      one: '已复制 1 张图片',
    );
    return '$_temp0';
  }

  @override
  String movedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已移动 $count 张图片',
      one: '已移动 1 张图片',
    );
    return '$_temp0';
  }

  @override
  String copyFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 张图片无法复制',
      one: '有 1 张图片无法复制',
    );
    return '$_temp0';
  }

  @override
  String moveFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 张图片无法移动',
      one: '有 1 张图片无法移动',
    );
    return '$_temp0';
  }

  @override
  String get imageCopiedNotice => '图片已复制到剪贴板';

  @override
  String get clipboardFailedNotice => '无法将图片复制到剪贴板';

  @override
  String get revealFailedNotice => '无法在文件夹中显示该图片';

  @override
  String get openWithFailedNotice => '无法在该应用中打开图片';

  @override
  String selectionCount(int count) {
    return '已选择 $count 张';
  }

  @override
  String get clearSelectionTooltip => '清除选择';

  @override
  String get shortcutRename => '重命名图片';

  @override
  String shortcutTrash(String bin) {
    return '移到$bin';
  }

  @override
  String get shortcutCopyImage => '复制图片';

  @override
  String get shortcutSelectAll => '全选图片';

  @override
  String get shortcutSelect => '添加到 / 扩展选择';

  @override
  String get shortcutEscape => '清除选择、退出全屏或关闭';

  @override
  String get clickLabel => '点击';

  @override
  String get slideshowSectionTitle => '幻灯片';

  @override
  String get slideshowIntervalTitle => '每张图片的时间';

  @override
  String slideshowIntervalValue(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get slideshowShuffleTitle => '随机播放';

  @override
  String get slideshowShuffleDescription => '以随机顺序显示图片。';

  @override
  String get slideshowLoopTitle => '循环';

  @override
  String get slideshowLoopDescription => '播放完最后一张后重新开始。';

  @override
  String get slideshowFullScreenTitle => '幻灯片播放时全屏';

  @override
  String get slideshowFullScreenDescription => '开始播放幻灯片时切换到全屏。';

  @override
  String get enterFullScreenTooltip => '全屏';

  @override
  String get exitFullScreenTooltip => '退出全屏';

  @override
  String get fillWindowTooltip => '填满窗口';

  @override
  String get fitWindowTooltip => '适应窗口';

  @override
  String get shortcutFullScreen => '开启 / 关闭全屏';

  @override
  String get shortcutFitFill => '适应 / 填满窗口';

  @override
  String get dropToOpen => '松开以打开';

  @override
  String get saveRotationTooltip => '保存旋转';

  @override
  String get rotationSavedNotice => '旋转已保存';

  @override
  String rotationUnsupportedNotice(String format) {
    return '暂不支持保存 $format 图片的旋转';
  }

  @override
  String get rotationSaveFailedNotice => '无法保存旋转，原文件未更改。';

  @override
  String get shortcutSaveRotation => '将旋转保存到文件';

  @override
  String get editImageTooltip => '编辑图片';

  @override
  String get editUnavailableTooltip => '无法编辑此类文件';

  @override
  String get shortcutEdit => '编辑图片';

  @override
  String get editorTabFixes => '基本修正';

  @override
  String get editorTabTuning => '微调';

  @override
  String get editorTabEffects => '效果';

  @override
  String get editorCrop => '裁剪';

  @override
  String get editorStraighten => '拉直';

  @override
  String get editorRedEye => '红眼';

  @override
  String get editorFeelingLucky => '手气不错';

  @override
  String get editorAutoContrast => '自动对比度';

  @override
  String get editorAutoColor => '自动颜色';

  @override
  String get editorTuneFillLight => '补光';

  @override
  String get editorTuneHighlights => '高光';

  @override
  String get editorTuneShadows => '阴影';

  @override
  String get editorTuneTemperature => '色温';

  @override
  String get editorApply => '应用';

  @override
  String get editorReset => '重置';

  @override
  String get editorClear => '清除';

  @override
  String get editorStrength => '强度';

  @override
  String get effectBlackAndWhite => '黑白';

  @override
  String get effectSepia => '怀旧';

  @override
  String get effectWarmify => '暖色';

  @override
  String get effectSaturation => '饱和度';

  @override
  String get effectSharpen => '锐化';

  @override
  String get effectSoftFocus => '柔焦';

  @override
  String get effectGlow => '光晕';

  @override
  String get effectFilmGrain => '胶片颗粒';

  @override
  String get effectVignette => '暗角';

  @override
  String get editorCropHint => '拖动边框或其四角，选择要保留的部分。';

  @override
  String get editorCropSwapOrientation => '纵向 / 横向';

  @override
  String get editorCropFree => '自由';

  @override
  String get editorCropOriginal => '原始比例';

  @override
  String get editorCropSquare => '正方形';

  @override
  String get editorCrop4x6 => '4 × 6';

  @override
  String get editorCrop5x7 => '5 × 7';

  @override
  String get editorCrop8x10 => '8 × 10';

  @override
  String get editorCrop16x9 => '16:9';

  @override
  String get editorStraightenHint => '移动滑块，直到地平线与网格对齐。';

  @override
  String editorDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get editorRedEyeHint => '点击每只红眼的中心。如果圆圈太小或太大，请先调整大小。';

  @override
  String get editorRedEyeSize => '大小';

  @override
  String get editorUndo => '撤销';

  @override
  String get editorRedo => '重做';

  @override
  String get editorRevert => '还原';

  @override
  String get editorExport => '导出…';

  @override
  String get editorDone => '完成';

  @override
  String get editorLoadFailed => '无法打开此图片进行编辑。';

  @override
  String get editorSaveFailed => '无法在此文件夹中保存编辑。关闭 Picavi 后编辑将丢失。';

  @override
  String editorExported(String name) {
    return '已另存为 $name';
  }

  @override
  String get editorExportFailed => '无法导出图片';

  @override
  String exportDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '导出 $count 张图片',
      one: '导出图片',
    );
    return '$_temp0';
  }

  @override
  String get exportDialogDescription => '编辑后的副本会保存为新文件，原图永远不会被更改。';

  @override
  String get exportFormatLabel => '格式';

  @override
  String get exportFormatJpeg => 'JPEG';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportSizeLabel => '尺寸';

  @override
  String get exportSizeOriginal => '原始尺寸';

  @override
  String exportSizePixels(int size) {
    return '长边 $size 像素';
  }

  @override
  String exportQualityLabel(int quality) {
    return '质量：$quality';
  }

  @override
  String get exportChooseFolder => '选择文件夹…';

  @override
  String exportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '导出 $count 张图片…',
      one: '导出…',
    );
    return '$_temp0';
  }

  @override
  String exportedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导出 $count 张图片',
      one: '已导出 1 张图片',
    );
    return '$_temp0';
  }

  @override
  String exportFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 张图片无法导出',
      one: '有 1 张图片无法导出',
    );
    return '$_temp0';
  }

  @override
  String quickFixMenu(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '快速修正 $count 张图片',
      one: '快速修正',
    );
    return '$_temp0';
  }

  @override
  String get removeEditsAction => '移除编辑';

  @override
  String quickFixAppliedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已编辑 $count 张图片',
      one: '已编辑 1 张图片',
    );
    return '$_temp0';
  }

  @override
  String quickFixFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 张图片无法编辑',
      one: '有 1 张图片无法编辑',
    );
    return '$_temp0';
  }

  @override
  String editsRemovedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已移除 $count 张图片的编辑',
      one: '已移除 1 张图片的编辑',
    );
    return '$_temp0';
  }

  @override
  String get rotationAddedToEditsNotice => '旋转已与此图片的编辑一起保存';

  @override
  String get editedBadgeTooltip => '已编辑';
}
