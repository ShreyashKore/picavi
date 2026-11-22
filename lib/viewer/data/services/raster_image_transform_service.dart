import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../domain/services/image_transform_service.dart';

/// Saves rotations without losing quality:
/// - JPEG: only the EXIF orientation tag changes; pixels and all other
///   metadata are left byte-for-byte as they were.
/// - PNG / BMP: pixels are rotated and re-encoded losslessly.
///
/// The new file is written next to the original and swapped in with a
/// rename, so a failure never leaves a half-written image.
class RasterImageTransformService implements ImageTransformService {
  static const Set<String> _jpegExtensions = {'.jpg', '.jpeg'};
  static const Set<String> _pixelExtensions = {'.png', '.bmp'};

  @override
  bool canSaveRotation(String path) {
    final extension = p.extension(path).toLowerCase();
    return _jpegExtensions.contains(extension) ||
        _pixelExtensions.contains(extension);
  }

  @override
  Future<RotationSaveResult> saveRotation(
    String path,
    int quarterTurnsClockwise,
  ) async {
    final turns = quarterTurnsClockwise % 4;
    if (!canSaveRotation(path)) {
      return RotationSaveResult.unsupportedFormat;
    }
    if (turns == 0) {
      return RotationSaveResult.saved;
    }

    try {
      final original = await File(path).readAsBytes();
      final extension = p.extension(path).toLowerCase();
      final rotated = await Isolate.run(
        () => rotateEncodedImage(original, extension, turns),
      );
      if (rotated == null) {
        return RotationSaveResult.failed;
      }

      await _replaceFile(path, rotated);
      return RotationSaveResult.saved;
    } catch (error) {
      debugPrint('Unable to save rotation for $path: $error');
      return RotationSaveResult.failed;
    }
  }

  static Future<void> _replaceFile(String path, Uint8List bytes) async {
    final temporary = File(
      p.join(p.dirname(path), '.${p.basename(path)}.picavi-tmp'),
    );
    try {
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(path);
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }
  }
}

/// Returns [bytes] rotated by [turns] quarter turns clockwise, or null if the
/// image couldn't be decoded. Top-level so it can run in an isolate.
@visibleForTesting
Uint8List? rotateEncodedImage(Uint8List bytes, String extension, int turns) {
  switch (extension) {
    case '.jpg':
    case '.jpeg':
      return rotateJpegOrientation(bytes, turns);
    case '.png':
      final image = img.decodePng(bytes);
      return image == null
          ? null
          : img.encodePng(img.copyRotate(image, angle: 90 * turns));
    case '.bmp':
      final image = img.decodeBmp(bytes);
      return image == null
          ? null
          : img.encodeBmp(img.copyRotate(image, angle: 90 * turns));
  }
  return null;
}

/// EXIF orientation as (mirrored, clockwise quarter turns), mirror applied
/// first — the exiftool definitions of values 1–8.
const Map<int, (bool, int)> _orientationTransforms = {
  1: (false, 0),
  2: (true, 0),
  3: (false, 2),
  4: (true, 2),
  5: (true, 3),
  6: (false, 1),
  7: (true, 1),
  8: (false, 3),
};

/// The orientation value that shows an image with [current] orientation
/// rotated a further [turns] quarter turns clockwise.
@visibleForTesting
int composeOrientation(int current, int turns) {
  final (mirrored, currentTurns) =
      _orientationTransforms[current] ?? (false, 0);
  final targetTurns = (currentTurns + turns) % 4;
  return _orientationTransforms.entries
      .firstWhere(
        (entry) => entry.value.$1 == mirrored && entry.value.$2 == targetTurns,
      )
      .key;
}

/// Rotates a JPEG by rewriting its EXIF orientation. Edits the existing tag in
/// place when there is one (everything else stays byte-identical); otherwise
/// adds EXIF with just the orientation.
@visibleForTesting
Uint8List? rotateJpegOrientation(Uint8List jpeg, int turns) {
  if (jpeg.length < 4 || jpeg[0] != 0xFF || jpeg[1] != 0xD8) {
    return null;
  }

  final location = _findOrientationTag(jpeg);
  if (location != null) {
    final data = ByteData.sublistView(jpeg);
    final current = data.getUint16(location.offset, location.endian);
    final updated = Uint8List.fromList(jpeg);
    ByteData.sublistView(updated).setUint16(
      location.offset,
      composeOrientation(current, turns),
      location.endian,
    );
    return updated;
  }

  final exif = img.decodeJpgExif(jpeg) ?? img.ExifData();
  if (!exif.isEmpty) {
    // EXIF exists but has no orientation tag: rewriting it could drop tags
    // the encoder doesn't understand, so leave the file alone.
    return null;
  }
  exif.imageIfd.orientation = composeOrientation(1, turns);
  return img.injectJpgExif(jpeg, exif);
}

class _TagLocation {
  const _TagLocation(this.offset, this.endian);

  final int offset;
  final Endian endian;
}

/// Finds the value bytes of IFD0's Orientation (0x0112, SHORT) tag.
_TagLocation? _findOrientationTag(Uint8List jpeg) {
  final data = ByteData.sublistView(jpeg);
  var offset = 2;
  while (offset + 4 <= jpeg.length) {
    if (jpeg[offset] != 0xFF) {
      return null;
    }
    final marker = jpeg[offset + 1];
    if (marker == 0xDA || marker == 0xD9) {
      return null; // Start of scan / end of image: no more metadata.
    }
    final segmentLength = data.getUint16(offset + 2);
    final segmentStart = offset + 4;
    final segmentEnd = offset + 2 + segmentLength;
    if (segmentEnd > jpeg.length) {
      return null;
    }

    if (marker == 0xE1 &&
        segmentLength >= 8 &&
        String.fromCharCodes(jpeg, segmentStart, segmentStart + 4) == 'Exif') {
      return _orientationInTiff(data, segmentStart + 6, segmentEnd);
    }
    offset = segmentEnd;
  }
  return null;
}

_TagLocation? _orientationInTiff(ByteData data, int tiffStart, int end) {
  if (tiffStart + 8 > end) {
    return null;
  }
  final byteOrder = data.getUint16(tiffStart);
  final endian = switch (byteOrder) {
    0x4949 => Endian.little, // "II"
    0x4D4D => Endian.big, // "MM"
    _ => null,
  };
  if (endian == null) {
    return null;
  }

  final ifdStart = tiffStart + data.getUint32(tiffStart + 4, endian);
  if (ifdStart + 2 > end) {
    return null;
  }
  final entryCount = data.getUint16(ifdStart, endian);
  for (var index = 0; index < entryCount; index++) {
    final entry = ifdStart + 2 + index * 12;
    if (entry + 12 > end) {
      return null;
    }
    final tag = data.getUint16(entry, endian);
    if (tag != 0x0112) {
      continue;
    }
    final type = data.getUint16(entry + 2, endian);
    final count = data.getUint32(entry + 4, endian);
    return type == 3 && count == 1 ? _TagLocation(entry + 8, endian) : null;
  }
  return null;
}
