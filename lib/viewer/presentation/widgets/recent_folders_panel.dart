import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../domain/entities/gallery_image.dart';
import '../../domain/entities/recent_folder.dart';

/// Start-screen list of recently opened folders, each showing a few image
/// previews. Tapping a row reopens the folder; the trailing button removes the
/// entry from history without confirmation.
class RecentFoldersPanel extends StatelessWidget {
  const RecentFoldersPanel({
    super.key,
    required this.folders,
    required this.title,
    required this.imageCountLabel,
    required this.removeTooltip,
    required this.onOpen,
    required this.onRemove,
  });

  static const double _thumbnailExtent = 52;

  final List<RecentFolder> folders;
  final String title;
  final String Function(int count) imageCountLabel;
  final String removeTooltip;
  final ValueChanged<RecentFolder> onOpen;
  final ValueChanged<RecentFolder> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final folder in folders)
            _RecentFolderTile(
              folder: folder,
              thumbnailExtent: _thumbnailExtent,
              countLabel: imageCountLabel(folder.imageCount),
              removeTooltip: removeTooltip,
              onOpen: () => onOpen(folder),
              onRemove: () => onRemove(folder),
            ),
        ],
      ),
    );
  }
}

class _RecentFolderTile extends StatelessWidget {
  const _RecentFolderTile({
    required this.folder,
    required this.thumbnailExtent,
    required this.countLabel,
    required this.removeTooltip,
    required this.onOpen,
    required this.onRemove,
  });

  final RecentFolder folder;
  final double thumbnailExtent;
  final String countLabel;
  final String removeTooltip;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.folder_outlined,
                        size: 18,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        countLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _PreviewStrip(
                    images: folder.previewImages,
                    thumbnailExtent: thumbnailExtent,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onRemove,
              tooltip: removeTooltip,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 18, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStrip extends StatelessWidget {
  const _PreviewStrip({required this.images, required this.thumbnailExtent});

  final List<GalleryImage> images;
  final double thumbnailExtent;

  @override
  Widget build(BuildContext context) {
    final cacheSize = (thumbnailExtent * MediaQuery.devicePixelRatioOf(context))
        .round();

    return SizedBox(
      height: thumbnailExtent,
      child: Row(
        children: [
          for (final image in images)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: thumbnailExtent,
                  height: thumbnailExtent,
                  child: AppImage.file(
                    image.path,
                    fit: BoxFit.cover,
                    cacheWidth: cacheSize,
                    cacheHeight: cacheSize,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: AppColors.topOverlay,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 18,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
