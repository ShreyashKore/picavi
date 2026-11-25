import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/editor/presentation/screens/editor_screen.dart';
import 'package:oiv/l10n/generated/app_localizations.dart';

import 'support/editor_fakes.dart';

const _path = '/photos/a.jpg';

void main() {
  late InMemoryImageEditRepository repository;
  ImageEdits? popped;

  Future<void> openEditor(WidgetTester tester, {Locale? locale}) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    popped = null;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                popped = await Navigator.of(context).push<ImageEdits>(
                  MaterialPageRoute(
                    builder: (_) => EditorScreen(
                      path: _path,
                      repository: repository,
                      pixelSource: FakePixelSource(gradientImage(80, 40)),
                      renderService: SyncRenderService(),
                      exportService: FakeExportService(),
                      pickExportDirectory: () async => null,
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
  }

  setUp(() {
    repository = InMemoryImageEditRepository();
  });

  testWidgets('crops with a preset and returns the edits when done', (
    tester,
  ) async {
    await openEditor(tester);

    expect(find.text('Basic fixes'), findsOneWidget);
    await tester.tap(find.text('Crop'));
    await settle(tester);
    await tester.tap(find.text('Square'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await settle(tester);

    final crop = repository.stored[_path]!.operations.single as CropEdit;
    expect(crop.rect.width, closeTo(0.5, 1e-9));
    expect(find.text('Basic fixes'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(popped?.operations.single, crop);
  });

  testWidgets('tab labels stay on one line in every language', (tester) async {
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(const SizedBox());
      await openEditor(tester, locale: locale);

      final l10n = lookupAppLocalizations(locale);
      for (final label in [
        l10n.editorTabFixes,
        l10n.editorTabTuning,
        l10n.editorTabEffects,
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label),
        );
        final lines = paragraph
            .getBoxesForSelection(
              TextSelection(baseOffset: 0, extentOffset: label.length),
            )
            .map((box) => box.top.round())
            .toSet();
        expect(lines, hasLength(1), reason: '$locale "$label" wraps');
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason: '$locale "$label" is cut off',
        );
      }
    }
  });

  testWidgets('tuning is applied when leaving the tab', (tester) async {
    await openEditor(tester);

    await tester.tap(find.text('Tuning'));
    await settle(tester);
    await tester.drag(find.byType(Slider).first, const Offset(80, 0));
    await settle(tester);
    expect(repository.stored, isEmpty);

    await tester.tap(find.text('Effects'));
    await settle(tester);

    final tune = repository.stored[_path]!.operations.single as TuneEdit;
    expect(tune.fillLight, greaterThan(0));
  });

  testWidgets('effects preview, then apply; undo removes them', (tester) async {
    await openEditor(tester);

    await tester.tap(find.text('Effects'));
    await settle(tester);
    await tester.tap(find.text('Sepia'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await settle(tester);
    expect(
      repository.stored[_path]!.operations.single,
      const EffectEdit(EffectKind.sepia, 1),
    );

    await tester.tap(find.byTooltip('Undo'));
    await settle(tester);
    expect(repository.stored, isEmpty);
  });

  testWidgets('escape closes an open tool, then the editor', (tester) async {
    await openEditor(tester);

    await tester.tap(find.text('Straighten'));
    await settle(tester);
    expect(find.byType(Slider), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.text('Basic fixes'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.byType(EditorScreen), findsNothing);
    expect(popped, ImageEdits.none);
  });
}

/// Lets fake async work and image uploads finish, then settles animations.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
