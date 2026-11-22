import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/editor/data/pipeline/edit_pipeline.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/editor/domain/entities/rgba_image.dart';

/// A [width]×[height] image filled by [color] (x, y) → [r, g, b, a].
RgbaImage paint(int width, int height, List<int> Function(int x, int y) color) {
  final image = RgbaImage.blank(width, height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.pixels.setAll((y * width + x) * 4, color(x, y));
    }
  }
  return image;
}

List<int> pixelAt(RgbaImage image, int x, int y) {
  final i = (y * image.width + x) * 4;
  return image.pixels.sublist(i, i + 4);
}

void main() {
  group('ImageEdits JSON', () {
    test('round-trips every operation type', () {
      const edits = ImageEdits([
        CropEdit(NormalizedRect(0.1, 0.2, 0.9, 0.8)),
        RotateEdit(-1),
        StraightenEdit(3.5),
        LevelsEdit(
          kind: AutoFixKind.feelingLucky,
          black: [4, 5, 6],
          white: [250, 251, 252],
          saturation: 0.15,
        ),
        TuneEdit(
          fillLight: 0.3,
          highlights: 0.1,
          shadows: 0.2,
          temperature: -0.4,
        ),
        EffectEdit(EffectKind.sepia, 0.8),
        RedEyeEdit([RedEyeSpot(0.4, 0.5, 0.02)]),
      ]);

      expect(ImageEdits.fromJson(edits.toJson()), edits);
    });

    test('skips unknown or corrupt entries instead of failing', () {
      final edits = ImageEdits.fromJson([
        {
          'op': 'crop',
          'rect': [0, 0, 0.5, 0.5],
        },
        {'op': 'fromTheFuture', 'x': 1},
        {'op': 'effect', 'kind': 'nope', 'amount': 1},
        'garbage',
        {'op': 'rotate', 'turns': 1},
      ]);

      expect(edits.operations, const [
        CropEdit(NormalizedRect(0, 0, 0.5, 0.5)),
        RotateEdit(1),
      ]);
      expect(ImageEdits.fromJson('nonsense'), ImageEdits.none);
    });
  });

  group('geometry', () {
    test('crop keeps the requested region', () {
      final image = paint(10, 10, (x, y) => [x * 10, y * 10, 0, 255]);

      final cropped = cropImage(image, const NormalizedRect(0.2, 0.5, 0.6, 1));

      expect((cropped.width, cropped.height), (4, 5));
      expect(pixelAt(cropped, 0, 0), [20, 50, 0, 255]);
      expect(pixelAt(cropped, 3, 4), [50, 90, 0, 255]);
    });

    test(
      'rotating a quarter turn clockwise moves the top-left to the top-right',
      () {
        final image = paint(3, 2, (x, y) => [x, y, 0, 255]);

        final rotated = rotateQuarterTurns(image, 1);

        expect((rotated.width, rotated.height), (2, 3));
        expect(pixelAt(rotated, 1, 0), [0, 0, 0, 255]);
        expect(pixelAt(rotated, 0, 0), [0, 1, 0, 255]);
        expect(pixelAt(rotated, 0, 2), [2, 1, 0, 255]);
      },
    );

    test('four quarter turns give the original back', () {
      final image = paint(5, 3, (x, y) => [x * 40, y * 80, 7, 255]);

      var rotated = image;
      for (var i = 0; i < 4; i++) {
        rotated = rotateQuarterTurns(rotated, 1);
      }

      expect(rotated.pixels, image.pixels);
    });

    test('straighten crops so no empty corners show', () {
      final image = paint(200, 100, (x, y) => [200, 100, 50, 255]);

      final straightened = straightenImage(image, 10 * 3.141592653589793 / 180);

      final scale = straightenScale(200, 100, 10 * 3.141592653589793 / 180);
      expect(scale, lessThan(1));
      expect(straightened.width, (200 * scale).floor());
      expect(straightened.height, (100 * scale).floor());
      for (final (x, y) in [
        (0, 0),
        (straightened.width - 1, 0),
        (0, straightened.height - 1),
        (straightened.width - 1, straightened.height - 1),
      ]) {
        expect(pixelAt(straightened, x, y), [200, 100, 50, 255]);
      }
    });

    test('straighten by zero is a no-op', () {
      final image = paint(4, 4, (x, y) => [x, y, 0, 255]);

      expect(identical(straightenImage(image, 0), image), isTrue);
    });
  });

  group('colour', () {
    test('levels stretch the range', () {
      final image = paint(
        2,
        1,
        (x, y) => x == 0 ? [50, 50, 50, 255] : [200, 200, 200, 255],
      );

      final result = applyEdit(
        image,
        const LevelsEdit(
          kind: AutoFixKind.autoContrast,
          black: [50, 50, 50],
          white: [200, 200, 200],
        ),
      );

      expect(pixelAt(result, 0, 0), [0, 0, 0, 255]);
      expect(pixelAt(result, 1, 0), [255, 255, 255, 255]);
    });

    test('fill light brightens shadows, shadows darkens them', () {
      List<int> tuned(TuneEdit tune) => pixelAt(
        applyEdit(paint(1, 1, (_, _) => [60, 60, 60, 255]), tune),
        0,
        0,
      );

      expect(tuned(const TuneEdit(fillLight: 1))[0], greaterThan(60));
      expect(tuned(const TuneEdit(shadows: 1))[0], lessThan(60));
      final warm = tuned(const TuneEdit(temperature: 1));
      expect(warm[0], greaterThan(warm[2]));
    });

    test('black & white removes colour; sepia tints it', () {
      final source = paint(1, 1, (_, _) => [200, 40, 40, 255]);

      final gray = pixelAt(
        applyEdit(source.copy(), const EffectEdit(EffectKind.blackAndWhite, 1)),
        0,
        0,
      );
      expect(gray[0], gray[1]);
      expect(gray[1], gray[2]);

      final sepia = pixelAt(
        applyEdit(source.copy(), const EffectEdit(EffectKind.sepia, 1)),
        0,
        0,
      );
      expect(sepia[0], greaterThan(sepia[1]));
      expect(sepia[1], greaterThan(sepia[2]));
    });

    test('negative saturation moves towards gray', () {
      final source = paint(1, 1, (_, _) => [220, 60, 60, 255]);

      final result = pixelAt(
        applyEdit(source, const EffectEdit(EffectKind.saturation, -1)),
        0,
        0,
      );

      expect(result[0], result[1]);
    });

    test('vignette darkens corners more than the centre', () {
      final source = paint(51, 51, (_, _) => [200, 200, 200, 255]);

      final result = applyEdit(
        source,
        const EffectEdit(EffectKind.vignette, 1),
      );

      expect(pixelAt(result, 0, 0)[0], lessThan(pixelAt(result, 25, 25)[0]));
      expect(pixelAt(result, 25, 25)[0], 200);
    });

    test('every effect leaves alpha and size alone', () {
      for (final kind in EffectKind.values) {
        final source = paint(20, 12, (x, y) => [x * 12, y * 20, 128, 200]);

        final result = applyEdit(source, EffectEdit(kind, kind.defaultAmount));

        expect((result.width, result.height), (20, 12), reason: kind.name);
        for (var i = 3; i < result.pixels.length; i += 4) {
          expect(result.pixels[i], 200, reason: kind.name);
        }
      }
    });

    test('film grain is the same every time', () {
      RgbaImage grain() => applyEdit(
        paint(16, 16, (_, _) => [128, 128, 128, 255]),
        const EffectEdit(EffectKind.filmGrain, 1),
      );

      expect(grain().pixels, grain().pixels);
    });

    test('red-eye removal only touches red pixels inside the spot', () {
      final source = paint(
        20,
        20,
        (x, y) => x < 10 ? [220, 30, 30, 255] : [30, 30, 220, 255],
      );

      final result = applyEdit(
        source,
        const RedEyeEdit([RedEyeSpot(0.25, 0.5, 0.2)]),
      );

      expect(pixelAt(result, 5, 10)[0], lessThan(60));
      expect(pixelAt(result, 5, 0), [220, 30, 30, 255]);
      expect(pixelAt(result, 15, 10), [30, 30, 220, 255]);
    });
  });

  group('auto fixes', () {
    test('auto contrast measures the darkest and brightest tones', () {
      final image = paint(100, 1, (x, y) {
        final v = 60 + x;
        return [v, v, v, 255];
      });

      final fix = measureAutoFix(image, AutoFixKind.autoContrast);

      expect(fix.black[0], inInclusiveRange(60, 61));
      expect(fix.white[0], 191); // Limited so flat images stay natural.
      expect(fix.black, [fix.black[0], fix.black[0], fix.black[0]]);
    });

    test('auto colour stretches each channel on its own', () {
      final image = paint(100, 1, (x, y) => [x + 100, x + 20, x, 255]);

      final fix = measureAutoFix(image, AutoFixKind.autoColor);

      expect(fix.black[0], greaterThan(fix.black[2]));
      expect(fix.saturation, 0);
      expect(
        measureAutoFix(image, AutoFixKind.feelingLucky).saturation,
        greaterThan(0),
      );
    });

    test('ignores transparent pixels', () {
      final image = paint(
        2,
        1,
        (x, y) => x == 0 ? [0, 0, 0, 0] : [128, 128, 128, 255],
      );

      final fix = measureAutoFix(image, AutoFixKind.autoContrast);

      expect(fix.black[0], 64);
    });
  });

  test('applyEdits leaves the source untouched', () {
    final source = paint(8, 8, (x, y) => [100, 100, 100, 255]);
    final before = Uint8List.fromList(source.pixels);

    final result = applyEdits(source, const [
      EffectEdit(EffectKind.sepia, 1),
      CropEdit(NormalizedRect(0, 0, 0.5, 0.5)),
    ]);

    expect(source.pixels, before);
    expect((result.width, result.height), (4, 4));
  });
}
