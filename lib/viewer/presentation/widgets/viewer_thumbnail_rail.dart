import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../editor/data/services/edited_image_provider.dart';
import '../../../editor/domain/entities/image_edits.dart';
import '../../domain/entities/gallery_image.dart';

class ViewerThumbnailRail extends StatelessWidget {
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

  /// Decode width for thumbnails; also used to evict them from the cache.
  static const int cacheWidth = 220;
  final double topInset;

  /// Long edge for rendering edited thumbnails (fits portrait ones too).
  static const int editedThumbnailDimension = 330;

  Widget _thumbnail(
    GalleryImage image,
    ImageEdits? edits, {
    required ImageErrorWidgetBuilder errorBuilder,
  }) {
    if (edits == null || edits.isEmpty) {
      return AppImage.file(
        image.path,
        fit: BoxFit.cover,
        revision: image.revision,
        cacheWidth: cacheWidth,
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
            maxDimension: editedThumbnailDimension,
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
    if (event is! PointerScrollEvent || images.length < 2) {
      return;
    }

    final primaryDelta = event.scrollDelta.dy.abs() > event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (primaryDelta == 0) {
      return;
    }

    onScrollImageChange(primaryDelta > 0 ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thumbnailExtent,
      child: Listener(
        onPointerSignal: _handlePointerSignal,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.softPanel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 6,
            radius: const Radius.circular(999),
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = index == currentIndex;
                final isPicked = selectedPaths.contains(images[index].path);
                final borderRadius = BorderRadius.circular(4);

                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: InkWell(
                    borderRadius: borderRadius,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: thumbnailExtent - 8,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white.withValues(alpha: 0.05),
                          width: isSelected ? 4 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : const [],
                      ),
                      foregroundDecoration: isPicked
                          ? BoxDecoration(
                              borderRadius: borderRadius,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.28),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            )
                          : null,
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: _thumbnail(
                          images[index],
                          edits[images[index].path],
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: AppColors.brokenImage,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
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
