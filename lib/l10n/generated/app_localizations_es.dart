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
  String get emptyStateTitle => 'Picavi';

  @override
  String get emptyStateDescription =>
      'Visor de imágenes ligero y sin complicaciones.';

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

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get defaultViewerTitle => 'Visor predeterminado';

  @override
  String get restoreLastOpenedImageTitle =>
      'Restaurar la última imagen abierta al iniciar';

  @override
  String get restoreLastOpenedImageDescription =>
      'Vuelve a abrir la última imagen vista, o su carpeta si la imagen ya no está disponible, cuando Picavi se inicie sin un archivo explícito.';

  @override
  String get showRecentFoldersTitle => 'Mostrar carpetas recientes al iniciar';

  @override
  String get showRecentFoldersDescription =>
      'Muestra en la pantalla de inicio las carpetas abiertas recientemente con vistas previas de imágenes.';

  @override
  String get recentFoldersTitle => 'Carpetas recientes';

  @override
  String recentFolderImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count imágenes',
      one: '1 imagen',
      zero: 'Sin imágenes',
    );
    return '$_temp0';
  }

  @override
  String get recentFolderRemoveTooltip => 'Quitar de recientes';

  @override
  String get versionTitle => 'Versión';

  @override
  String get defaultViewerActionSet => 'Establecer como visor predeterminado';

  @override
  String get defaultViewerActionOpenSystemSettings =>
      'Abrir la configuración de aplicaciones predeterminadas';

  @override
  String get defaultViewerPromptTitle =>
      '¿Quieres que Picavi sea tu visor de imágenes predeterminado?';

  @override
  String get defaultViewerPromptMessage =>
      'Puedes abrir imágenes en Picavi directamente desde Finder, el Explorador de archivos o tu administrador de archivos. Puedes cambiar esto más tarde desde Configuración.';

  @override
  String get notNowLabel => 'Ahora no';

  @override
  String get defaultViewerHintTitle =>
      'Picavi no es el visor de imágenes predeterminado.';

  @override
  String get defaultViewerChecking => 'Comprobando…';

  @override
  String get defaultViewerStatusDefault =>
      'Picavi es actualmente tu visor de imágenes predeterminado para los formatos compatibles.';

  @override
  String get defaultViewerStatusNotDefault =>
      'Picavi aún no es tu visor de imágenes predeterminado.';

  @override
  String get defaultViewerGuidedHelp =>
      'Tu sistema operativo te guiará en los pasos restantes.';

  @override
  String get defaultViewerSetSuccess =>
      'Picavi ahora es el visor de imágenes predeterminado para los formatos compatibles.';

  @override
  String get defaultViewerFlowOpened =>
      'Se abrió la configuración de aplicaciones predeterminadas del sistema.';

  @override
  String get defaultViewerSetFailed =>
      'No se pudo establecer Picavi como visor predeterminado automáticamente.';

  @override
  String get defaultViewerUnsupported =>
      'La configuración del visor predeterminado no está disponible en esta plataforma.';
}
