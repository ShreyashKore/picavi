import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/l10n/generated/app_localizations.dart';
import 'package:oiv/library/data/library_services.dart';
import 'package:oiv/library/data/services/thumbnail_cache.dart';
import 'package:oiv/library/presentation/screens/library_screen.dart';

import 'support/editor_fakes.dart';
import 'support/library_fakes.dart';

void main() {
  late Directory thumbs;
  late LibraryFixture fixture;
  String? opened;

  setUp(() async {
    thumbs = await Directory.systemTemp.createTemp('oiv_lib_thumbs');
    fixture = LibraryFixture([
      catalogPhoto('/pics/goa/beach.jpg', taken: DateTime(2019, 7, 14)),
      catalogPhoto('/pics/home/cat.jpg', taken: DateTime(2021, 3, 1)),
    ]);
    opened = null;
  });

  tearDown(() async {
    await fixture.catalog.close();
    await thumbs.delete(recursive: true);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> openLibrary(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final services = LibraryServices(
      catalog: fixture.catalog,
      thumbnails: ThumbnailCache(thumbs.path, pixelSource: FakePixelSource()),
      settings: fixture.settings,
      photoInfo: InMemoryPhotoInfoRepository(),
      fileOperations: fixture.files,
      indexer: fixture.indexer,
      duplicateFinder: fixture.duplicates,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              opened = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => LibraryScreen(
                    services: services,
                    pickFolder: () async => '/pics',
                  ),
                ),
              );
            },
            child: const Text('library'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('library'));
    await settle(tester);
  }

  testWidgets('add a folder, browse by month, select and open', (tester) async {
    await openLibrary(tester);

    expect(find.text('Build your photo library'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add folder…'));
    await settle(tester);

    expect(find.textContaining('March 2021'), findsOneWidget);
    expect(find.textContaining('July 2019'), findsOneWidget);
    expect(find.text('goa'), findsOneWidget);

    final beach = find.bySemanticsLabel('beach.jpg');
    await tester.tap(beach);
    await tester.pump();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.text('Star'));
    await settle(tester);
    await tester.tap(find.text('Starred'));
    await settle(tester);
    expect(find.bySemanticsLabel('cat.jpg'), findsNothing);

    await tester.tap(find.bySemanticsLabel('beach.jpg'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.bySemanticsLabel('beach.jpg'));
    await settle(tester);

    expect(find.byType(LibraryScreen), findsNothing);
    expect(opened, '/pics/goa/beach.jpg');
  });

  testWidgets('create an album from the selection', (tester) async {
    fixture.settings.roots = ['/pics'];
    await openLibrary(tester);

    await tester.tap(find.bySemanticsLabel('cat.jpg'));
    await tester.pump();
    await tester.tap(find.text('Add to album'));
    await settle(tester);
    await tester.tap(find.text('New album').last);
    await settle(tester);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Pets',
    );
    await tester.pump();
    await tester.tap(find.text('Create'));
    await settle(tester);

    expect(find.text('Pets'), findsOneWidget);
    expect(
      (await tester.runAsync(fixture.catalog.albums))!.single.imageCount,
      1,
    );
  });
}
