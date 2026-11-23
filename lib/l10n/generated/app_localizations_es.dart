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
  String get shortcutCopyImage => 'Copiar imagen o el texto seleccionado';

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

  @override
  String get editImageTooltip => 'Editar imagen';

  @override
  String get editUnavailableTooltip =>
      'Este tipo de archivo no se puede editar';

  @override
  String get shortcutEdit => 'Editar imagen';

  @override
  String get editorTabFixes => 'Ajustes básicos';

  @override
  String get editorTabTuning => 'Ajustes finos';

  @override
  String get editorTabEffects => 'Efectos';

  @override
  String get editorCrop => 'Recortar';

  @override
  String get editorStraighten => 'Enderezar';

  @override
  String get editorRedEye => 'Ojos rojos';

  @override
  String get editorFeelingLucky => 'Voy a tener suerte';

  @override
  String get editorAutoContrast => 'Contraste automático';

  @override
  String get editorAutoColor => 'Color automático';

  @override
  String get editorTuneFillLight => 'Luz de relleno';

  @override
  String get editorTuneHighlights => 'Luces';

  @override
  String get editorTuneShadows => 'Sombras';

  @override
  String get editorTuneTemperature => 'Temperatura de color';

  @override
  String get editorApply => 'Aplicar';

  @override
  String get editorReset => 'Restablecer';

  @override
  String get editorClear => 'Borrar';

  @override
  String get editorStrength => 'Intensidad';

  @override
  String get effectBlackAndWhite => 'Blanco y negro';

  @override
  String get effectSepia => 'Sepia';

  @override
  String get effectWarmify => 'Calidez';

  @override
  String get effectSaturation => 'Saturación';

  @override
  String get effectSharpen => 'Enfocar';

  @override
  String get effectSoftFocus => 'Enfoque suave';

  @override
  String get effectGlow => 'Resplandor';

  @override
  String get effectFilmGrain => 'Grano de película';

  @override
  String get effectVignette => 'Viñeta';

  @override
  String get editorCropHint =>
      'Arrastra el marco o sus esquinas para elegir qué conservar.';

  @override
  String get editorCropSwapOrientation => 'Vertical / horizontal';

  @override
  String get editorCropFree => 'Libre';

  @override
  String get editorCropOriginal => 'Original';

  @override
  String get editorCropSquare => 'Cuadrado';

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
      'Mueve el control hasta que el horizonte quede alineado con la cuadrícula.';

  @override
  String editorDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get editorRedEyeHint =>
      'Haz clic en el centro de cada ojo rojo. Si el círculo es demasiado pequeño o grande, cambia antes el tamaño.';

  @override
  String get editorRedEyeSize => 'Tamaño';

  @override
  String get editorUndo => 'Deshacer';

  @override
  String get editorRedo => 'Rehacer';

  @override
  String get editorRevert => 'Revertir';

  @override
  String get editorExport => 'Exportar…';

  @override
  String get editorDone => 'Listo';

  @override
  String get editorLoadFailed => 'Esta imagen no se puede abrir para editarla.';

  @override
  String get editorSaveFailed =>
      'No se pudieron guardar las ediciones en esta carpeta. Se perderán al cerrar Picavi.';

  @override
  String editorExported(String name) {
    return 'Se guardó una copia como $name';
  }

  @override
  String get editorExportFailed => 'No se pudo exportar la imagen';

  @override
  String exportDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exportar $count imágenes',
      one: 'Exportar imagen',
    );
    return '$_temp0';
  }

  @override
  String get exportDialogDescription =>
      'Las copias editadas se guardan como archivos nuevos. Los originales nunca se modifican.';

  @override
  String get exportFormatLabel => 'Formato';

  @override
  String get exportFormatJpeg => 'JPEG';

  @override
  String get exportFormatPng => 'PNG';

  @override
  String get exportSizeLabel => 'Tamaño';

  @override
  String get exportSizeOriginal => 'Tamaño completo';

  @override
  String exportSizePixels(int size) {
    return '$size px en el lado mayor';
  }

  @override
  String exportQualityLabel(int quality) {
    return 'Calidad: $quality';
  }

  @override
  String get exportChooseFolder => 'Elegir carpeta…';

  @override
  String exportAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exportar $count imágenes…',
      one: 'Exportar…',
    );
    return '$_temp0';
  }

  @override
  String exportedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se exportaron $count imágenes',
      one: 'Se exportó 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String exportFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron exportar $count imágenes',
      one: 'No se pudo exportar 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String quickFixMenu(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Arreglo rápido de $count imágenes',
      one: 'Arreglo rápido',
    );
    return '$_temp0';
  }

  @override
  String get removeEditsAction => 'Quitar ediciones';

  @override
  String quickFixAppliedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se editaron $count imágenes',
      one: 'Se editó 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String quickFixFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron editar $count imágenes',
      one: 'No se pudo editar 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String editsRemovedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se quitaron las ediciones de $count imágenes',
      one: 'Se quitaron las ediciones de 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String get rotationAddedToEditsNotice =>
      'Giro guardado con las ediciones de esta imagen';

  @override
  String get editedBadgeTooltip => 'Editada';

  @override
  String get starTooltip => 'Destacar (S)';

  @override
  String get unstarTooltip => 'Quitar destacado (S)';

  @override
  String get starredBadgeTooltip => 'Destacada';

  @override
  String get shortcutStar => 'Destacar / quitar destacado';

  @override
  String get captionTagsAction => 'Título y etiquetas…';

  @override
  String get captionTagsTitle => 'Título y etiquetas';

  @override
  String get captionLabel => 'Título';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get tagsHint => 'Separa las etiquetas con comas';

  @override
  String get saveLabel => 'Guardar';

  @override
  String hideFromLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ocultar $count imágenes en la biblioteca',
      one: 'Ocultar en la biblioteca',
    );
    return '$_temp0';
  }

  @override
  String showInLibraryAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar $count imágenes en la biblioteca',
      one: 'Mostrar en la biblioteca',
    );
    return '$_temp0';
  }

  @override
  String get photoInfoSaveFailedNotice =>
      'No se pudo guardar el destacado, el título o las etiquetas en esta carpeta';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get shortcutLibrary => 'Abrir la biblioteca';

  @override
  String get libraryAllPhotos => 'Todas las fotos';

  @override
  String get libraryStarred => 'Destacadas';

  @override
  String get libraryAlbums => 'Álbumes';

  @override
  String get libraryFolders => 'Carpetas';

  @override
  String get libraryNoAlbums => 'Aún no hay álbumes';

  @override
  String get libraryNewAlbum => 'Nuevo álbum';

  @override
  String get libraryAlbumName => 'Nombre del álbum';

  @override
  String get libraryCreate => 'Crear';

  @override
  String get libraryRenameAlbum => 'Cambiar nombre del álbum';

  @override
  String get libraryDeleteAlbum => 'Eliminar álbum';

  @override
  String libraryDeleteAlbumTitle(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String get libraryDeleteAlbumMessage =>
      'Las fotos se quedan donde están; solo se elimina el álbum.';

  @override
  String libraryAlbumCreated(String name) {
    return 'Se creó el álbum «$name»';
  }

  @override
  String get libraryAddToAlbum => 'Añadir al álbum';

  @override
  String get libraryRemoveFromAlbum => 'Quitar del álbum';

  @override
  String libraryAddedToAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se añadieron $count fotos al álbum',
      one: 'Se añadió 1 foto al álbum',
    );
    return '$_temp0';
  }

  @override
  String libraryRemovedFromAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se quitaron $count fotos del álbum',
      one: 'Se quitó 1 foto del álbum',
    );
    return '$_temp0';
  }

  @override
  String get libraryAddFolder => 'Añadir carpeta…';

  @override
  String get libraryRemoveFolder => 'Quitar de la biblioteca';

  @override
  String get libraryRemoveFolderTitle =>
      '¿Quitar esta carpeta de la biblioteca?';

  @override
  String libraryRemoveFolderMessage(String path) {
    return 'Picavi dejará de mostrar las fotos de $path. No se cambia nada en el disco.';
  }

  @override
  String get libraryHideFolder => 'Ocultar carpeta';

  @override
  String get libraryShowFolder => 'Mostrar carpeta';

  @override
  String get libraryRevealFolder => 'Mostrar en el gestor de archivos';

  @override
  String get libraryShowHidden => 'Mostrar fotos ocultas';

  @override
  String get libraryHideHidden => 'No mostrar fotos ocultas';

  @override
  String get libraryRescan => 'Volver a examinar las carpetas';

  @override
  String get libraryThumbnailSize => 'Tamaño de las miniaturas';

  @override
  String get librarySearchHint => 'Buscar nombres, títulos, etiquetas, fechas…';

  @override
  String get libraryClearSearch => 'Borrar búsqueda';

  @override
  String get libraryEmptyTitle => 'Crea tu biblioteca de fotos';

  @override
  String get libraryEmptyMessage =>
      'Añade las carpetas donde guardas tus fotos. Picavi encuentra todas las fotos que contienen, las ordena por mes y mantiene la lista al día. Tus archivos se quedan donde están.';

  @override
  String libraryScanning(int count) {
    return 'Buscando fotos… $count encontradas';
  }

  @override
  String get libraryNoMatches => 'Ninguna foto coincide con la búsqueda';

  @override
  String get libraryNothingHere => 'No hay fotos aquí';

  @override
  String libraryPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get libraryStar => 'Destacar';

  @override
  String get libraryUnstar => 'Quitar destacado';

  @override
  String get duplicatesTitle => 'Buscar duplicados';

  @override
  String get duplicatesSearching => 'Comparando fotos…';

  @override
  String get duplicatesNone => 'No se encontraron fotos duplicadas';

  @override
  String duplicatesSummary(int count, String bin) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count grupos de fotos idénticas. Conserva una copia de cada uno y mueve las demás a $bin.',
      one:
          '1 grupo de fotos idénticas. Conserva una copia y mueve las demás a $bin.',
    );
    return '$_temp0';
  }

  @override
  String get duplicatesKeepOnly => 'Conservar solo esta';

  @override
  String get libraryPickFolderMessage =>
      'Elige una carpeta con fotos. Se incluyen sus subcarpetas.';

  @override
  String get libraryOpenFailed => 'No se pudo abrir la biblioteca';

  @override
  String shareAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compartir $count imágenes…',
      one: 'Compartir…',
    );
    return '$_temp0';
  }

  @override
  String get shareFailedNotice => 'No se pudo abrir el menú de compartir';

  @override
  String get importTitle => 'Importar fotos';

  @override
  String get importDevices => 'Cámaras y tarjetas';

  @override
  String get importRefreshDevices => 'Buscar cámaras y tarjetas';

  @override
  String get importNoDevices =>
      'No hay ninguno conectado. Conecta una cámara o inserta una tarjeta de memoria.';

  @override
  String get importFromFolder => 'Desde una carpeta…';

  @override
  String get importChooseSource =>
      'Elige una cámara, tarjeta o carpeta a la izquierda. Las fotos se copian en carpetas por fecha; no se cambia nada en la tarjeta.';

  @override
  String importDestination(String folder) {
    return 'En $folder / año / fecha';
  }

  @override
  String get importChangeDestination => 'Cambiar…';

  @override
  String get importNothingFound => 'No se encontraron fotos aquí';

  @override
  String get importAlreadyImported => 'Importada';

  @override
  String importSelectedCount(int selected, int total) {
    return '$selected de $total seleccionadas';
  }

  @override
  String get importSelectNew => 'Seleccionar nuevas';

  @override
  String get importSelectNone => 'No seleccionar ninguna';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count fotos',
      one: 'Importar 1 foto',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return 'Copiando $done de $total…';
  }

  @override
  String importDone(int copied, int skipped, int failed) {
    return 'Importadas $copied, omitidas $skipped que ya estaban, $failed con error';
  }

  @override
  String get collageAction => 'Crear un collage…';

  @override
  String get collageButton => 'Collage…';

  @override
  String collageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collage de $count fotos',
      one: 'Collage de 1 foto',
    );
    return '$_temp0';
  }

  @override
  String get collageMosaic => 'Mosaico';

  @override
  String get collageGrid => 'Cuadrícula';

  @override
  String get collageContactSheet => 'Hoja de contactos';

  @override
  String get collageHint =>
      'El mosaico muestra cada foto entera; la cuadrícula las recorta en celdas iguales.';

  @override
  String get collageContactSheetHint =>
      'Páginas A4 con 35 miniaturas y sus nombres de archivo, listas para imprimir.';

  @override
  String get collageSpacing => 'Espaciado';

  @override
  String get collageBackground => 'Fondo';

  @override
  String get collageWhite => 'Blanco';

  @override
  String get collageBlack => 'Negro';

  @override
  String get collageCharcoal => 'Carbón';

  @override
  String collageSizeWide(int width, int height) {
    return 'Panorámico ($width × $height)';
  }

  @override
  String collageSizeLarge(int width, int height) {
    return 'Grande 3:2 ($width × $height)';
  }

  @override
  String collageSizeSquare(int width, int height) {
    return 'Cuadrado ($width × $height)';
  }

  @override
  String collageSizePortrait(int width, int height) {
    return 'Vertical 2:3 ($width × $height)';
  }

  @override
  String get collageWorking => 'Creando el collage…';

  @override
  String collageSaved(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se guardaron $count páginas, empezando por $name',
      one: 'Se guardó $name',
    );
    return '$_temp0';
  }

  @override
  String get collageFailed => 'No se pudo crear el collage';

  @override
  String get collageFileName => 'Collage';

  @override
  String get contactSheetFileName => 'Hoja de contactos';

  @override
  String get placesTitle => 'Lugares';

  @override
  String get placesEmpty =>
      'Aún no hay fotos con ubicación. Las fotos del móvil suelen tenerla; para las demás, selecciónalas y elige Establecer ubicación.';

  @override
  String get placesSetLocation => 'Establecer ubicación…';

  @override
  String get placesPickHint =>
      'Haz clic en el mapa donde se tomaron las fotos. Desplaza para acercar y arrastra para moverte. Los archivos no se modifican.';

  @override
  String get placesNoPointYet => 'Aún no se ha elegido ningún lugar';

  @override
  String get placesRemoveLocation => 'Quitar ubicación';

  @override
  String printAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imprimir $count imágenes…',
      one: 'Imprimir…',
    );
    return '$_temp0';
  }

  @override
  String printTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imprimir $count fotos',
      one: 'Imprimir 1 foto',
    );
    return '$_temp0';
  }

  @override
  String get printPerPage => 'Fotos por página';

  @override
  String get printHint =>
      'Las fotos se ajustan a su espacio sin recortarse y con tus ediciones. El tamaño y la orientación del papel se eligen en la siguiente ventana.';

  @override
  String get printContinue => 'Continuar…';

  @override
  String get printPreparing => 'Preparando las fotos para imprimir…';

  @override
  String printJobName(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fotos de Picavi ($count)',
      one: 'Foto de Picavi',
    );
    return '$_temp0';
  }

  @override
  String get printFailed => 'No se pudieron imprimir estas fotos';

  @override
  String get liveTextCopy => 'Copiar texto';

  @override
  String get liveTextSelectAll => 'Seleccionar todo el texto';

  @override
  String get liveTextCopiedNotice => 'Texto copiado al portapapeles';

  @override
  String get liveTextSettingTitle => 'Seleccionar texto en imágenes';

  @override
  String get liveTextSettingDescription =>
      'Pasa el puntero sobre el texto de una foto para seleccionarlo y copiarlo. El texto se reconoce en este Mac; no se sube nada.';
}
