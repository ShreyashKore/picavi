/// Formats Flutter decodes itself, on every platform.
const Set<String> supportedImageExtensions = {
  '.bmp',
  '.gif',
  '.ico',
  '.jpeg',
  '.jpg',
  '.png',
  '.svg',
  '.webp',
};

/// Formats decoded by the operating system's image framework, where the
/// platform provides one (currently macOS ImageIO).
const Set<String> systemDecodedImageExtensions = {
  '.avif',
  '.heic',
  '.heif',
  '.tif',
  '.tiff',
};

/// Every extension the viewer can open, given whether system decoding is
/// available.
Set<String> imageExtensionsFor({required bool systemDecoding}) => {
  ...supportedImageExtensions,
  if (systemDecoding) ...systemDecodedImageExtensions,
};
