import '../../core/images/system_decoded_image.dart';
import '../domain/constants/supported_image_extensions.dart';

/// Extensions the viewer can open on the current platform.
final Set<String> platformImageExtensions = imageExtensionsFor(
  systemDecoding: isSystemImageDecodingAvailable,
);
