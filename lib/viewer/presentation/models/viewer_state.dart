import '../../../editor/domain/entities/image_edits.dart';
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
    this.edits = const <String, ImageEdits>{},
    this.isWorking = false,
  });

  const ViewerState.initial()
    : images = const <GalleryImage>[],
      currentDirectory = null,
      currentIndex = 0,
      isBootstrapping = true,
      notice = null,
      sortOrder = const ImageSortOrder(),
      selectedPaths = const <String>{},
      edits = const <String, ImageEdits>{},
      isWorking = false;

  final List<GalleryImage> images;
  final String? currentDirectory;
  final int currentIndex;
  final bool isBootstrapping;
  final ViewerNotice? notice;
  final ImageSortOrder sortOrder;

  /// Images picked with Cmd/Ctrl- or Shift-click. Empty means actions apply
  /// to the current image only.
  final Set<String> selectedPaths;

  /// Non-destructive edits of images in the current folder, by path.
  final Map<String, ImageEdits> edits;

  /// A batch action (export, quick fix) is running.
  final bool isWorking;

  ImageEdits editsFor(String path) => edits[path] ?? ImageEdits.none;

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
    Map<String, ImageEdits>? edits,
    bool? isWorking,
  }) {
    return ViewerState(
      images: images ?? this.images,
      currentDirectory: currentDirectory ?? this.currentDirectory,
      currentIndex: currentIndex ?? this.currentIndex,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      notice: clearNotice ? null : notice ?? this.notice,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      edits: edits ?? this.edits,
      isWorking: isWorking ?? this.isWorking,
    );
  }
}
