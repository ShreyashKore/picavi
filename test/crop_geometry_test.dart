import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/presentation/models/crop_geometry.dart';

void main() {
  const image = Size(400, 200);

  double pixelAspect(NormalizedRect rect) =>
      rect.width * image.width / (rect.height * image.height);

  test('centred crops fill the image in one direction', () {
    final square = centeredCrop(1, image);
    expect(square.top, 0);
    expect(square.bottom, 1);
    expect(pixelAspect(square), closeTo(1, 1e-9));

    final wide = centeredCrop(4, image);
    expect(wide.left, 0);
    expect(pixelAspect(wide), closeTo(4, 1e-9));
  });

  test('presets follow the requested orientation', () {
    expect(CropAspectPreset.free.ratio(image, portrait: false), isNull);
    expect(CropAspectPreset.print4x6.ratio(image, portrait: false), 1.5);
    expect(CropAspectPreset.print4x6.ratio(image, portrait: true), 1 / 1.5);
    expect(CropAspectPreset.original.ratio(image, portrait: false), 2);
  });

  test('moving stays inside the image', () {
    const start = NormalizedRect(0.1, 0.1, 0.5, 0.5);

    final moved = dragCrop(start, CropHandle.move, -1, 0.2, imageSize: image);

    expect(moved.left, 0);
    expect(moved.width, closeTo(0.4, 1e-9));
    expect(moved.top, closeTo(0.3, 1e-9));
  });

  test('free resizing never inverts or leaves the image', () {
    const start = NormalizedRect(0.2, 0.2, 0.8, 0.8);

    final dragged = dragCrop(
      start,
      CropHandle.topLeft,
      2,
      -1,
      imageSize: image,
    );

    expect(dragged.top, 0);
    expect(dragged.left, lessThan(dragged.right));
    expect(dragged.right, 0.8);
  });

  test('corner drags keep the shape and the opposite corner', () {
    const start = NormalizedRect(0.25, 0, 0.75, 1); // 200×200 px, square.

    final dragged = dragCrop(
      start,
      CropHandle.bottomRight,
      -0.1,
      -0.3,
      imageSize: image,
      aspect: 1,
    );

    expect(dragged.left, 0.25);
    expect(dragged.top, 0);
    expect(pixelAspect(dragged), closeTo(1, 1e-9));
    expect(dragged.width, lessThan(start.width));
  });

  test('a fixed shape is limited by the image edge', () {
    const start = NormalizedRect(0.25, 0, 0.75, 1);

    final dragged = dragCrop(
      start,
      CropHandle.bottomRight,
      1,
      1,
      imageSize: image,
      aspect: 1,
    );

    expect(dragged.bottom, closeTo(1, 1e-9));
    expect(pixelAspect(dragged), closeTo(1, 1e-9));
  });
}
