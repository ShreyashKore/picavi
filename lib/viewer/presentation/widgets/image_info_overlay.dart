import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../domain/entities/image_metadata.dart';
import 'interactive_image_viewer.dart';

class ImageInfoOverlay extends StatefulWidget {
  const ImageInfoOverlay({
    super.key,
    required this.imagePath,
    required this.fileName,
    required this.currentIndex,
    required this.imageCount,
    required this.viewState,
    this.caption = '',
    this.tags = const <String>[],
  });

  final String imagePath;
  final String fileName;
  final int currentIndex;
  final int imageCount;
  final InteractiveImageViewerValue viewState;
  final String caption;
  final List<String> tags;

  @override
  State<ImageInfoOverlay> createState() => _ImageInfoOverlayState();
}

class _ImageInfoOverlayState extends State<ImageInfoOverlay> {
  late Future<ImageMetadata> _metadataFuture;

  @override
  void initState() {
    super.initState();
    _metadataFuture = ImageMetadata.load(widget.imagePath);
  }

  @override
  void didUpdateWidget(covariant ImageInfoOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _metadataFuture = ImageMetadata.load(widget.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final runtimeResolution = widget.viewState.imageInfo?.pixelSize;

    return FutureBuilder<ImageMetadata>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        final metadata = snapshot.data;
        final resolutionLabel = runtimeResolution == null
            ? metadata?.embeddedResolution ?? l10n.loadingValue
            : '${runtimeResolution.width.round()} × ${runtimeResolution.height.round()}';

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
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
                      widget.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _InfoLine(
                      label: l10n.infoImageLabel,
                      value: l10n.infoImagePosition(
                        widget.currentIndex + 1,
                        widget.imageCount,
                      ),
                    ),
                    if (widget.caption.isNotEmpty)
                      _InfoLine(
                        label: l10n.captionLabel,
                        value: widget.caption,
                      ),
                    if (widget.tags.isNotEmpty)
                      _InfoLine(
                        label: l10n.tagsLabel,
                        value: widget.tags.join(', '),
                      ),
                    _InfoLine(
                      label: l10n.infoTypeLabel,
                      value: metadata?.typeLabel ?? '',
                    ),
                    _InfoLine(
                      label: l10n.infoResolutionLabel,
                      value: resolutionLabel,
                    ),
                    _InfoLine(
                      label: l10n.infoFileSizeLabel,
                      value: metadata?.fileSize == null
                          ? l10n.unknownValue
                          : _formatBytes(metadata!.fileSize!),
                    ),
                    if (metadata?.capturedAt != null)
                      _InfoLine(
                        label: l10n.infoCapturedLabel,
                        value: _formatDateTime(metadata!.capturedAt!),
                      ),
                    if (metadata?.modifiedAt != null)
                      _InfoLine(
                        label: l10n.infoModifiedLabel,
                        value: _formatDateTime(metadata!.modifiedAt!),
                      ),
                    if (metadata?.camera != null)
                      _InfoLine(
                        label: l10n.infoCameraLabel,
                        value: metadata!.camera!,
                      ),
                    if (metadata?.lens != null)
                      _InfoLine(
                        label: l10n.infoLensLabel,
                        value: metadata!.lens!,
                      ),
                    if (metadata?.focalLength != null)
                      _InfoLine(
                        label: l10n.infoFocalLengthLabel,
                        value: metadata!.focalLength!,
                      ),
                    if (metadata?.aperture != null)
                      _InfoLine(
                        label: l10n.infoApertureLabel,
                        value: metadata!.aperture!,
                      ),
                    if (metadata?.exposure != null)
                      _InfoLine(
                        label: l10n.infoExposureLabel,
                        value: metadata!.exposure!,
                      ),
                    if (metadata?.iso != null)
                      _InfoLine(
                        label: l10n.infoIsoLabel,
                        value: metadata!.iso!,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      widget.imagePath,
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
      },
    );
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

String _formatDateTime(DateTime value) {
  return DateFormat('MMM d, y • h:mm a').format(value);
}

String _formatBytes(int bytes) {
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
