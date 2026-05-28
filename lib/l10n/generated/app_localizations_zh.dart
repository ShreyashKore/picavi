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
}
