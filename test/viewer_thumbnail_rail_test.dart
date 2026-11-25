import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/l10n/generated/app_localizations.dart';
import 'package:oiv/viewer/domain/entities/gallery_image.dart';
import 'package:oiv/viewer/presentation/widgets/viewer_thumbnail_rail.dart';

const double _extent = 84;

final _images = [
  for (var i = 0; i < 30; i++)
    GalleryImage(path: '/nonexistent/picavi-rail-test/$i.jpg'),
];

Widget _rail(ScrollController controller, int currentIndex) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 600,
          child: ViewerThumbnailRail(
            images: _images,
            currentIndex: currentIndex,
            thumbnailExtent: _extent,
            scrollController: controller,
            onTap: (_) {},
            onScrollImageChange: (_) {},
          ),
        ),
      ),
    ),
  );
}

Rect _thumbnailRect(WidgetTester tester, int index) => tester.getRect(
  find.byKey(ValueKey<String>('thumbnail-${_images[index].path}')),
);

void _expectSize(Size actual, Size expected) {
  expect(actual.width, moreOrLessEquals(expected.width));
  expect(actual.height, moreOrLessEquals(expected.height));
}

void main() {
  testWidgets('keeps the current thumbnail centred and larger', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final railCenterX =
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;

    for (final index in [0, 5, 6, 29]) {
      await tester.pumpWidget(_rail(controller, index));
      await tester.pumpAndSettle();

      final selected = _thumbnailRect(tester, index);
      expect(selected.center.dx, moreOrLessEquals(railCenterX, epsilon: 0.5));
      _expectSize(selected.size, ViewerThumbnailRail.selectedSize(_extent));
      expect(
        controller.offset,
        moreOrLessEquals(index * ViewerThumbnailRail.itemStride(_extent)),
      );

      final neighbour = _thumbnailRect(tester, index == 0 ? 1 : index - 1);
      _expectSize(neighbour.size, ViewerThumbnailRail.unselectedSize(_extent));
      expect(neighbour.width, lessThan(selected.width));
    }
  });

  testWidgets('animates to the new image instead of jumping', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_rail(controller, 3));
    await tester.pumpAndSettle();
    final start = controller.offset;

    await tester.pumpWidget(_rail(controller, 4));
    await tester.pump(); // post-frame callback starts the scroll
    await tester.pump(const Duration(milliseconds: 60));
    final target = 4 * ViewerThumbnailRail.itemStride(_extent);
    expect(controller.offset, greaterThan(start));
    expect(controller.offset, lessThan(target));

    await tester.pumpAndSettle();
    expect(controller.offset, moreOrLessEquals(target));
  });
}
