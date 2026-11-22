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
}

class ViewerNotice {
  const ViewerNotice({required this.id, required this.type, this.count = 0});

  final int id;
  final ViewerNoticeType type;

  /// Number of images the notice is about, where relevant.
  final int count;
}
