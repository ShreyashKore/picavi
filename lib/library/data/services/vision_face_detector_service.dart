import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/face.dart';
import '../../domain/services/face_detector.dart';

/// Face detection with Apple Vision on macOS (channel method
/// `detectFaces`). Other platforms report it as unavailable.
class VisionFaceDetectorService implements FaceDetectorService {
  const VisionFaceDetectorService();

  static const MethodChannel _channel = MethodChannel(
    'com.gyanoba.oiv/file_open',
  );

  @override
  bool get isAvailable => Platform.isMacOS;

  @override
  Future<List<DetectedFace>?> detect(String path) async {
    if (!isAvailable) {
      return null;
    }
    try {
      final result = await _channel.invokeMethod<Object?>('detectFaces', {
        'path': path,
      });
      return parseDetectedFaces(result);
    } on MissingPluginException {
      return null;
    } catch (error) {
      debugPrint('Face detection failed for $path: $error');
      return null;
    }
  }
}

/// Parses the native reply; null if it isn't a detection result.
@visibleForTesting
List<DetectedFace>? parseDetectedFaces(Object? result) {
  if (result is! Map) {
    return null;
  }
  final faces = result['faces'];
  if (faces is! List) {
    return null;
  }
  final parsed = <DetectedFace>[];
  for (final face in faces) {
    if (face is! Map) {
      continue;
    }
    double? number(String key) => (face[key] as num?)?.toDouble();
    final left = number('left');
    final top = number('top');
    final width = number('width');
    final height = number('height');
    if (left == null || top == null || width == null || height == null) {
      continue;
    }
    final crop = face['crop'];
    final print = face['print'];
    parsed.add(
      DetectedFace(
        box: FaceBox(left, top, width, height),
        crop: crop is Uint8List ? crop : null,
        print: print is Float32List ? print : null,
      ),
    );
  }
  return parsed;
}
