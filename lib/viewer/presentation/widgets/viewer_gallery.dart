import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/gallery_image.dart';
import 'interactive_image_viewer.dart';

class ViewerGallery extends StatelessWidget {
  const ViewerGallery({
    super.key,
    required this.image,
    required this.controller,
  });

  final GalleryImage image;
  final InteractiveImageViewerController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.galleryOverlay,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InteractiveImageViewer(
          controller: controller,
          image: AppImage.file(
            image.path,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, _, _) => const SizedBox.expand(),
          ),
          semanticLabel: image.fileName,
          errorBuilder: (context, error) => const ColoredBox(
            color: AppColors.brokenImage,
            child: Center(child: Icon(Icons.broken_image_outlined, size: 28)),
          ),
        ),
      ),
    );
  }
}
