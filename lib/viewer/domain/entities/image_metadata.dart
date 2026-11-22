import 'dart:io';

import 'package:exif/exif.dart';
import 'package:path/path.dart' as p;

class ImageMetadata {
  const ImageMetadata({
    required this.typeLabel,
    required this.fileSize,
    required this.modifiedAt,
    required this.capturedAt,
    required this.camera,
    required this.lens,
    required this.focalLength,
    required this.aperture,
    required this.exposure,
    required this.iso,
    required this.embeddedResolution,
  });

  final String typeLabel;
  final int? fileSize;
  final DateTime? modifiedAt;
  final DateTime? capturedAt;
  final String? camera;
  final String? lens;
  final String? focalLength;
  final String? aperture;
  final String? exposure;
  final String? iso;
  final String? embeddedResolution;

  static Future<ImageMetadata> load(String imagePath) async {
    return _loadMetadata(imagePath);
  }
}

Future<ImageMetadata> _loadMetadata(String imagePath) async {
  final file = File(imagePath);
  final extension = p.extension(imagePath).toLowerCase();

  DateTime? modifiedAt;
  int? fileSize;
  try {
    final stat = await file.stat();
    modifiedAt = stat.modified;
    fileSize = stat.size;
  } on FileSystemException {
    // Best effort only.
  }

  final tags = await _readExifTags(file, extension);
  final make = _tagValue(tags, 'Image Make');
  final model = _tagValue(tags, 'Image Model');
  final lensModel = _tagValue(tags, 'EXIF LensModel');
  final focalLength = _tagValue(tags, 'EXIF FocalLength');
  final aperture = _tagValue(tags, 'EXIF FNumber');
  final exposure = _tagValue(tags, 'EXIF ExposureTime');
  final iso = _firstNonEmptyTagValue(tags, const [
    'EXIF ISOSpeedRatings',
    'EXIF PhotographicSensitivity',
  ]);
  final takenAt = _parseExifDate(
    _firstNonEmptyTagValue(tags, const [
      'EXIF DateTimeOriginal',
      'EXIF DateTimeDigitized',
      'Image DateTime',
    ]),
  );
  final width = _parseDimension(tags, const [
    'EXIF ExifImageWidth',
    'Image ImageWidth',
  ]);
  final height = _parseDimension(tags, const [
    'EXIF ExifImageLength',
    'Image ImageLength',
  ]);

  return ImageMetadata(
    typeLabel: _typeLabel(extension),
    fileSize: fileSize,
    modifiedAt: modifiedAt,
    capturedAt: takenAt,
    camera: _joinParts([make, model]),
    lens: lensModel,
    focalLength: focalLength,
    aperture: aperture == null ? null : 'f/$aperture',
    exposure: exposure,
    iso: iso == null ? null : 'ISO $iso',
    embeddedResolution: width != null && height != null
        ? '$width × $height'
        : null,
  );
}

Future<Map<String, IfdTag>> _readExifTags(File file, String extension) async {
  if (extension == '.svg') {
    return const <String, IfdTag>{};
  }

  try {
    final bytes = await file.readAsBytes();
    return await readExifFromBytes(bytes);
  } on FileSystemException {
    return const <String, IfdTag>{};
  } catch (_) {
    return const <String, IfdTag>{};
  }
}

String? _tagValue(Map<String, IfdTag> tags, String key) {
  final value = tags[key]?.printable.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  return value;
}

String? _firstNonEmptyTagValue(Map<String, IfdTag> tags, List<String> keys) {
  for (final key in keys) {
    final value = _tagValue(tags, key);
    if (value != null) {
      return value;
    }
  }

  return null;
}

int? _parseDimension(Map<String, IfdTag> tags, List<String> keys) {
  final rawValue = _firstNonEmptyTagValue(tags, keys);
  if (rawValue == null) {
    return null;
  }

  final match = RegExp(r'\d+').firstMatch(rawValue);
  if (match == null) {
    return null;
  }

  return int.tryParse(match.group(0)!);
}

DateTime? _parseExifDate(String? rawValue) {
  if (rawValue == null || rawValue.isEmpty) {
    return null;
  }

  final sanitized = rawValue.replaceFirstMapped(
    RegExp(r'^(\d{4}):(\d{2}):(\d{2})'),
    (match) => '${match[1]}-${match[2]}-${match[3]}',
  );

  return DateTime.tryParse(sanitized);
}

String _typeLabel(String extension) {
  switch (extension) {
    case '.jpg':
    case '.jpeg':
      return 'JPEG';
    case '.png':
      return 'PNG';
    case '.gif':
      return 'GIF';
    case '.bmp':
      return 'BMP';
    case '.webp':
      return 'WebP';
    case '.ico':
      return 'ICO';
    case '.svg':
      return 'SVG vector';
    default:
      return extension.isEmpty
          ? 'Image'
          : extension.replaceFirst('.', '').toUpperCase();
  }
}

String? _joinParts(Iterable<String?> parts) {
  final res = parts
      .whereType<String>()
      .where((part) => part.isNotEmpty)
      .join(' ');
  if (res.trim().isEmpty) {
    return null;
  }
  return res;
}
