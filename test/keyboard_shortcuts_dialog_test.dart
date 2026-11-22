import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/l10n/generated/app_localizations.dart';
import 'package:oiv/viewer/presentation/widgets/keyboard_shortcuts_dialog.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showKeyboardShortcutsDialog(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the viewer shortcuts and closes', (tester) async {
    await pumpDialog(tester, const Locale('en'));

    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('Play / pause slideshow'), findsOneWidget);
    expect(find.text('Space'), findsOneWidget);
    expect(find.text('Rotate right / left'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsNothing);
  });

  testWidgets('is localized', (tester) async {
    await pumpDialog(tester, const Locale('es'));

    expect(find.text('Atajos de teclado'), findsOneWidget);
    expect(find.text('Cerrar'), findsOneWidget);
  });
}
