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

  @override
  String get zoomOutTooltip => 'Alejar';

  @override
  String get zoomInTooltip => 'Acercar';

  @override
  String get actualSizeTooltip => 'Tamaño real (1:1)';

  @override
  String get rotateLeftTooltip => 'Girar a la izquierda';

  @override
  String get rotateRightTooltip => 'Girar a la derecha';

  @override
  String get showImageInfoTooltip => 'Mostrar información de la imagen';

  @override
  String get hideImageInfoTooltip => 'Ocultar información de la imagen';

  @override
  String get previousImageTooltip => 'Imagen anterior';

  @override
  String get nextImageTooltip => 'Imagen siguiente';

  @override
  String get playSlideshowTooltip => 'Iniciar presentación';

  @override
  String get pauseSlideshowTooltip => 'Pausar presentación';

  @override
  String get imageLoadFailed => 'No se pudo cargar la imagen';

  @override
  String get unknownValue => 'Desconocido';

  @override
  String get loadingValue => 'Cargando…';

  @override
  String get infoImageLabel => 'Imagen';

  @override
  String infoImagePosition(int current, int total) {
    return '$current de $total';
  }

  @override
  String get infoTypeLabel => 'Tipo';

  @override
  String get infoResolutionLabel => 'Resolución';

  @override
  String get infoFileSizeLabel => 'Tamaño';

  @override
  String get infoCapturedLabel => 'Tomada';

  @override
  String get infoModifiedLabel => 'Modificada';

  @override
  String get infoCameraLabel => 'Cámara';

  @override
  String get infoLensLabel => 'Objetivo';

  @override
  String get infoFocalLengthLabel => 'Distancia focal';

  @override
  String get infoApertureLabel => 'Apertura';

  @override
  String get infoExposureLabel => 'Exposición';

  @override
  String get infoIsoLabel => 'ISO';

  @override
  String get sortTooltip => 'Ordenar imágenes';

  @override
  String get sortByName => 'Nombre';

  @override
  String get sortByModified => 'Fecha de modificación';

  @override
  String get sortBySize => 'Tamaño';

  @override
  String get sortByType => 'Tipo de archivo';

  @override
  String get sortAscending => 'Ascendente';

  @override
  String get sortDescending => 'Descendente';

  @override
  String get keyboardShortcutsTitle => 'Atajos de teclado';

  @override
  String get shortcutNextPrevious => 'Imagen siguiente / anterior';

  @override
  String get shortcutFirstLast => 'Primera / última imagen';

  @override
  String get shortcutPlayPause => 'Iniciar / pausar presentación';

  @override
  String get shortcutZoom => 'Acercar / alejar';

  @override
  String get shortcutActualSize => 'Tamaño real (1:1)';

  @override
  String get shortcutFit => 'Ajustar a la ventana';

  @override
  String get shortcutRotate => 'Girar a la derecha / izquierda';

  @override
  String get shortcutInfo => 'Mostrar / ocultar información';

  @override
  String get shortcutHelp => 'Mostrar atajos de teclado';

  @override
  String get shortcutClose => 'Cerrar Picavi';

  @override
  String get closeLabel => 'Cerrar';

  @override
  String get moreActionsTooltip => 'Más acciones';

  @override
  String get renameAction => 'Cambiar nombre…';

  @override
  String get renameDialogTitle => 'Cambiar nombre de la imagen';

  @override
  String get renameFieldLabel => 'Nombre del archivo';

  @override
  String get renameConfirm => 'Cambiar nombre';

  @override
  String get cancelLabel => 'Cancelar';

  @override
  String get renameErrorExists => 'Ya existe un archivo con ese nombre.';

  @override
  String get renameErrorInvalid =>
      'No se puede usar ese nombre. Evita / \\ : * ? \" < > | y un punto inicial.';

  @override
  String get renameErrorFailed => 'No se pudo cambiar el nombre de la imagen.';

  @override
  String copyToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copiar $count imágenes a carpeta…',
      one: 'Copiar a carpeta…',
    );
    return '$_temp0';
  }

  @override
  String moveToFolderAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover $count imágenes a carpeta…',
      one: 'Mover a carpeta…',
    );
    return '$_temp0';
  }

  @override
  String get copyHerePrompt => 'Copiar aquí';

  @override
  String get moveHerePrompt => 'Mover aquí';

  @override
  String get chooseDestinationMessage => 'Elige una carpeta para las imágenes.';

  @override
  String get copyImageAction => 'Copiar imagen';

  @override
  String get revealInFinderAction => 'Mostrar en Finder';

  @override
  String get revealInExplorerAction => 'Mostrar en el Explorador de archivos';

  @override
  String get revealInFileManagerAction => 'Mostrar en la carpeta';

  @override
  String get openWithAction => 'Abrir con…';

  @override
  String get openWithPrompt => 'Abrir';

  @override
  String get trashName => 'Papelera';

  @override
  String get recycleBinName => 'Papelera de reciclaje';

  @override
  String moveToTrashAction(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover $count imágenes a la $bin',
      one: 'Mover a la $bin',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmTitle(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Mover $count imágenes a la $bin?',
      one: '¿Mover esta imagen a la $bin?',
    );
    return '$_temp0';
  }

  @override
  String trashConfirmMessage(String bin) {
    return 'Puedes restaurar las imágenes desde la $bin.';
  }

  @override
  String movedToTrashNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se movieron $count imágenes a la $bin',
      one: 'Se movió 1 imagen a la $bin',
    );
    return '$_temp0';
  }

  @override
  String trashFailedNotice(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron mover $count imágenes a la $bin',
      one: 'No se pudo mover 1 imagen a la $bin',
    );
    return '$_temp0';
  }

  @override
  String copiedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se copiaron $count imágenes',
      one: 'Se copió 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String movedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se movieron $count imágenes',
      one: 'Se movió 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String copyFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron copiar $count imágenes',
      one: 'No se pudo copiar 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String moveFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron mover $count imágenes',
      one: 'No se pudo mover 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String get imageCopiedNotice => 'Imagen copiada al portapapeles';

  @override
  String get clipboardFailedNotice =>
      'No se pudo copiar la imagen al portapapeles';

  @override
  String get revealFailedNotice => 'No se pudo mostrar la imagen en su carpeta';

  @override
  String get openWithFailedNotice =>
      'No se pudo abrir la imagen en esa aplicación';

  @override
  String selectionCount(int count) {
    return '$count seleccionadas';
  }

  @override
  String get clearSelectionTooltip => 'Borrar selección';

  @override
  String get shortcutRename => 'Cambiar nombre de la imagen';

  @override
  String shortcutTrash(String bin) {
    return 'Mover a la $bin';
  }

  @override
  String get shortcutCopyImage => 'Copiar imagen';

  @override
  String get shortcutSelectAll => 'Seleccionar todas las imágenes';

  @override
  String get shortcutSelect => 'Añadir a / ampliar la selección';

  @override
  String get shortcutEscape =>
      'Borrar selección, salir de pantalla completa o cerrar';

  @override
  String get clickLabel => 'Clic';

  @override
  String get slideshowSectionTitle => 'Presentación';

  @override
  String get slideshowIntervalTitle => 'Tiempo por imagen';

  @override
  String slideshowIntervalValue(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get slideshowShuffleTitle => 'Orden aleatorio';

  @override
  String get slideshowShuffleDescription =>
      'Muestra las imágenes en orden aleatorio.';

  @override
  String get slideshowLoopTitle => 'Repetir';

  @override
  String get slideshowLoopDescription =>
      'Vuelve a empezar tras la última imagen.';

  @override
  String get slideshowFullScreenTitle =>
      'Pantalla completa durante la presentación';

  @override
  String get slideshowFullScreenDescription =>
      'Cambia a pantalla completa al iniciar una presentación.';

  @override
  String get enterFullScreenTooltip => 'Pantalla completa';

  @override
  String get exitFullScreenTooltip => 'Salir de pantalla completa';

  @override
  String get fillWindowTooltip => 'Rellenar ventana';

  @override
  String get fitWindowTooltip => 'Ajustar a la ventana';

  @override
  String get shortcutFullScreen => 'Activar / desactivar pantalla completa';

  @override
  String get shortcutFitFill => 'Ajustar / rellenar ventana';

  @override
  String get dropToOpen => 'Suelta para abrir';

  @override
  String get saveRotationTooltip => 'Guardar rotación';

  @override
  String get rotationSavedNotice => 'Rotación guardada';

  @override
  String rotationUnsupportedNotice(String format) {
    return 'Todavía no se puede guardar la rotación de imágenes $format';
  }

  @override
  String get rotationSaveFailedNotice =>
      'No se pudo guardar la rotación. El archivo original no ha cambiado.';

  @override
  String get shortcutSaveRotation => 'Guardar la rotación en el archivo';
}
