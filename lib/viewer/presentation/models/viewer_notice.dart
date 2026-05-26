enum ViewerNoticeType { folderAccessDenied, folderAccessRequestFailed }

class ViewerNotice {
  const ViewerNotice({required this.id, required this.type});

  final int id;
  final ViewerNoticeType type;
}
