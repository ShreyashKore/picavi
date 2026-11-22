import 'dart:math' as math;

/// A rectangle in coordinates relative to an image: (0, 0) is the top-left
/// corner and (1, 1) the bottom-right, whatever the image's pixel size.
class NormalizedRect {
  const NormalizedRect(this.left, this.top, this.right, this.bottom);

  static const NormalizedRect full = NormalizedRect(0, 0, 1, 1);

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  bool get isFull => left <= 0 && top <= 0 && right >= 1 && bottom >= 1;

  /// Clamped into the unit square with at least [minSize] on each side.
  NormalizedRect clamped({double minSize = 0.01}) {
    final l = left.clamp(0.0, 1.0 - minSize);
    final t = top.clamp(0.0, 1.0 - minSize);
    final r = right.clamp(l + minSize, 1.0);
    final b = bottom.clamp(t + minSize, 1.0);
    return NormalizedRect(l, t, r, b);
  }

  List<double> toJson() => [left, top, right, bottom];

  static NormalizedRect? fromJson(Object? json) {
    if (json is! List || json.length != 4) {
      return null;
    }
    final values = json.whereType<num>().map((v) => v.toDouble()).toList();
    if (values.length != 4) {
      return null;
    }
    return NormalizedRect(values[0], values[1], values[2], values[3]);
  }

  @override
  bool operator ==(Object other) =>
      other is NormalizedRect &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'NormalizedRect($left, $top, $right, $bottom)';
}

/// One step of a non-destructive edit. Edits are applied in order; any
/// coordinates are relative to the image as it is at that step.
sealed class EditOperation {
  const EditOperation();

  String get type;

  Map<String, Object?> toJson();

  /// Parses one operation, or returns null for unknown/corrupt entries so a
  /// sidecar written by a newer version doesn't break older ones.
  static EditOperation? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    double? number(String key) => (json[key] as num?)?.toDouble();
    try {
      switch (json['op']) {
        case 'crop':
          final rect = NormalizedRect.fromJson(json['rect']);
          return rect == null ? null : CropEdit(rect.clamped());
        case 'rotate':
          final turns = (json['turns'] as num?)?.toInt();
          return turns == null ? null : RotateEdit(turns);
        case 'straighten':
          final degrees = number('degrees');
          return degrees == null ? null : StraightenEdit(degrees);
        case 'levels':
          final kind = AutoFixKind.values.asNameMap()[json['kind']];
          final black = _rgb(json['black']);
          final white = _rgb(json['white']);
          if (kind == null || black == null || white == null) {
            return null;
          }
          return LevelsEdit(
            kind: kind,
            black: black,
            white: white,
            saturation: number('saturation') ?? 0,
          );
        case 'tune':
          return TuneEdit(
            fillLight: number('fillLight') ?? 0,
            highlights: number('highlights') ?? 0,
            shadows: number('shadows') ?? 0,
            temperature: number('temperature') ?? 0,
          );
        case 'effect':
          final kind = EffectKind.values.asNameMap()[json['kind']];
          final amount = number('amount');
          return kind == null || amount == null
              ? null
              : EffectEdit(kind, amount);
        case 'redEye':
          final spots = (json['spots'] as List?)
              ?.map(RedEyeSpot.fromJson)
              .whereType<RedEyeSpot>()
              .toList();
          return spots == null || spots.isEmpty ? null : RedEyeEdit(spots);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static List<int>? _rgb(Object? json) {
    if (json is! List || json.length != 3) {
      return null;
    }
    final values = json.whereType<num>().map((v) => v.toInt()).toList();
    return values.length == 3 ? values : null;
  }
}

/// Keeps only [rect] of the image.
class CropEdit extends EditOperation {
  const CropEdit(this.rect);

  final NormalizedRect rect;

  @override
  String get type => 'crop';

  @override
  Map<String, Object?> toJson() => {'op': type, 'rect': rect.toJson()};

  @override
  bool operator ==(Object other) => other is CropEdit && other.rect == rect;

  @override
  int get hashCode => Object.hash(type, rect);
}

/// Rotates by quarter turns clockwise (negative turns go anticlockwise).
class RotateEdit extends EditOperation {
  const RotateEdit(this.turns);

  final int turns;

  /// Normalised to 0–3.
  int get clockwiseTurns => turns % 4;

  @override
  String get type => 'rotate';

  @override
  Map<String, Object?> toJson() => {'op': type, 'turns': turns};

  @override
  bool operator ==(Object other) => other is RotateEdit && other.turns == turns;

  @override
  int get hashCode => Object.hash(type, turns);
}

/// Rotates by a small angle (clockwise positive) and crops to the largest
/// rectangle with the original aspect ratio, so no empty corners show.
class StraightenEdit extends EditOperation {
  const StraightenEdit(this.degrees);

  /// Range offered by the straighten slider.
  static const double maxDegrees = 20;

  final double degrees;

  double get radians => degrees * math.pi / 180;

  @override
  String get type => 'straighten';

  @override
  Map<String, Object?> toJson() => {'op': type, 'degrees': degrees};

  @override
  bool operator ==(Object other) =>
      other is StraightenEdit && other.degrees == degrees;

  @override
  int get hashCode => Object.hash(type, degrees);
}

enum AutoFixKind { autoContrast, autoColor, feelingLucky }

/// Per-channel levels: input [black] maps to 0 and [white] to 255. The
/// values are measured once when the fix is applied, so the result doesn't
/// depend on the resolution it is later rendered at.
class LevelsEdit extends EditOperation {
  const LevelsEdit({
    required this.kind,
    required this.black,
    required this.white,
    this.saturation = 0,
  });

  final AutoFixKind kind;
  final List<int> black;
  final List<int> white;

  /// Extra saturation, -1–1 (used by "I'm Feeling Lucky").
  final double saturation;

  @override
  String get type => 'levels';

  @override
  Map<String, Object?> toJson() => {
    'op': type,
    'kind': kind.name,
    'black': black,
    'white': white,
    if (saturation != 0) 'saturation': saturation,
  };

  @override
  bool operator ==(Object other) =>
      other is LevelsEdit &&
      other.kind == kind &&
      _listEquals(other.black, black) &&
      _listEquals(other.white, white) &&
      other.saturation == saturation;

  @override
  int get hashCode => Object.hash(
    type,
    kind,
    Object.hashAll(black),
    Object.hashAll(white),
    saturation,
  );
}

/// Picasa-style tuning. [fillLight], [highlights] and [shadows] run 0–1;
/// [temperature] runs -1 (cooler) to 1 (warmer).
class TuneEdit extends EditOperation {
  const TuneEdit({
    this.fillLight = 0,
    this.highlights = 0,
    this.shadows = 0,
    this.temperature = 0,
  });

  final double fillLight;
  final double highlights;
  final double shadows;
  final double temperature;

  bool get isNeutral =>
      fillLight == 0 && highlights == 0 && shadows == 0 && temperature == 0;

  TuneEdit copyWith({
    double? fillLight,
    double? highlights,
    double? shadows,
    double? temperature,
  }) {
    return TuneEdit(
      fillLight: fillLight ?? this.fillLight,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      temperature: temperature ?? this.temperature,
    );
  }

  @override
  String get type => 'tune';

  @override
  Map<String, Object?> toJson() => {
    'op': type,
    'fillLight': fillLight,
    'highlights': highlights,
    'shadows': shadows,
    'temperature': temperature,
  };

  @override
  bool operator ==(Object other) =>
      other is TuneEdit &&
      other.fillLight == fillLight &&
      other.highlights == highlights &&
      other.shadows == shadows &&
      other.temperature == temperature;

  @override
  int get hashCode =>
      Object.hash(type, fillLight, highlights, shadows, temperature);
}

enum EffectKind {
  blackAndWhite(defaultAmount: 1),
  sepia(defaultAmount: 1),
  warmify(defaultAmount: 0.5),
  saturation(defaultAmount: 0.4, minAmount: -1),
  sharpen(defaultAmount: 0.5),
  softFocus(defaultAmount: 0.5),
  glow(defaultAmount: 0.4),
  filmGrain(defaultAmount: 0.4),
  vignette(defaultAmount: 0.5);

  const EffectKind({required this.defaultAmount, this.minAmount = 0});

  final double defaultAmount;
  final double minAmount;
  double get maxAmount => 1;
}

/// A one-slider effect; [amount] runs from [EffectKind.minAmount] to 1.
class EffectEdit extends EditOperation {
  const EffectEdit(this.kind, this.amount);

  final EffectKind kind;
  final double amount;

  @override
  String get type => 'effect';

  @override
  Map<String, Object?> toJson() => {
    'op': type,
    'kind': kind.name,
    'amount': amount,
  };

  @override
  bool operator ==(Object other) =>
      other is EffectEdit && other.kind == kind && other.amount == amount;

  @override
  int get hashCode => Object.hash(type, kind, amount);
}

/// A circle to clear red-eye in. The centre is relative to the image size;
/// the radius is relative to the image's shorter side.
class RedEyeSpot {
  const RedEyeSpot(this.x, this.y, this.radius);

  final double x;
  final double y;
  final double radius;

  List<double> toJson() => [x, y, radius];

  static RedEyeSpot? fromJson(Object? json) {
    if (json is! List || json.length != 3) {
      return null;
    }
    final values = json.whereType<num>().map((v) => v.toDouble()).toList();
    return values.length == 3
        ? RedEyeSpot(values[0], values[1], values[2])
        : null;
  }

  @override
  bool operator ==(Object other) =>
      other is RedEyeSpot &&
      other.x == x &&
      other.y == y &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(x, y, radius);
}

class RedEyeEdit extends EditOperation {
  const RedEyeEdit(this.spots);

  final List<RedEyeSpot> spots;

  @override
  String get type => 'redEye';

  @override
  Map<String, Object?> toJson() => {
    'op': type,
    'spots': [for (final spot in spots) spot.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is RedEyeEdit && _listEquals(other.spots, spots);

  @override
  int get hashCode => Object.hash(type, Object.hashAll(spots));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
