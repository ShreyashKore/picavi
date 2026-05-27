import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'interactive_image_viewer.dart';

class ImageInfoOverlay extends StatelessWidget {
  const ImageInfoOverlay({
    super.key,
    required this.imagePath,
    required this.fileName,
    required this.currentIndex,
    required this.imageCount,
    required this.viewState,
  });

  final String imagePath;
  final String fileName;
  final int currentIndex;
  final int imageCount;
  final InteractiveImageViewerValue viewState;

  @override
  Widget build(BuildContext context) {
    final imageSize = viewState.imageInfo?.pixelSize;
    final rotationDegrees = (viewState.rotationQuarterTurns % 4) * 90;
    final fileSize = _readFileLength(imagePath);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.topOverlay,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.white70,
              height: 1.35,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _InfoLine(
                  label: 'Image',
                  value: '${currentIndex + 1} of $imageCount',
                ),
                _InfoLine(
                  label: 'Resolution',
                  value: imageSize == null
                      ? 'Loading…'
                      : '${imageSize.width.round()} × ${imageSize.height.round()}',
                ),
                _InfoLine(
                  label: 'Zoom',
                  value: '${viewState.zoomPercent.toStringAsFixed(0)}%',
                ),
                _InfoLine(label: 'Rotation', value: '$rotationDegrees°'),
                _InfoLine(
                  label: 'File size',
                  value: fileSize == null ? 'Unknown' : _formatBytes(fileSize),
                ),
                const SizedBox(height: 8),
                Text(
                  imagePath,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int? _readFileLength(String path) {
    try {
      return File(path).lengthSync();
    } on FileSystemException {
      return null;
    }
  }

  static String _formatBytes(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var suffixIndex = 0;

    while (value >= 1024 && suffixIndex < suffixes.length - 1) {
      value /= 1024;
      suffixIndex += 1;
    }

    final fractionDigits = value >= 100
        ? 0
        : value >= 10
        ? 1
        : 2;
    return '${value.toStringAsFixed(fractionDigits)} ${suffixes[suffixIndex]}';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
