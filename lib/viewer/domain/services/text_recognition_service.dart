import '../entities/recognized_text.dart';

/// Finds text in images (Live Text). Implementations fail soft: they return
/// null when recognition is unavailable or fails.
abstract class TextRecognitionService {
  /// Whether this platform can recognize text at all.
  bool get isAvailable;

  Future<RecognizedText?> recognize(TextRecognitionSource source);
}
