import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/core/widgets/app_image.dart';
import 'package:oiv/viewer/presentation/widgets/interactive_image_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InteractiveImageViewer animations', () {
    testWidgets('zoom commands animate smoothly', (tester) async {
      final controller = InteractiveImageViewerController();
      final image = _buildSvgImage(
        const Color(0xFFE53935),
        width: 40,
        height: 20,
      );

      await _pumpViewer(tester, controller: controller, image: image);
      await tester.pump(const Duration(milliseconds: 50));

      controller.zoomIn();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));

      final midAnimationScale = _scaleTransform(tester).storage[0];
      expect(midAnimationScale, greaterThan(1));
      expect(midAnimationScale, lessThan(1.2));

      await tester.pump(const Duration(milliseconds: 200));

      final completedScale = _scaleTransform(tester).storage[0];
      expect(completedScale, closeTo(1.2, 0.02));
    });

    testWidgets('fit/fill toggles between covering and fitting', (
      tester,
    ) async {
      final controller = InteractiveImageViewerController();
      // A 2:1 image in a 4:3 viewport: filling needs 1.5x the fit zoom.
      final image = _buildSvgImage(
        const Color(0xFF43A047),
        width: 40,
        height: 20,
      );

      await _pumpViewer(tester, controller: controller, image: image);
      // Let the SVG's intrinsic size resolve (real async work).
      for (var i = 0; i < 20 && controller.value.imageInfo == null; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pump();
      expect(controller.value.imageInfo, isNotNull);
      expect(controller.value.fillZoomFactor, closeTo(1.5, 0.01));
      expect(controller.value.isFillingViewport, isFalse);

      controller.toggleFitFill();
      await tester.pumpAndSettle();
      expect(controller.value.zoomFactor, closeTo(1.5, 0.01));
      expect(controller.value.isFillingViewport, isTrue);

      controller.toggleFitFill();
      await tester.pumpAndSettle();
      expect(controller.value.zoomFactor, closeTo(1, 0.01));
      expect(controller.value.isFillingViewport, isFalse);
    });

    testWidgets('reloading the same file resets rotation without spinning', (
      tester,
    ) async {
      final controller = InteractiveImageViewerController();
      AppImage revisionOf(int revision) => AppImage(
        image: null,
        filePath: '/photos/a.jpg',
        revision: revision,
        svgBytesLoader: SvgStringLoader(
          _svgMarkup(const Color(0xFF1E88E5), width: 40, height: 20),
        ),
      );

      await _pumpViewer(tester, controller: controller, image: revisionOf(0));
      await tester.pump(const Duration(milliseconds: 50));
      controller.rotateRight();
      await tester.pumpAndSettle();
      expect(controller.value.rotationQuarterTurns, 1);

      await _pumpViewer(tester, controller: controller, image: revisionOf(1));
      for (
        var i = 0;
        i < 20 && controller.value.rotationQuarterTurns != 0;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }

      expect(controller.value.rotationQuarterTurns, 0);
      // Reset is immediate: nothing left to animate.
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('rotation commands animate toward quarter turns', (
      tester,
    ) async {
      final controller = InteractiveImageViewerController();
      final image = _buildSvgImage(
        const Color(0xFF1E88E5),
        width: 40,
        height: 20,
      );

      await _pumpViewer(tester, controller: controller, image: image);
      await tester.pump(const Duration(milliseconds: 50));

      controller.rotateRight();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 130));

      final midAnimationRotation = _rotationTransform(tester).storage;
      expect(midAnimationRotation[0].abs(), lessThan(0.99));
      expect(
        midAnimationRotation[1].abs() + midAnimationRotation[4].abs(),
        greaterThan(0.1),
      );

      await tester.pump(const Duration(milliseconds: 200));

      final completedRotation = _rotationTransform(tester).storage;
      expect(completedRotation[0].abs(), lessThan(0.1));
      expect(
        completedRotation[1].abs() + completedRotation[4].abs(),
        greaterThan(0.9),
      );
    });

    testWidgets('image changes cross-fade after the next image resolves', (
      tester,
    ) async {
      final controller = InteractiveImageViewerController();
      final image1 = _buildSvgImage(
        const Color(0xFF43A047),
        width: 48,
        height: 24,
      );
      final image2 = _buildSvgImage(
        const Color(0xFFFDD835),
        width: 48,
        height: 24,
      );

      await _pumpViewer(tester, controller: controller, image: image1);
      await tester.pump(const Duration(milliseconds: 50));

      final firstImageKey = ValueKey<Object>(image1.providerIdentity);
      final secondImageKey = ValueKey<Object>(image2.providerIdentity);
      expect(find.byKey(firstImageKey), findsOneWidget);
      expect(find.byKey(secondImageKey), findsNothing);

      await _pumpViewer(tester, controller: controller, image: image2);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 40));

      expect(find.byKey(firstImageKey), findsOneWidget);
      expect(find.byKey(secondImageKey), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 240));

      expect(find.byKey(firstImageKey), findsNothing);
      expect(find.byKey(secondImageKey), findsOneWidget);
    });

    testWidgets('overlay is sized to the fitted image and zooms with it', (
      tester,
    ) async {
      final controller = InteractiveImageViewerController();
      final image = _buildSvgImage(
        const Color(0xFF1E88E5),
        width: 40,
        height: 20,
      );
      const overlayKey = ValueKey<String>('overlay');
      Size? fittedSize;

      await _pumpViewer(
        tester,
        controller: controller,
        image: image,
        overlayBuilder: (context, size) {
          fittedSize = size;
          return const SizedBox.expand(key: overlayKey);
        },
      );
      for (var i = 0; i < 20 && controller.value.imageInfo == null; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pump();

      // A 2:1 image fitted into 320x240.
      expect(fittedSize, const Size(320, 160));
      expect(tester.getSize(find.byKey(overlayKey)), const Size(320, 160));

      controller.zoomIn();
      await tester.pumpAndSettle();
      final zoomedRect = tester.getRect(find.byKey(overlayKey));
      expect(zoomedRect.width, closeTo(320 * 1.2, 0.5));
    });
  });
}

Future<void> _pumpViewer(
  WidgetTester tester, {
  required InteractiveImageViewerController controller,
  required AppImage image,
  Widget Function(BuildContext context, Size fittedImageSize)? overlayBuilder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            height: 240,
            child: InteractiveImageViewer(
              controller: controller,
              image: image,
              overlayBuilder: overlayBuilder,
            ),
          ),
        ),
      ),
    ),
  );
}

AppImage _buildSvgImage(
  Color color, {
  required int width,
  required int height,
}) {
  return AppImage(
    image: null,
    svgBytesLoader: SvgStringLoader(
      _svgMarkup(color, width: width, height: height),
    ),
    fit: BoxFit.contain,
    filterQuality: FilterQuality.none,
  );
}

String _svgMarkup(Color color, {required int width, required int height}) {
  final colorHex = color
      .toARGB32()
      .toRadixString(16)
      .padLeft(8, '0')
      .substring(2);
  return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height">
  <rect width="$width" height="$height" fill="#$colorHex" />
</svg>
''';
}

Matrix4 _scaleTransform(WidgetTester tester) {
  return tester
      .widget<Transform>(
        find.byKey(
          const ValueKey<String>('interactive_image_viewer.scale_transform'),
        ),
      )
      .transform;
}

Matrix4 _rotationTransform(WidgetTester tester) {
  return tester
      .widget<Transform>(
        find.byKey(
          const ValueKey<String>('interactive_image_viewer.rotation_transform'),
        ),
      )
      .transform;
}
