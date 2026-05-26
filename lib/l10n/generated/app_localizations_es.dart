// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Picavi';

  @override
  String get emptyStateTitle => 'Visor de imágenes de escritorio Picavi';

  @override
  String get emptyStateDescription =>
      'Abre cualquier imagen compatible para iniciar el visor denso en pantalla completa con zoom por gestos y una tira de miniaturas de toda la carpeta.';

  @override
  String get openImage => 'Abrir imagen';

  @override
  String get tipsText =>
      'Consejos: arrastra con el ratón o el trackpad para desplazar, pellizca o usa la rueda para ampliar y usa ← / → para moverte por la carpeta.';

  @override
  String get folderFallback => 'Carpeta';

  @override
  String viewerPosition(Object directoryName, int current, int total) {
    return '$directoryName • $current / $total';
  }

  @override
  String get folderAccessDenied =>
      'No se concedió acceso a la carpeta, por lo que solo se puede mostrar la imagen seleccionada.';

  @override
  String get folderAccessRequestFailed =>
      'No se pudo solicitar acceso a la carpeta. Se mostrará solo la imagen seleccionada.';

  @override
  String get nativeOpenViewerPrompt => 'Abrir visor';

  @override
  String get nativeGrantFolderAccessPrompt => 'Conceder acceso a la carpeta';

  @override
  String get nativeGrantFolderAccessMessage =>
      'Permite que Picavi lea las imágenes vecinas de esta carpeta.';
}
