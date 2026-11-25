import '../entities/face.dart';

/// Finds faces in photos, on the device.
abstract class FaceDetectorService {
  /// Whether this platform can detect faces.
  bool get isAvailable;

  /// Faces in the photo at [path] (empty if none), or null if it couldn't
  /// be read.
  Future<List<DetectedFace>?> detect(String path);
}
