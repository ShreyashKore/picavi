import 'dart:math' as math;
import 'dart:typed_data';

/// A face's box, relative to the image (0–1, top-left origin).
class FaceBox {
  const FaceBox(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  /// Overlap between two boxes: 0 (apart) to 1 (identical).
  double overlap(FaceBox other) {
    final w = math.max(
      0.0,
      math.min(right, other.right) - math.max(left, other.left),
    );
    final h = math.max(
      0.0,
      math.min(bottom, other.bottom) - math.max(top, other.top),
    );
    final intersection = w * h;
    final union = width * height + other.width * other.height - intersection;
    return union <= 0 ? 0 : intersection / union;
  }

  List<double> toJson() => [left, top, width, height];

  static FaceBox? fromJson(Object? json) {
    if (json is! List || json.length != 4) {
      return null;
    }
    final v = json.whereType<num>().map((n) => n.toDouble()).toList();
    return v.length == 4 ? FaceBox(v[0], v[1], v[2], v[3]) : null;
  }

  @override
  bool operator ==(Object other) =>
      other is FaceBox &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);
}

/// A named face, as stored next to the photo (portable, like Picasa's
/// `.picasa.ini` faces).
class PersonTag {
  const PersonTag(this.name, this.box);

  final String name;
  final FaceBox box;

  Map<String, Object?> toJson() => {'name': name, 'box': box.toJson()};

  static PersonTag? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final name = json['name'];
    final box = FaceBox.fromJson(json['box']);
    return name is String && name.trim().isNotEmpty && box != null
        ? PersonTag(name.trim(), box)
        : null;
  }

  @override
  bool operator ==(Object other) =>
      other is PersonTag && other.name == name && other.box == box;

  @override
  int get hashCode => Object.hash(name, box);
}

/// A face found by the detector.
class DetectedFace {
  const DetectedFace({required this.box, this.crop, this.print});

  final FaceBox box;

  /// A small square JPEG of the face, for display.
  final Uint8List? crop;

  /// A similarity fingerprint of the face (closer = more alike).
  final Float32List? print;
}

/// A face in the catalog.
class CatalogFace {
  const CatalogFace({
    required this.id,
    required this.path,
    required this.box,
    this.crop,
    this.print,
    this.name,
    this.ignored = false,
  });

  final int id;
  final String path;
  final FaceBox box;
  final Uint8List? crop;
  final Float32List? print;

  /// Who it is, once the user said so.
  final String? name;

  /// The user said this isn't a face worth naming.
  final bool ignored;
}

class PersonSummary {
  const PersonSummary({
    required this.name,
    required this.photoCount,
    required this.cover,
  });

  final String name;
  final int photoCount;

  /// One of their faces, for the card.
  final CatalogFace cover;
}
