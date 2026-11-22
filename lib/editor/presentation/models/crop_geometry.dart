import 'dart:math' as math;
import 'dart:ui' show Size;

import '../../domain/entities/edit_operation.dart';

enum CropHandle {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
  move;

  bool get isCorner =>
      this == topLeft ||
      this == topRight ||
      this == bottomRight ||
      this == bottomLeft;

  bool get movesLeft => this == topLeft || this == left || this == bottomLeft;
  bool get movesRight =>
      this == topRight || this == right || this == bottomRight;
  bool get movesTop => this == topLeft || this == top || this == topRight;
  bool get movesBottom =>
      this == bottomLeft || this == bottom || this == bottomRight;
}

/// Crop shapes, named after the print sizes Picasa offered.
enum CropAspectPreset {
  free,
  original,
  square,
  print4x6,
  print5x7,
  print8x10,
  wide16x9;

  /// Width ÷ height in landscape form, or null for a free crop.
  double? landscapeRatio(Size imageSize) => switch (this) {
    free => null,
    original =>
      math.max(imageSize.width, imageSize.height) /
          math.min(imageSize.width, imageSize.height),
    square => 1,
    print4x6 => 3 / 2,
    print5x7 => 7 / 5,
    print8x10 => 5 / 4,
    wide16x9 => 16 / 9,
  };

  /// Width ÷ height for the requested orientation, or null for free.
  double? ratio(Size imageSize, {required bool portrait}) {
    final landscape = landscapeRatio(imageSize);
    if (landscape == null) {
      return null;
    }
    return portrait ? 1 / landscape : landscape;
  }
}

/// The largest crop with [aspect] (width ÷ height, in pixels) centred in an
/// image of [imageSize].
NormalizedRect centeredCrop(double aspect, Size imageSize) {
  final imageAspect = imageSize.width / imageSize.height;
  if (imageAspect > aspect) {
    final width = aspect / imageAspect;
    return NormalizedRect((1 - width) / 2, 0, (1 + width) / 2, 1);
  }
  final height = imageAspect / aspect;
  return NormalizedRect(0, (1 - height) / 2, 1, (1 + height) / 2);
}

/// [start] after dragging [handle] by ([dx], [dy]) in normalised units. With
/// an [aspect] the shape is kept (corners only), and the rectangle never
/// leaves the image or shrinks below [minSize] of the shorter side.
NormalizedRect dragCrop(
  NormalizedRect start,
  CropHandle handle,
  double dx,
  double dy, {
  required Size imageSize,
  double? aspect,
  double minSize = 0.05,
}) {
  final w = imageSize.width;
  final h = imageSize.height;
  var left = start.left * w;
  var top = start.top * h;
  var right = start.right * w;
  var bottom = start.bottom * h;
  final moveX = dx * w;
  final moveY = dy * h;
  final minimum = minSize * math.min(w, h);

  if (handle == CropHandle.move) {
    final shiftX = moveX.clamp(-left, w - right);
    final shiftY = moveY.clamp(-top, h - bottom);
    return NormalizedRect(
      (left + shiftX) / w,
      (top + shiftY) / h,
      (right + shiftX) / w,
      (bottom + shiftY) / h,
    );
  }

  if (aspect == null || !handle.isCorner) {
    if (handle.movesLeft) {
      left = (left + moveX).clamp(0, right - minimum);
    }
    if (handle.movesRight) {
      right = (right + moveX).clamp(left + minimum, w);
    }
    if (handle.movesTop) {
      top = (top + moveY).clamp(0, bottom - minimum);
    }
    if (handle.movesBottom) {
      bottom = (bottom + moveY).clamp(top + minimum, h);
    }
    return NormalizedRect(left / w, top / h, right / w, bottom / h);
  }

  // Corner with a fixed shape: the opposite corner stays put.
  final anchorX = handle.movesLeft ? right : left;
  final anchorY = handle.movesTop ? bottom : top;
  final cornerX = (handle.movesLeft ? left : right) + moveX;
  final cornerY = (handle.movesTop ? top : bottom) + moveY;
  var width = math.max(
    (cornerX - anchorX).abs(),
    (cornerY - anchorY).abs() * aspect,
  );
  var height = width / aspect;
  final maxWidth = handle.movesLeft ? anchorX : w - anchorX;
  final maxHeight = handle.movesTop ? anchorY : h - anchorY;
  if (width > maxWidth) {
    width = maxWidth;
    height = width / aspect;
  }
  if (height > maxHeight) {
    height = maxHeight;
    width = height * aspect;
  }
  if (math.min(width, height) < minimum) {
    final grow = minimum / math.min(width, height);
    width *= grow;
    height *= grow;
  }
  left = handle.movesLeft ? anchorX - width : anchorX;
  right = handle.movesLeft ? anchorX : anchorX + width;
  top = handle.movesTop ? anchorY - height : anchorY;
  bottom = handle.movesTop ? anchorY : anchorY + height;
  return NormalizedRect(left / w, top / h, right / w, bottom / h);
}
