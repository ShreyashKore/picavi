import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/collage/domain/collage_options.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/print_photos/data/print_pdf.dart';
import 'package:oiv/print_photos/domain/print_layout.dart';
import 'package:pdf/pdf.dart';

import 'support/editor_fakes.dart';

int pageCount(List<int> pdf) =>
    RegExp(r'/Type\s*/Page[^s]').allMatches(latin1.decode(pdf)).length;

void main() {
  test('prepares JPEGs at the layout size with edits applied', () async {
    final pixels = FakePixelSource(gradientImage(80, 40));

    final jpegs = await preparePrintImages(
      const [
        CollagePhoto('/a.jpg'),
        CollagePhoto('/b.jpg', ImageEdits([RotateEdit(1)])),
      ],
      PrintLayout.four,
      pixels,
    );

    expect(pixels.loads.first.$2, PrintLayout.four.renderSize);
    expect(img.decodeJpg(jpegs[0])!.width, 80);
    expect(img.decodeJpg(jpegs[1])!.width, 40);
  });

  test('skips photos that cannot be read', () async {
    final jpegs = await preparePrintImages(
      const [CollagePhoto('/a.jpg')],
      PrintLayout.one,
      FakePixelSource()..image = null,
    );

    expect(jpegs, isEmpty);
  });

  test('puts the right number of photos on each page', () async {
    final jpeg = img.encodeJpg(img.Image(width: 30, height: 20));
    final five = List.filled(5, jpeg);

    expect(
      pageCount(await buildPrintPdf(five, PdfPageFormat.a4, PrintLayout.one)),
      5,
    );
    expect(
      pageCount(await buildPrintPdf(five, PdfPageFormat.a4, PrintLayout.two)),
      3,
    );
    expect(
      pageCount(
        await buildPrintPdf(
          five,
          PdfPageFormat.letter.landscape,
          PrintLayout.four,
        ),
      ),
      2,
    );
    expect(
      pageCount(await buildPrintPdf(five, PdfPageFormat.a4, PrintLayout.nine)),
      1,
    );
  });
}
