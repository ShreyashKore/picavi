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
  String get emptyStateTitle => 'Picavi 桌面看图器';

  @override
  String get emptyStateDescription => '打开任意支持的图片，即可启动紧凑的全屏查看器，支持手势缩放和文件夹缩略图带。';

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
}
