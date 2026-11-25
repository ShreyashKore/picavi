import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../collage/domain/collage_options.dart';
import '../../editor/data/pipeline/edit_pipeline.dart';
import '../../editor/domain/services/image_pixel_source.dart';
import '../domain/print_layout.dart';

/// Decodes [photos] at a size suited to [layout], applies their edits and
/// encodes them as JPEG for the PDF. Unreadable photos are skipped.
Future<List<Uint8List>> preparePrintImages(
  List<CollagePhoto> photos,
  PrintLayout layout,
  ImagePixelSource pixelSource, {
  void Function(int done, int total)? onProgress,
}) async {
  final result = <Uint8List>[];
  onProgress?.call(0, photos.length);
  for (var i = 0; i < photos.length; i++) {
    final photo = photos[i];
    final pixels = await pixelSource.load(
      photo.path,
      maxDimension: layout.renderSize,
    );
    if (pixels != null) {
      final operations = photo.edits.operations;
      result.add(
        await Isolate.run(() {
          final rendered = applyEdits(pixels, operations);
          final image = img.Image.fromBytes(
            width: rendered.width,
            height: rendered.height,
            bytes: rendered.pixels.buffer,
            bytesOffset: rendered.pixels.offsetInBytes,
            numChannels: 4,
          );
          final flat = img.Image(width: image.width, height: image.height)
            ..clear(img.ColorRgb8(255, 255, 255));
          img.compositeImage(flat, image);
          return img.encodeJpg(flat, quality: 90);
        }),
      );
    }
    onProgress?.call(i + 1, photos.length);
  }
  return result;
}

/// Lays out [jpegs] on pages of [format], [layout] photos per page, each
/// fitted (never cropped) into its cell and centred.
Future<Uint8List> buildPrintPdf(
  List<Uint8List> jpegs,
  PdfPageFormat format,
  PrintLayout layout, {
  String title = '',
}) {
  final document = pw.Document(title: title);
  final landscape = format.width > format.height;
  final columns = landscape ? layout.rows : layout.columns;
  final rows = landscape ? layout.columns : layout.rows;
  const gap = 12.0;
  final margin = math.min(36.0, format.width * 0.05);
  final pageFormat = format.copyWith(
    marginLeft: margin,
    marginRight: margin,
    marginTop: margin,
    marginBottom: margin,
  );

  for (var start = 0; start < jpegs.length; start += layout.perPage) {
    final pageImages = jpegs.sublist(
      start,
      math.min(start + layout.perPage, jpegs.length),
    );
    document.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          final cellWidth =
              (pageFormat.availableWidth - gap * (columns - 1)) / columns;
          final cellHeight =
              (pageFormat.availableHeight - gap * (rows - 1)) / rows;
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              for (var row = 0; row < rows; row++) ...[
                if (row > 0) pw.SizedBox(height: gap),
                pw.Row(
                  children: [
                    for (var column = 0; column < columns; column++) ...[
                      if (column > 0) pw.SizedBox(width: gap),
                      pw.SizedBox(
                        width: cellWidth,
                        height: cellHeight,
                        child: row * columns + column < pageImages.length
                            ? pw.Center(
                                child: pw.Image(
                                  pw.MemoryImage(
                                    pageImages[row * columns + column],
                                  ),
                                  fit: pw.BoxFit.contain,
                                ),
                              )
                            : pw.SizedBox(),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
  return document.save();
}
