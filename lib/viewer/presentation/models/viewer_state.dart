import '../../domain/entities/gallery_image.dart';
import '../../domain/entities/image_sort_order.dart';
import 'viewer_notice.dart';

class ViewerState {
  const ViewerState({
    required this.images,
    required this.currentDirectory,
    required this.currentIndex,
    required this.isBootstrapping,
    required this.notice,
    this.sortOrder = const ImageSortOrder(),
    this.selectedPaths = const <String>{},
  });

  const ViewerState.initial()
    : images = const <GalleryImage>[],
      currentDirectory = null,
      currentIndex = 0,
      isBootstrapping = true,
      notice = null,
      sortOrder = const ImageSortOrder(),
      selectedPaths = const <String>{};

  final List<GalleryImage> images;
  final String? currentDirectory;
  final int currentIndex;
  final bool isBootstrapping;
  final ViewerNotice? notice;
  final ImageSortOrder sortOrder;

  /// Images picked with Cmd/Ctrl- or Shift-click. Empty means actions apply
  /// to the current image only.
  final Set<String> selectedPaths;

  bool get hasImages => images.isNotEmpty;

  GalleryImage get currentImage => images[currentIndex];

  bool get hasSelection => selectedPaths.isNotEmpty;

  /// The images an action should apply to, in gallery order: the selection
  /// when there is one, otherwise the current image.
  List<String> get actionTargets {
    if (!hasImages) {
      return const <String>[];
    }
    if (!hasSelection) {
      return <String>[currentImage.path];
    }
    return images
        .map((image) => image.path)
        .where(selectedPaths.contains)
        .toList(growable: false);
  }

  ViewerState copyWith({
    List<GalleryImage>? images,
    String? currentDirectory,
    int? currentIndex,
    bool? isBootstrapping,
    ViewerNotice? notice,
    bool clearNotice = false,
    ImageSortOrder? sortOrder,
    Set<String>? selectedPaths,
  }) {
    return ViewerState(
      images: images ?? this.images,
      currentDirectory: currentDirectory ?? this.currentDirectory,
      currentIndex: currentIndex ?? this.currentIndex,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      notice: clearNotice ? null : notice ?? this.notice,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedPaths: selectedPaths ?? this.selectedPaths,
    );
  }
}
