import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/gallery_image.dart';

class ViewerGallery extends StatelessWidget {
  const ViewerGallery({
    super.key,
    required this.images,
    required this.pageController,
    required this.onPageChanged,
  });

  final List<GalleryImage> images;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.galleryOverlay,
        borderRadius: BorderRadius.circular(18),
      ),
      child: PhotoViewGallery.builder(
        pageController: pageController,
        itemCount: images.length,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        scrollPhysics: const BouncingScrollPhysics(),
        loadingBuilder: (context, loadingProgress) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(images[index].asFile),
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.6,
            filterQuality: FilterQuality.high,
            tightMode: true,
          );
        },
        onPageChanged: onPageChanged,
      ),
    );
  }
}
