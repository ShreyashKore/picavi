import 'dart:io';

import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.image,
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
  });

  AppImage.file(
    String path, {
    super.key,
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
  }) : image = FileImage(File(path));

  AppImage.asset(
    String assetName, {
    super.key,
    AssetBundle? bundle,
    String? package,
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
  }) : image = AssetImage(assetName, bundle: bundle, package: package);

  final ImageProvider image;
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

  Object get providerIdentity => (image, cacheWidth, cacheHeight);

  ImageProvider get imageProvider {
    return ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, image);
  }

  @override
  Widget build(BuildContext context) {
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
}

@immutable
class AppImageInfo {
  const AppImageInfo({required this.pixelSize});

  final Size pixelSize;
}
