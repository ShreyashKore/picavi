enum ExportFormat {
  jpeg('.jpg'),
  png('.png');

  const ExportFormat(this.extension);

  final String extension;
}

class ExportOptions {
  const ExportOptions({
    this.format = ExportFormat.jpeg,
    this.maxDimension,
    this.jpegQuality = 90,
  });

  /// Long-edge sizes offered in the export dialog; null keeps the original.
  static const List<int?> sizeChoices = [null, 640, 1024, 1600, 2048, 3840];

  final ExportFormat format;

  /// Longest side in pixels, or null for the edited image's full size.
  final int? maxDimension;

  /// 1–100; only used for JPEG.
  final int jpegQuality;

  ExportOptions copyWith({
    ExportFormat? format,
    int? Function()? maxDimension,
    int? jpegQuality,
  }) {
    return ExportOptions(
      format: format ?? this.format,
      maxDimension: maxDimension != null ? maxDimension() : this.maxDimension,
      jpegQuality: jpegQuality ?? this.jpegQuality,
    );
  }
}
