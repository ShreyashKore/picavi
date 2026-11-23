enum ViewerNoticeType {
  folderAccessDenied,
  folderAccessRequestFailed,
  movedToTrash,
  trashFailed,
  copied,
  moved,
  copyFailed,
  moveFailed,
  imageCopiedToClipboard,
  clipboardFailed,
  revealFailed,
  openWithFailed,
  rotationSaved,
  rotationUnsupported,
  rotationSaveFailed,
  rotationAddedToEdits,
  exported,
  exportFailed,
  quickFixApplied,
  quickFixFailed,
  editsRemoved,
  photoInfoSaveFailed,
  shareFailed,
}

class ViewerNotice {
  const ViewerNotice({
    required this.id,
    required this.type,
    this.count = 0,
    this.detail,
  });

  final int id;
  final ViewerNoticeType type;

  /// Number of images the notice is about, where relevant.
  final int count;

  /// Extra text for the message, e.g. a file format.
  final String? detail;
}
