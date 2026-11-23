import '../../editor/domain/entities/image_edits.dart';

enum CollageLayout { grid, mosaic, contactSheet }

/// Canvas sizes offered for grid and mosaic collages.
enum CollageSize {
  hd(1920, 1080),
  large(3000, 2000),
  square(2048, 2048),
  portrait(2000, 3000);

  const CollageSize(this.width, this.height);

  final int width;
  final int height;
}

enum CollageBackground {
  white(0xFFFFFFFF),
  black(0xFF000000),
  charcoal(0xFF202028);

  const CollageBackground(this.argb);

  final int argb;
}

class CollageOptions {
  const CollageOptions({
    this.layout = CollageLayout.mosaic,
    this.size = CollageSize.hd,
    this.spacing = 0.01,
    this.background = CollageBackground.white,
  });

  /// A4 at 150 dpi, used for contact sheet pages.
  static const int sheetWidth = 1240;
  static const int sheetHeight = 1754;
  static const int sheetColumns = 5;
  static const int sheetRows = 7;

  final CollageLayout layout;
  final CollageSize size;

  /// Gap between photos as a fraction of the canvas's shorter side.
  final double spacing;
  final CollageBackground background;

  int get width =>
      layout == CollageLayout.contactSheet ? sheetWidth : size.width;
  int get height =>
      layout == CollageLayout.contactSheet ? sheetHeight : size.height;

  CollageOptions copyWith({
    CollageLayout? layout,
    CollageSize? size,
    double? spacing,
    CollageBackground? background,
  }) {
    return CollageOptions(
      layout: layout ?? this.layout,
      size: size ?? this.size,
      spacing: spacing ?? this.spacing,
      background: background ?? this.background,
    );
  }
}

/// A photo to put in a collage, with the edits to apply first.
class CollagePhoto {
  const CollagePhoto(this.path, [this.edits = ImageEdits.none]);

  final String path;
  final ImageEdits edits;
}

/// Makes collages and contact sheets as new image files.
abstract class CollageService {
  /// Renders [photos] and writes the result (one file, or one per contact
  /// sheet page) into [directory] as `<fileName>.jpg` (numbered when taken
  /// or when there are several pages). Returns the files written; empty if
  /// nothing could be made. [onProgress] gets (photos loaded, total).
  Future<List<String>> create(
    List<CollagePhoto> photos,
    CollageOptions options,
    String directory, {
    required String fileName,
    void Function(int done, int total)? onProgress,
  });
}
