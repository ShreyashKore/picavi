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
  });
}

Future<void> _pumpViewer(
  WidgetTester tester, {
  required InteractiveImageViewerController controller,
  required AppImage image,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            height: 240,
            child: InteractiveImageViewer(controller: controller, image: image),
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
