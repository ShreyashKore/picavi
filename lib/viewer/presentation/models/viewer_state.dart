import '../../domain/entities/gallery_image.dart';
import 'viewer_notice.dart';

class ViewerState {
  const ViewerState({
    required this.images,
    required this.currentDirectory,
    required this.currentIndex,
    required this.isBootstrapping,
    required this.notice,
  });

  const ViewerState.initial()
    : images = const <GalleryImage>[],
      currentDirectory = null,
      currentIndex = 0,
      isBootstrapping = true,
      notice = null;

  final List<GalleryImage> images;
  final String? currentDirectory;
  final int currentIndex;
  final bool isBootstrapping;
  final ViewerNotice? notice;

  bool get hasImages => images.isNotEmpty;

  GalleryImage get currentImage => images[currentIndex];

  ViewerState copyWith({
    List<GalleryImage>? images,
    String? currentDirectory,
    int? currentIndex,
    bool? isBootstrapping,
    ViewerNotice? notice,
    bool clearNotice = false,
  }) {
    return ViewerState(
      images: images ?? this.images,
      currentDirectory: currentDirectory ?? this.currentDirectory,
      currentIndex: currentIndex ?? this.currentIndex,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      notice: clearNotice ? null : notice ?? this.notice,
    );
  }
}
