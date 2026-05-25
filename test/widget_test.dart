import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/main.dart';

void main() {
  testWidgets('shows viewer empty state before an image is opened', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OivApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Picavi desktop viewer'), findsOneWidget);
    expect(find.text('Open image'), findsOneWidget);
    expect(find.textContaining('gesture zoom'), findsOneWidget);
  });
}
