import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/recognized_text.dart';
import '../../domain/services/text_recognition_service.dart';

/// Live Text on macOS via the Vision framework (`recognizeText` on the
/// native channel). Other platforms report [isAvailable] false.
class VisionTextRecognitionService implements TextRecognitionService {
  const VisionTextRecognitionService();

  static const MethodChannel _channel = MethodChannel(
    'com.gyanoba.oiv/file_open',
  );

  @override
  bool get isAvailable => Platform.isMacOS;

  @override
  Future<RecognizedText?> recognize(TextRecognitionSource source) async {
    if (!isAvailable) {
      return null;
    }

    final arguments = switch (source) {
      FileTextRecognitionSource(:final path) => <String, Object?>{'path': path},
      PixelTextRecognitionSource(:final width, :final height, :final rgba) =>
        <String, Object?>{'width': width, 'height': height, 'rgba': rgba},
    };

    try {
      final response = await _channel.invokeMethod<Object?>(
        'recognizeText',
        arguments,
      );
      return parseRecognizedText(response);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      debugPrint('Text recognition failed: $error');
      return null;
    }
  }
}

/// Parses the native `recognizeText` payload; skips malformed entries.
@visibleForTesting
RecognizedText? parseRecognizedText(Object? response) {
  if (response is! Map) {
    return null;
  }
  final rawLines = response['lines'];
  if (rawLines is! List) {
    return null;
  }

  final lines = <RecognizedTextLine>[];
  for (final rawLine in rawLines) {
    if (rawLine is! Map) {
      continue;
    }
    final text = rawLine['text'];
    final quad = _parseQuad(rawLine['quad']);
    final rawWords = rawLine['words'];
    if (text is! String || quad == null || rawWords is! List) {
      continue;
    }

    final words = <RecognizedWord>[];
    for (final rawWord in rawWords) {
      if (rawWord is! Map) {
        continue;
      }
      final start = rawWord['start'];
      final end = rawWord['end'];
      final wordQuad = _parseQuad(rawWord['quad']);
      if (start is! int ||
          end is! int ||
          wordQuad == null ||
          start < 0 ||
          end <= start ||
          end > text.length) {
        continue;
      }
      words.add(RecognizedWord(start: start, end: end, quad: wordQuad));
    }
    lines.add(RecognizedTextLine(text: text, quad: quad, words: words));
  }
  return RecognizedText(lines);
}

TextQuad? _parseQuad(Object? raw) {
  if (raw is! List || raw.length != 8) {
    return null;
  }
  final values = <double>[];
  for (final value in raw) {
    if (value is! num) {
      return null;
    }
    values.add(value.toDouble());
  }
  return TextQuad.fromFlatList(values);
}
