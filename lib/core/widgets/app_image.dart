import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as p;

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.image,
    this.svgBytesLoader,
    this.revision = 0,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.cacheWidth,
    this.cacheHeight,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.opacity,
    this.assetName,
    this.filePath,
    this.bundle,
    this.package,
  });

  AppImage.file(
    String path, {
    super.key,
    this.revision = 0,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.cacheWidth,
    this.cacheHeight,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.opacity,
  }) : filePath = path,
       assetName = null,
       bundle = null,
       package = null,
       svgBytesLoader = _isSvgPath(path) ? SvgFileLoader(File(path)) : null,
       image = _isSvgPath(path) ? null : FileImage(File(path));

  AppImage.asset(
    this.assetName, {
    super.key,
    this.bundle,
    this.package,
    this.revision = 0,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.cacheWidth,
    this.cacheHeight,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.opacity,
  }) : filePath = null,
       svgBytesLoader = _isSvgPath(assetName!)
           ? SvgAssetLoader(
               assetName,
               assetBundle: bundle,
               packageName: package,
             )
           : null,
       image = _isSvgPath(assetName)
           ? null
           : AssetImage(assetName, bundle: bundle, package: package);

  final ImageProvider? image;

  /// Changes when the file at [filePath] was rewritten, forcing a reload.
  final int revision;
  final BytesLoader? svgBytesLoader;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;
  final FilterQuality filterQuality;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final int? cacheWidth;
  final int? cacheHeight;
  final ImageFrameBuilder? frameBuilder;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final Animation<double>? opacity;

  final String? assetName;
  final String? filePath;
  final AssetBundle? bundle;
  final String? package;

  bool get isSvg => svgBytesLoader != null;

  Object get providerIdentity => (
    image,
    svgBytesLoader,
    cacheWidth,
    cacheHeight,
    width,
    height,
    assetName,
    filePath,
    revision,
  );

  ImageProvider get imageProvider {
    final resolvedImage = image;
    if (resolvedImage == null) {
      throw StateError('SVG images do not expose a raster ImageProvider.');
    }

    return ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, resolvedImage);
  }

  Future<AppImageInfo> resolveInfo(BuildContext context) async {
    if (isSvg) {
      final pictureInfo = await vg.loadPicture(svgBytesLoader!, context);
      try {
        return AppImageInfo(pixelSize: pictureInfo.size, isVector: true);
      } finally {
        pictureInfo.picture.dispose();
      }
    }

    final completer = Completer<AppImageInfo>();
    final stream = imageProvider.resolve(
      createLocalImageConfiguration(context),
    );
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, _) {
        if (completer.isCompleted) {
          return;
        }
        completer.complete(
          AppImageInfo(
            pixelSize: Size(
              imageInfo.image.width.toDouble(),
              imageInfo.image.height.toDouble(),
            ),
          ),
        );
        stream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(exception, stackTrace);
        }
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (isSvg) {
      return SvgPicture(
        svgBytesLoader!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        alignment: alignment,
        matchTextDirection: matchTextDirection,
        semanticsLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        placeholderBuilder: loadingBuilder == null
            ? null
            : (context) =>
                  loadingBuilder!(context, const SizedBox.shrink(), null),
        errorBuilder: errorBuilder == null
            ? null
            : (context, error, stackTrace) =>
                  errorBuilder!(context, error, stackTrace),
      );
    }

    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      opacity: opacity,
    );
  }

  /// Drops cached decodes of the file at [path] (full size and the given
  /// thumbnail widths) so the next build reads it from disk again.
  static Future<void> evictFile(
    String path, {
    Iterable<int> cacheWidths = const <int>[],
  }) async {
    final provider = FileImage(File(path));
    await provider.evict();
    for (final width in cacheWidths) {
      await ResizeImage(provider, width: width).evict();
    }
  }

  static bool _isSvgPath(String path) {
    return p.extension(path).toLowerCase() == '.svg';
  }
}

@immutable
class AppImageInfo {
  const AppImageInfo({required this.pixelSize, this.isVector = false});

  final Size pixelSize;
  final bool isVector;
}
