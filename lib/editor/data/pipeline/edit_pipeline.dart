import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/rgba_image.dart';

/// Replays [operations] on a copy of [source]. Pure Dart so it can run in a
/// background isolate, and so the preview and the export share one
/// implementation.
RgbaImage applyEdits(RgbaImage source, List<EditOperation> operations) {
  var image = source.copy();
  for (final operation in operations) {
    image = applyEdit(image, operation);
  }
  return image;
}

/// Applies one operation. Colour operations work in place on [image];
/// geometric ones return a new image.
RgbaImage applyEdit(RgbaImage image, EditOperation operation) {
  switch (operation) {
    case CropEdit(:final rect):
      return cropImage(image, rect);
    case RotateEdit():
      return rotateQuarterTurns(image, operation.clockwiseTurns);
    case StraightenEdit():
      return straightenImage(image, operation.radians);
    case LevelsEdit(:final black, :final white, :final saturation):
      _applyLuts(
        image,
        _levelsLut(black[0], white[0]),
        _levelsLut(black[1], white[1]),
        _levelsLut(black[2], white[2]),
      );
      if (saturation != 0) {
        _saturate(image, saturation);
      }
      return image;
    case TuneEdit():
      _applyTune(image, operation);
      return image;
    case EffectEdit(:final kind, :final amount):
      _applyEffect(image, kind, amount);
      return image;
    case RedEyeEdit(:final spots):
      _removeRedEye(image, spots);
      return image;
  }
}

// ---------------------------------------------------------------------------
// Geometry

RgbaImage cropImage(RgbaImage image, NormalizedRect rect) {
  final clamped = rect.clamped(minSize: 0);
  final left = (clamped.left * image.width).round().clamp(0, image.width - 1);
  final top = (clamped.top * image.height).round().clamp(0, image.height - 1);
  final right = (clamped.right * image.width).round().clamp(
    left + 1,
    image.width,
  );
  final bottom = (clamped.bottom * image.height).round().clamp(
    top + 1,
    image.height,
  );
  if (left == 0 && top == 0 && right == image.width && bottom == image.height) {
    return image;
  }

  final width = right - left;
  final height = bottom - top;
  final result = RgbaImage.blank(width, height);
  final rowBytes = width * 4;
  for (var y = 0; y < height; y++) {
    final from = ((top + y) * image.width + left) * 4;
    result.pixels.setRange(
      y * rowBytes,
      (y + 1) * rowBytes,
      image.pixels,
      from,
    );
  }
  return result;
}

RgbaImage rotateQuarterTurns(RgbaImage image, int clockwiseTurns) {
  final turns = clockwiseTurns % 4;
  if (turns == 0) {
    return image;
  }
  final w = image.width;
  final h = image.height;
  final swap = turns.isOdd;
  final result = RgbaImage.blank(swap ? h : w, swap ? w : h);
  final aligned = image.pixels.offsetInBytes % 4 == 0
      ? image.pixels
      : Uint8List.fromList(image.pixels);
  final src = aligned.buffer.asUint32List(aligned.offsetInBytes, w * h);
  final dst = result.pixels.buffer.asUint32List(
    0,
    result.width * result.height,
  );
  final outWidth = result.width;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final int dx;
      final int dy;
      switch (turns) {
        case 1:
          dx = h - 1 - y;
          dy = x;
        case 2:
          dx = w - 1 - x;
          dy = h - 1 - y;
        default:
          dx = y;
          dy = w - 1 - x;
      }
      dst[dy * outWidth + dx] = src[y * w + x];
    }
  }
  return result;
}

/// The fraction of the image's width and height left after straightening
/// by [radians]: the largest same-aspect rectangle inside the rotated image.
double straightenScale(int width, int height, double radians) {
  final c = math.cos(radians.abs());
  final s = math.sin(radians.abs());
  return math.min(
    width / (width * c + height * s),
    height / (width * s + height * c),
  );
}

RgbaImage straightenImage(RgbaImage image, double radians) {
  if (radians.abs() < 1e-6) {
    return image;
  }
  final w = image.width;
  final h = image.height;
  final scale = straightenScale(w, h, radians);
  final outWidth = math.max(1, (w * scale).floor());
  final outHeight = math.max(1, (h * scale).floor());
  final result = RgbaImage.blank(outWidth, outHeight);
  final cos = math.cos(radians);
  final sin = math.sin(radians);
  final src = image.pixels;
  final dst = result.pixels;

  var out = 0;
  for (var v = 0; v < outHeight; v++) {
    final dv = v + 0.5 - outHeight / 2;
    for (var u = 0; u < outWidth; u++) {
      final du = u + 0.5 - outWidth / 2;
      // Inverse of a clockwise rotation (y points down).
      final sx = (du * cos + dv * sin + w / 2 - 0.5).clamp(0.0, w - 1.0);
      final sy = (-du * sin + dv * cos + h / 2 - 0.5).clamp(0.0, h - 1.0);
      final x0 = sx.floor();
      final y0 = sy.floor();
      final x1 = math.min(x0 + 1, w - 1);
      final y1 = math.min(y0 + 1, h - 1);
      final fx = sx - x0;
      final fy = sy - y0;
      final i00 = (y0 * w + x0) * 4;
      final i10 = (y0 * w + x1) * 4;
      final i01 = (y1 * w + x0) * 4;
      final i11 = (y1 * w + x1) * 4;
      for (var c = 0; c < 4; c++) {
        final top = src[i00 + c] + (src[i10 + c] - src[i00 + c]) * fx;
        final bottom = src[i01 + c] + (src[i11 + c] - src[i01 + c]) * fx;
        dst[out + c] = (top + (bottom - top) * fy).round();
      }
      out += 4;
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
// Colour

Uint8List _levelsLut(int black, int white) {
  final lut = Uint8List(256);
  final range = math.max(1, white - black);
  for (var i = 0; i < 256; i++) {
    lut[i] = ((i - black) * 255 / range).round().clamp(0, 255);
  }
  return lut;
}

void _applyLuts(RgbaImage image, Uint8List r, Uint8List g, Uint8List b) {
  final px = image.pixels;
  for (var i = 0; i < px.length; i += 4) {
    px[i] = r[px[i]];
    px[i + 1] = g[px[i + 1]];
    px[i + 2] = b[px[i + 2]];
  }
}

void _applyTune(RgbaImage image, TuneEdit tune) {
  if (tune.isNeutral) {
    return;
  }
  final fillExponent = 1 + tune.fillLight * 1.2;
  final highlightDivisor = 1 - tune.highlights * 0.35;
  final shadowPoint = tune.shadows * 0.25;

  double curve(double x) {
    var v = x;
    if (tune.fillLight > 0) {
      v = 1 - math.pow(1 - v, fillExponent).toDouble();
    }
    if (tune.highlights > 0) {
      v = math.min(1, v / highlightDivisor);
    }
    if (tune.shadows > 0) {
      v = math.max(0, (v - shadowPoint) / (1 - shadowPoint));
    }
    return v;
  }

  final redGain = 1 + tune.temperature * 0.15;
  final greenGain = 1 + tune.temperature * 0.03;
  final blueGain = 1 - tune.temperature * 0.15;
  final r = Uint8List(256);
  final g = Uint8List(256);
  final b = Uint8List(256);
  for (var i = 0; i < 256; i++) {
    final v = curve(i / 255) * 255;
    r[i] = (v * redGain).round().clamp(0, 255);
    g[i] = (v * greenGain).round().clamp(0, 255);
    b[i] = (v * blueGain).round().clamp(0, 255);
  }
  _applyLuts(image, r, g, b);
}

int _clampByte(double value) => value < 0
    ? 0
    : value > 255
    ? 255
    : value.round();

double _luma(int r, int g, int b) => 0.299 * r + 0.587 * g + 0.114 * b;

void _saturate(RgbaImage image, double amount) {
  final factor = 1 + amount;
  final px = image.pixels;
  for (var i = 0; i < px.length; i += 4) {
    final lum = _luma(px[i], px[i + 1], px[i + 2]);
    px[i] = _clampByte(lum + (px[i] - lum) * factor);
    px[i + 1] = _clampByte(lum + (px[i + 1] - lum) * factor);
    px[i + 2] = _clampByte(lum + (px[i + 2] - lum) * factor);
  }
}

void _applyEffect(RgbaImage image, EffectKind kind, double rawAmount) {
  final amount = rawAmount.clamp(kind.minAmount, kind.maxAmount);
  if (amount == 0) {
    return;
  }
  final px = image.pixels;
  switch (kind) {
    case EffectKind.blackAndWhite:
      for (var i = 0; i < px.length; i += 4) {
        final lum = _luma(px[i], px[i + 1], px[i + 2]);
        px[i] = _clampByte(px[i] + (lum - px[i]) * amount);
        px[i + 1] = _clampByte(px[i + 1] + (lum - px[i + 1]) * amount);
        px[i + 2] = _clampByte(px[i + 2] + (lum - px[i + 2]) * amount);
      }
    case EffectKind.sepia:
      for (var i = 0; i < px.length; i += 4) {
        final r = px[i];
        final g = px[i + 1];
        final b = px[i + 2];
        final sr = 0.393 * r + 0.769 * g + 0.189 * b;
        final sg = 0.349 * r + 0.686 * g + 0.168 * b;
        final sb = 0.272 * r + 0.534 * g + 0.131 * b;
        px[i] = _clampByte(r + (sr - r) * amount);
        px[i + 1] = _clampByte(g + (sg - g) * amount);
        px[i + 2] = _clampByte(b + (sb - b) * amount);
      }
    case EffectKind.warmify:
      _applyTune(image, TuneEdit(temperature: amount * 0.8));
      _saturate(image, amount * 0.15);
    case EffectKind.saturation:
      _saturate(image, amount);
    case EffectKind.sharpen:
      final blurred = boxBlur(image, 1, passes: 1);
      final factor = amount * 1.5;
      for (var i = 0; i < px.length; i += 4) {
        for (var c = 0; c < 3; c++) {
          final v = px[i + c];
          px[i + c] = _clampByte(v + (v - blurred[i + c]) * factor);
        }
      }
    case EffectKind.softFocus:
      final radius = math.max(
        1,
        (math.min(image.width, image.height) * 0.012).round(),
      );
      final blurred = boxBlur(image, radius);
      _blendRadial(image, blurred, (distance) {
        return amount * 0.85 * _smoothStep(0.15, 0.75, distance);
      });
    case EffectKind.glow:
      final radius = math.max(
        1,
        (math.min(image.width, image.height) * 0.02).round(),
      );
      final blurred = boxBlur(image, radius);
      final mix = amount * 0.6;
      for (var i = 0; i < px.length; i += 4) {
        for (var c = 0; c < 3; c++) {
          final v = px[i + c];
          final screen = 255 - (255 - v) * (255 - blurred[i + c]) / 255;
          px[i + c] = _clampByte(v + (screen - v) * mix);
        }
      }
    case EffectKind.filmGrain:
      // Deterministic so re-rendering gives the same grain.
      var seed =
          0x2F6E2B1 ^ (image.width * 73856093) ^ (image.height * 19349663);
      final strength = amount * 48;
      for (var i = 0; i < px.length; i += 4) {
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
        final noise = ((seed >> 8) & 0xFF) / 255 - 0.5;
        final delta = noise * strength;
        px[i] = _clampByte(px[i] + delta);
        px[i + 1] = _clampByte(px[i + 1] + delta);
        px[i + 2] = _clampByte(px[i + 2] + delta);
      }
    case EffectKind.vignette:
      final w = image.width;
      final h = image.height;
      final cx = w / 2;
      final cy = h / 2;
      final maxDistance = math.sqrt(cx * cx + cy * cy);
      var i = 0;
      for (var y = 0; y < h; y++) {
        final dy = y + 0.5 - cy;
        for (var x = 0; x < w; x++) {
          final dx = x + 0.5 - cx;
          final distance = math.sqrt(dx * dx + dy * dy) / maxDistance;
          final factor = 1 - amount * 0.75 * _smoothStep(0.35, 1.0, distance);
          px[i] = _clampByte(px[i] * factor);
          px[i + 1] = _clampByte(px[i + 1] * factor);
          px[i + 2] = _clampByte(px[i + 2] * factor);
          i += 4;
        }
      }
  }
}

double _smoothStep(double edge0, double edge1, double x) {
  final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

/// Mixes [other] into [image] with a weight that depends on the distance
/// from the centre (0 at the centre, 1 at the corners).
void _blendRadial(
  RgbaImage image,
  Uint8List other,
  double Function(double distance) weightAt,
) {
  final w = image.width;
  final h = image.height;
  final cx = w / 2;
  final cy = h / 2;
  final maxDistance = math.sqrt(cx * cx + cy * cy);
  final px = image.pixels;
  var i = 0;
  for (var y = 0; y < h; y++) {
    final dy = y + 0.5 - cy;
    for (var x = 0; x < w; x++) {
      final dx = x + 0.5 - cx;
      final weight = weightAt(math.sqrt(dx * dx + dy * dy) / maxDistance);
      if (weight > 0) {
        for (var c = 0; c < 3; c++) {
          px[i + c] = _clampByte(
            px[i + c] + (other[i + c] - px[i + c]) * weight,
          );
        }
      }
      i += 4;
    }
  }
}

/// A blurred copy of [image]'s pixels: [passes] separable box blurs, which
/// together approximate a Gaussian.
Uint8List boxBlur(RgbaImage image, int radius, {int passes = 3}) {
  final w = image.width;
  final h = image.height;
  var current = Uint8List.fromList(image.pixels);
  var scratch = Uint8List(current.length);
  for (var pass = 0; pass < passes; pass++) {
    _blurRows(current, scratch, w, h, radius);
    _blurColumns(scratch, current, w, h, radius);
  }
  return current;
}

void _blurRows(Uint8List src, Uint8List dst, int w, int h, int radius) {
  final window = radius * 2 + 1;
  for (var y = 0; y < h; y++) {
    final row = y * w * 4;
    for (var c = 0; c < 4; c++) {
      var sum = 0;
      for (var k = -radius; k <= radius; k++) {
        sum += src[row + k.clamp(0, w - 1) * 4 + c];
      }
      for (var x = 0; x < w; x++) {
        dst[row + x * 4 + c] = sum ~/ window;
        final out = (x - radius).clamp(0, w - 1);
        final into = (x + radius + 1).clamp(0, w - 1);
        sum += src[row + into * 4 + c] - src[row + out * 4 + c];
      }
    }
  }
}

void _blurColumns(Uint8List src, Uint8List dst, int w, int h, int radius) {
  final window = radius * 2 + 1;
  final stride = w * 4;
  for (var x = 0; x < w; x++) {
    for (var c = 0; c < 4; c++) {
      final column = x * 4 + c;
      var sum = 0;
      for (var k = -radius; k <= radius; k++) {
        sum += src[k.clamp(0, h - 1) * stride + column];
      }
      for (var y = 0; y < h; y++) {
        dst[y * stride + column] = sum ~/ window;
        final out = (y - radius).clamp(0, h - 1);
        final into = (y + radius + 1).clamp(0, h - 1);
        sum += src[into * stride + column] - src[out * stride + column];
      }
    }
  }
}

void _removeRedEye(RgbaImage image, List<RedEyeSpot> spots) {
  final w = image.width;
  final h = image.height;
  final shortSide = math.min(w, h);
  final px = image.pixels;
  for (final spot in spots) {
    final cx = spot.x * w;
    final cy = spot.y * h;
    final radius = math.max(1.0, spot.radius * shortSide);
    final x0 = math.max(0, (cx - radius).floor());
    final x1 = math.min(w - 1, (cx + radius).ceil());
    final y0 = math.max(0, (cy - radius).floor());
    final y1 = math.min(h - 1, (cy + radius).ceil());
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final dx = x + 0.5 - cx;
        final dy = y + 0.5 - cy;
        final distance = math.sqrt(dx * dx + dy * dy) / radius;
        if (distance > 1) {
          continue;
        }
        final i = (y * w + x) * 4;
        final r = px[i];
        final g = px[i + 1];
        final b = px[i + 2];
        final others = (g + b) / 2;
        if (r < 50 || r < others * 1.3) {
          continue;
        }
        final weight = 1 - _smoothStep(0.7, 1.0, distance);
        px[i] = _clampByte(r + (others - r) * weight);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Automatic fixes

/// Measures [image] and returns levels that stretch its tones (and, for
/// [AutoFixKind.autoColor] / [AutoFixKind.feelingLucky], neutralise colour
/// casts by stretching each channel on its own).
LevelsEdit measureAutoFix(RgbaImage image, AutoFixKind kind) {
  final histograms = List.generate(4, (_) => Int32List(256));
  final px = image.pixels;
  var counted = 0;
  for (var i = 0; i < px.length; i += 4) {
    if (px[i + 3] < 16) {
      continue; // Ignore transparent pixels.
    }
    final r = px[i];
    final g = px[i + 1];
    final b = px[i + 2];
    histograms[0][r] += 1;
    histograms[1][g] += 1;
    histograms[2][b] += 1;
    histograms[3][_luma(r, g, b).round()] += 1;
    counted += 1;
  }

  if (counted == 0) {
    return LevelsEdit(
      kind: kind,
      black: const [0, 0, 0],
      white: const [255, 255, 255],
    );
  }

  (int, int) bounds(Int32List histogram) {
    final clip = counted * 0.005;
    var low = 0;
    var seen = 0;
    while (low < 255 && seen + histogram[low] <= clip) {
      seen += histogram[low];
      low += 1;
    }
    var high = 255;
    seen = 0;
    while (high > 0 && seen + histogram[high] <= clip) {
      seen += histogram[high];
      high -= 1;
    }
    // Don't stretch wildly: a nearly flat image stays nearly flat.
    low = math.min(low, 64);
    high = math.max(high, 191);
    return (low, high);
  }

  final List<int> black;
  final List<int> white;
  if (kind == AutoFixKind.autoContrast) {
    final (low, high) = bounds(histograms[3]);
    black = [low, low, low];
    white = [high, high, high];
  } else {
    final channels = [for (var c = 0; c < 3; c++) bounds(histograms[c])];
    black = [for (final (low, _) in channels) low];
    white = [for (final (_, high) in channels) high];
  }

  return LevelsEdit(
    kind: kind,
    black: black,
    white: white,
    saturation: kind == AutoFixKind.feelingLucky ? 0.15 : 0,
  );
}
