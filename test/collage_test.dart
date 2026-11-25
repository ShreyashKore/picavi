import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oiv/collage/data/collage_renderer.dart';
import 'package:oiv/collage/data/raster_collage_service.dart';
import 'package:oiv/collage/domain/collage_options.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/editor/domain/entities/rgba_image.dart';
import 'package:path/path.dart' as p;

import 'support/editor_fakes.dart';

RgbaImage solid(int width, int height, List<int> rgb) {
  final image = RgbaImage.blank(width, height);
  for (var i = 0; i < image.pixels.length; i += 4) {
    image.pixels.setAll(i, [...rgb, 255]);
  }
  return image;
}

void main() {
  const options = CollageOptions(size: CollageSize.hd, spacing: 0.01);

  bool inside(Slot slot, CollageOptions o) =>
      slot.x >= 0 &&
      slot.y >= 0 &&
      slot.x + slot.width <= o.width + 1 &&
      slot.y + slot.height <= o.height + 1;

  test('grid slots fill the canvas without overlapping', () {
    final slots = gridSlots(7, options);

    expect(slots, hasLength(7));
    expect(slots.every((s) => inside(s, options)), isTrue);
    final first = slots.first;
    expect(
      slots.every((s) => s.width == first.width && s.height == first.height),
      isTrue,
    );
  });

  test('mosaic keeps each photo\'s shape and fills the canvas', () {
    final aspects = [1.5, 0.66, 1.0, 1.5, 1.5, 0.75, 1.33];
    final slots = mosaicSlots(aspects, options);

    expect(slots.every((s) => inside(s, options)), isTrue);
    final bottom = slots
        .map((s) => s.y + s.height)
        .reduce((a, b) => a > b ? a : b);
    final gap = (options.height * options.spacing).round();
    expect(bottom, closeTo(options.height - gap, 2));
    for (var i = 0; i < aspects.length; i++) {
      final rowSlots = slots.where((s) => s.y == slots[i].y).toList();
      final right = rowSlots
          .map((s) => s.x + s.width)
          .reduce((a, b) => a > b ? a : b);
      expect(
        right,
        closeTo(options.width - gap, 2),
        reason: 'rows span the width',
      );
    }
  });

  test('renders pages with the background and the photos', () {
    final tiles = [
      CollageTile(solid(300, 200, [255, 0, 0]), 'a.jpg'),
      CollageTile(solid(200, 300, [0, 0, 255]), 'b.jpg'),
    ];

    final page = renderCollagePages(
      tiles,
      const CollageOptions(
        layout: CollageLayout.grid,
        size: CollageSize.square,
        spacing: 0.04,
        background: CollageBackground.black,
      ),
    ).single;

    expect((page.width, page.height), (2048, 2048));
    expect(page.getPixel(2, 2).r, 0);
    // Two photos on a square canvas stack in one column.
    final top = page.getPixel(1024, 512);
    final bottom = page.getPixel(1024, 1536);
    expect((top.r, top.b), (255, 0));
    expect((bottom.r, bottom.b), (0, 255));
  });

  test('cropped photos stay inside their slots', () {
    const green = [0, 255, 0];
    for (final layout in [CollageLayout.mosaic, CollageLayout.grid]) {
      for (final size in CollageSize.values) {
        // Photos far from the shape of their slots, so most are cropped.
        final tiles = [
          for (var i = 0; i < 9; i++)
            CollageTile(
              i.isEven ? solid(300, 100, green) : solid(100, 300, green),
              '$i.jpg',
            ),
        ];
        final options = CollageOptions(
          layout: layout,
          size: size,
          spacing: 0.03,
          background: CollageBackground.black,
        );
        final slots = layout == CollageLayout.mosaic
            ? mosaicSlots([
                for (final tile in tiles) tile.image.width / tile.image.height,
              ], options)
            : gridSlots(tiles.length, options);

        final page = renderCollagePages(tiles, options).single;

        // A little slack for rounding at slot edges.
        bool nearSlot(int x, int y) => slots.any(
          (s) =>
              x >= s.x - 2 &&
              x <= s.x + s.width + 2 &&
              y >= s.y - 2 &&
              y <= s.y + s.height + 2,
        );
        final outside = <(int, int)>[
          for (var y = 0; y < page.height; y += 7)
            for (var x = 0; x < page.width; x += 7)
              if (page.getPixel(x, y).g != 0 && !nearSlot(x, y)) (x, y),
        ];
        expect(outside, isEmpty, reason: '$layout $size paints over the gaps');
        for (final slot in slots) {
          final centre = page.getPixel(
            slot.x + slot.width ~/ 2,
            slot.y + slot.height ~/ 2,
          );
          expect(centre.g, 255, reason: '$layout $size draws every photo');
        }
      }
    }
  });

  test('contact sheets split into pages of 35', () {
    final tiles = [
      for (var i = 0; i < 40; i++)
        CollageTile(solid(40, 30, [i * 5, 100, 100]), 'IMG_$i.jpg'),
    ];

    final pages = renderCollagePages(
      tiles,
      const CollageOptions(layout: CollageLayout.contactSheet),
    );

    expect(pages, hasLength(2));
    expect((pages.first.width, pages.first.height), (1240, 1754));
  });

  test(
    'the service applies edits, writes JPEGs and never overwrites',
    () async {
      final directory = await Directory.systemTemp.createTemp('oiv_collage');
      addTearDown(() => directory.delete(recursive: true));
      await File(p.join(directory.path, 'Collage.jpg')).writeAsString('keep');
      final service = RasterCollageService(
        pixelSource: FakePixelSource(gradientImage(60, 40)),
      );
      final progress = <(int, int)>[];

      final written = await service.create(
        const [
          CollagePhoto('/a.jpg'),
          CollagePhoto('/b.jpg', ImageEdits([RotateEdit(1)])),
        ],
        const CollageOptions(size: CollageSize.hd),
        directory.path,
        fileName: 'Collage',
        onProgress: (done, total) => progress.add((done, total)),
      );

      expect(written.map(p.basename), ['Collage (2).jpg']);
      expect(
        await File(p.join(directory.path, 'Collage.jpg')).readAsString(),
        'keep',
      );
      final decoded = img.decodeJpg(await File(written.single).readAsBytes())!;
      expect((decoded.width, decoded.height), (1920, 1080));
      expect(progress.last, (2, 2));
    },
  );

  test('the service writes nothing when no photo can be read', () async {
    final service = RasterCollageService(
      pixelSource: FakePixelSource()..image = null,
    );

    final written = await service.create(
      const [CollagePhoto('/a.jpg')],
      const CollageOptions(),
      Directory.systemTemp.path,
      fileName: 'Collage',
    );

    expect(written, isEmpty);
  });
}
