import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../editor/data/services/edited_image_provider.dart';
import '../../../editor/domain/entities/image_edits.dart';
import '../../domain/entities/gallery_image.dart';

/// Bottom film strip. The current image is always scrolled to the middle and
/// drawn larger than its neighbours; both changes animate quickly.
class ViewerThumbnailRail extends StatefulWidget {
  const ViewerThumbnailRail({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.thumbnailExtent,
    required this.scrollController,
    required this.onTap,
    required this.onScrollImageChange,
    this.selectedPaths = const <String>{},
    this.edits = const <String, ImageEdits>{},
    this.starredPaths = const <String>{},
    this.topInset = 0,
  });

  final List<GalleryImage> images;
  final int currentIndex;
  final double thumbnailExtent;
  final ScrollController scrollController;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onScrollImageChange;
  final Set<String> selectedPaths;

  /// Edits by path; edited images show their edited version and a badge.
  final Map<String, ImageEdits> edits;

  /// Images that show a star badge.
  final Set<String> starredPaths;

  /// Decode width for thumbnails; also used to evict them from the cache.
  static const int cacheWidth = 220;
  final double topInset;

  /// Long edge for rendering edited thumbnails (fits portrait ones too).
  static const int editedThumbnailDimension = 330;

  /// How long the size change and the re-centring scroll take.
  static const Duration transitionDuration = Duration(milliseconds: 170);
  static const Curve transitionCurve = Curves.easeOutCubic;

  static const double _topPadding = 8;
  static const double _bottomPadding = 14; // room for the scrollbar
  static const double _gap = 4;

  /// Extra space either side of the current thumbnail.
  static const double _selectedGap = 4;
  static const double _aspectRatio = 4 / 3;

  /// Unselected thumbnails are this fraction of the current one's size.
  static const double _unselectedScale = 0.74;

  static double _selectedHeight(double extent) =>
      extent - _topPadding - _bottomPadding;

  /// Size of the current image's thumbnail.
  static Size selectedSize(double extent) {
    final height = _selectedHeight(extent);
    return Size(height * _aspectRatio, height);
  }

  /// Size of every other thumbnail.
  static Size unselectedSize(double extent) =>
      selectedSize(extent) * _unselectedScale;

  /// Width of every slot in the strip; the scroll offset that centres image
  /// `i` is `i * itemStride`.
  static double itemStride(double extent) =>
      unselectedSize(extent).width + _gap;

  @override
  State<ViewerThumbnailRail> createState() => _ViewerThumbnailRailState();
}

class _ViewerThumbnailRailState extends State<ViewerThumbnailRail> {
  @override
  void initState() {
    super.initState();
    _scheduleCentering(animate: false);
  }

  @override
  void didUpdateWidget(ViewerThumbnailRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController ||
        oldWidget.thumbnailExtent != widget.thumbnailExtent) {
      _scheduleCentering(animate: false);
    } else if (oldWidget.currentIndex != widget.currentIndex ||
        !identical(oldWidget.images, widget.images)) {
      _scheduleCentering(animate: true);
    }
  }

  void _scheduleCentering({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _centerOnCurrent(animate: animate);
      }
    });
  }

  void _centerOnCurrent({required bool animate}) {
    final controller = widget.scrollController;
    if (!controller.hasClients || widget.images.isEmpty) {
      return;
    }

    final position = controller.position;
    // Slots have a fixed width and the list is padded by half the viewport on
    // each side, so the offset that centres an image does not depend on the
    // window width.
    final target =
        (widget.currentIndex *
                ViewerThumbnailRail.itemStride(widget.thumbnailExtent))
            .clamp(0.0, double.infinity);
    final distance = (target - position.pixels).abs();
    if (distance < 0.5) {
      return;
    }

    // Long hops (Home/End, opening a folder) jump instead of whipping
    // across the whole strip.
    if (!animate || distance > position.viewportDimension * 2) {
      controller.jumpTo(target);
      return;
    }

    controller.animateTo(
      target,
      duration: ViewerThumbnailRail.transitionDuration,
      curve: ViewerThumbnailRail.transitionCurve,
    );
  }

  Widget _thumbnail(
    GalleryImage image,
    ImageEdits? edits, {
    required ImageErrorWidgetBuilder errorBuilder,
    bool starred = false,
  }) {
    final picture = _picture(image, edits, errorBuilder: errorBuilder);
    if (!starred) {
      return picture;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        picture,
        const PositionedDirectional(start: 2, top: 2, child: _StarBadge()),
      ],
    );
  }

  Widget _picture(
    GalleryImage image,
    ImageEdits? edits, {
    required ImageErrorWidgetBuilder errorBuilder,
  }) {
    if (edits == null || edits.isEmpty) {
      return AppImage.file(
        image.path,
        fit: BoxFit.cover,
        revision: image.revision,
        cacheWidth: ViewerThumbnailRail.cacheWidth,
        errorBuilder: errorBuilder,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AppImage(
          image: EditedImageProvider(
            image.path,
            edits,
            maxDimension: ViewerThumbnailRail.editedThumbnailDimension,
            revision: image.revision,
          ),
          filePath: image.path,
          revision: image.revision,
          fit: BoxFit.cover,
          errorBuilder: errorBuilder,
        ),
        const PositionedDirectional(end: 3, bottom: 3, child: _EditedBadge()),
      ],
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || widget.images.length < 2) {
      return;
    }

    final primaryDelta = event.scrollDelta.dy.abs() > event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (primaryDelta == 0) {
      return;
    }

    widget.onScrollImageChange(primaryDelta > 0 ? 1 : -1);
  }

  Widget _buildItem(BuildContext context, int index) {
    final image = widget.images[index];
    final isSelected = index == widget.currentIndex;
    final isPicked = widget.selectedPaths.contains(image.path);
    final primary = Theme.of(context).colorScheme.primary;
    final extent = widget.thumbnailExtent;
    final selectedSize = ViewerThumbnailRail.selectedSize(extent);
    final size = isSelected
        ? selectedSize
        : ViewerThumbnailRail.unselectedSize(extent);
    final borderRadius = BorderRadius.circular(isSelected ? 6 : 4);

    // Every slot is the same width (so scroll offsets stay exact); the current
    // thumbnail overflows its slot and its neighbours slide apart to make room.
    final push =
        (selectedSize.width -
                ViewerThumbnailRail.unselectedSize(extent).width) /
            2 +
        ViewerThumbnailRail._selectedGap;
    final shift = index < widget.currentIndex
        ? -push
        : index > widget.currentIndex
        ? push
        : 0.0;

    return AnimatedContainer(
      duration: ViewerThumbnailRail.transitionDuration,
      curve: ViewerThumbnailRail.transitionCurve,
      transform: Matrix4.translationValues(shift, 0, 0),
      child: OverflowBox(
        minWidth: 0,
        minHeight: 0,
        maxWidth: selectedSize.width,
        maxHeight: selectedSize.height,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => widget.onTap(index),
          child: AnimatedOpacity(
            duration: ViewerThumbnailRail.transitionDuration,
            curve: ViewerThumbnailRail.transitionCurve,
            opacity: isSelected || isPicked ? 1 : 0.72,
            child: AnimatedContainer(
              key: ValueKey<String>('thumbnail-${image.path}'),
              duration: ViewerThumbnailRail.transitionDuration,
              curve: ViewerThumbnailRail.transitionCurve,
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: isSelected
                      ? primary
                      : Colors.white.withValues(alpha: 0.05),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? primary.withValues(alpha: 0.55)
                        : Colors.transparent,
                    blurRadius: isSelected ? 8 : 0,
                  ),
                ],
              ),
              foregroundDecoration: isPicked
                  ? BoxDecoration(
                      borderRadius: borderRadius,
                      color: primary.withValues(alpha: 0.28),
                      border: Border.all(color: primary, width: 2),
                    )
                  : null,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: _thumbnail(
                  image,
                  widget.edits[image.path],
                  starred: widget.starredPaths.contains(image.path),
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: AppColors.brokenImage,
                    child: Center(
                      child: Icon(Icons.broken_image_outlined, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stride = ViewerThumbnailRail.itemStride(widget.thumbnailExtent);

    return SizedBox(
      height: widget.thumbnailExtent,
      child: Listener(
        onPointerSignal: _handlePointerSignal,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.softPanel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Half a viewport of padding on each side lets the first and
              // last images reach the middle too.
              final sidePadding = ((constraints.maxWidth - stride) / 2).clamp(
                0.0,
                double.infinity,
              );
              return Scrollbar(
                controller: widget.scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                thickness: 6,
                radius: const Radius.circular(999),
                child: ListView.builder(
                  controller: widget.scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    ViewerThumbnailRail._topPadding,
                    sidePadding,
                    ViewerThumbnailRail._bottomPadding,
                  ),
                  itemExtent: stride,
                  itemCount: widget.images.length,
                  itemBuilder: _buildItem,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditedBadge extends StatelessWidget {
  const _EditedBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.editedBadgeTooltip,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xCC000000),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Icon(Icons.tune_rounded, size: 10, color: Colors.white),
        ),
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.starredBadgeTooltip,
      child: const Icon(
        Icons.star_rounded,
        size: 14,
        color: Color(0xFFFFC94D),
        shadows: [Shadow(blurRadius: 3)],
      ),
    );
  }
}
