import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/gallery_image.dart';

class ViewerThumbnailRail extends StatelessWidget {
  const ViewerThumbnailRail({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.thumbnailExtent,
    required this.scrollController,
    required this.onTap,
  });

  final List<GalleryImage> images;
  final int currentIndex;
  final double thumbnailExtent;
  final ScrollController scrollController;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thumbnailExtent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.softPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final isSelected = index == currentIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: thumbnailExtent - 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.05),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.28),
                              blurRadius: 16,
                            ),
                          ]
                        : const [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      images[index].asFile,
                      fit: BoxFit.cover,
                      cacheWidth: 220,
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
            );
          },
        ),
      ),
    );
  }
}
