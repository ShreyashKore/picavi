import 'dart:typed_data';

/// A point normalized to the image (0–1), origin at the top-left.
class NormalizedPoint {
  const NormalizedPoint(this.x, this.y);

  final double x;
  final double y;

  @override
  bool operator ==(Object other) =>
      other is NormalizedPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'NormalizedPoint($x, $y)';
}

/// Four corners of a (possibly rotated) text box, in normalized image
/// coordinates.
class TextQuad {
  const TextQuad({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  /// Reads `[tlx, tly, trx, try, brx, bry, blx, bly]`; null when malformed.
  static TextQuad? fromFlatList(List<double> values) {
    if (values.length != 8) {
      return null;
    }
    return TextQuad(
      topLeft: NormalizedPoint(values[0], values[1]),
      topRight: NormalizedPoint(values[2], values[3]),
      bottomRight: NormalizedPoint(values[4], values[5]),
      bottomLeft: NormalizedPoint(values[6], values[7]),
    );
  }

  final NormalizedPoint topLeft;
  final NormalizedPoint topRight;
  final NormalizedPoint bottomRight;
  final NormalizedPoint bottomLeft;

  List<NormalizedPoint> get corners => [
    topLeft,
    topRight,
    bottomRight,
    bottomLeft,
  ];
}

/// A whitespace-delimited run of text inside a [RecognizedTextLine].
class RecognizedWord {
  const RecognizedWord({
    required this.start,
    required this.end,
    required this.quad,
  });

  /// UTF-16 offsets into the line's text.
  final int start;
  final int end;
  final TextQuad quad;
}

class RecognizedTextLine {
  const RecognizedTextLine({
    required this.text,
    required this.quad,
    required this.words,
  });

  final String text;
  final TextQuad quad;
  final List<RecognizedWord> words;

  String wordText(RecognizedWord word) => text.substring(word.start, word.end);
}

/// Text found in an image, lines in reading order.
class RecognizedText {
  const RecognizedText(this.lines);

  static const RecognizedText empty = RecognizedText([]);

  final List<RecognizedTextLine> lines;

  bool get isEmpty => lines.every((line) => line.words.isEmpty);

  String get fullText => lines.map((line) => line.text).join('\n');
}

/// What to run text recognition on.
sealed class TextRecognitionSource {
  const TextRecognitionSource();
}

/// An image file, read as the viewer shows it (EXIF orientation applied).
class FileTextRecognitionSource extends TextRecognitionSource {
  const FileTextRecognitionSource(this.path);

  final String path;
}

/// Already-rendered pixels, e.g. an image with edits applied.
class PixelTextRecognitionSource extends TextRecognitionSource {
  const PixelTextRecognitionSource({
    required this.width,
    required this.height,
    required this.rgba,
  });

  final int width;
  final int height;

  /// 4 bytes per pixel, straight alpha, rows top to bottom.
  final Uint8List rgba;
}
