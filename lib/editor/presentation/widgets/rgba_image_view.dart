import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/services/rgba_conversions.dart';
import '../../domain/entities/rgba_image.dart';

/// Paints an [RgbaImage]. While a new image is being uploaded the previous
/// one stays on screen, so slider moves don't flicker.
class RgbaImageView extends StatefulWidget {
  const RgbaImageView({super.key, required this.image});

  final RgbaImage image;

  @override
  State<RgbaImageView> createState() => _RgbaImageViewState();
}

class _RgbaImageViewState extends State<RgbaImageView> {
  ui.Image? _uiImage;
  RgbaImage? _shown;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_upload(widget.image));
  }

  @override
  void didUpdateWidget(RgbaImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.image, widget.image)) {
      unawaited(_upload(widget.image));
    }
  }

  Future<void> _upload(RgbaImage image) async {
    final generation = ++_generation;
    final uploaded = await uiImageFromRgba(image);
    if (!mounted || generation != _generation) {
      uploaded.dispose();
      return;
    }
    final previous = _uiImage;
    setState(() {
      _uiImage = uploaded;
      _shown = image;
    });
    previous?.dispose();
  }

  @override
  void dispose() {
    _uiImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _uiImage;
    if (image == null || _shown == null) {
      return const SizedBox.expand();
    }
    return RawImage(
      image: image,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
    );
  }
}
