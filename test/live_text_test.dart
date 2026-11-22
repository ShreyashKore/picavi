import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/viewer/data/services/vision_text_recognition_service.dart';
import 'package:oiv/viewer/domain/entities/recognized_text.dart';
import 'package:oiv/viewer/domain/services/text_recognition_service.dart';
import 'package:oiv/viewer/presentation/controllers/live_text_controller.dart';
import 'package:oiv/viewer/presentation/widgets/live_text_overlay.dart';

void main() {
  group('parseRecognizedText', () {
    test('reads lines, words and quads', () {
      final text = parseRecognizedText(_payload)!;

      expect(text.lines, hasLength(2));
      expect(text.lines.first.text, 'Hello, world!');
      expect(text.lines.first.words, hasLength(2));
      expect(text.lines.first.wordText(text.lines.first.words.last), 'world!');
      expect(text.lines.first.quad.topLeft, const NormalizedPoint(0.1, 0.1));
      expect(text.lines.last.words.single.quad.bottomRight.y, 0.5);
      expect(text.fullText, 'Hello, world!\nPicavi');
    });

    test('skips malformed entries and rejects bad payloads', () {
      expect(parseRecognizedText(null), isNull);
      expect(parseRecognizedText({'lines': 'nope'}), isNull);

      final text = parseRecognizedText({
        'lines': [
          'junk',
          {'text': 'no quad', 'words': <Object>[]},
          {
            'text': 'abc',
            'quad': _quad(0, 0, 1, 0.1),
            'words': [
              {'start': 0, 'end': 9, 'quad': _quad(0, 0, 1, 0.1)},
              {'start': 0, 'end': 3, 'quad': <double>[1, 2]},
              {'start': 0, 'end': 3, 'quad': _quad(0, 0, 1, 0.1)},
            ],
          },
        ],
      })!;

      expect(text.lines, hasLength(1));
      expect(text.lines.single.words, hasLength(1));
    });
  });

  group('LiveTextController', () {
    test('recognizes, selects and joins text across lines', () async {
      final service = _FakeRecognitionService();
      final controller = LiveTextController(service);
      addTearDown(controller.dispose);

      await controller.analyze('a', () async => _source('a'));
      expect(controller.hasText, isTrue);
      expect(controller.words, hasLength(3));
      expect(controller.hasSelection, isFalse);

      controller.select(2, 1);
      expect(controller.selectedRange, (1, 2));
      expect(controller.selectedText, 'world!\nPicavi');

      controller.selectLine(0);
      expect(controller.selectedText, 'Hello, world!');

      controller.selectAll();
      expect(controller.selectedText, 'Hello, world!\nPicavi');

      controller.clearSelection();
      expect(controller.selectedText, isNull);
    });

    test('drops results for an image that is no longer current', () async {
      final service = _FakeRecognitionService()..holdNext = true;
      final controller = LiveTextController(service);
      addTearDown(controller.dispose);

      final first = controller.analyze('a', () async => _source('a'));
      await Future<void>.delayed(Duration.zero);
      controller.clear();
      service.release();
      await first;

      expect(controller.text, isNull);
      expect(controller.key, isNull);

      // The late result was still cached.
      await controller.analyze('a', () async => _source('a'));
      expect(service.calls, 1);
      expect(controller.hasText, isTrue);
    });

    test('cache keeps the most recent images only', () async {
      final service = _FakeRecognitionService();
      final controller = LiveTextController(service, cacheSize: 2);
      addTearDown(controller.dispose);

      for (final key in ['a', 'b', 'c', 'a']) {
        await controller.analyze(key, () async => _source(key));
      }
      expect(service.calls, 4);

      await controller.analyze('c', () async => _source('c'));
      expect(service.calls, 4);
    });

    test('does nothing when recognition is unavailable', () async {
      final service = _FakeRecognitionService()..available = false;
      final controller = LiveTextController(service);
      addTearDown(controller.dispose);

      await controller.analyze('a', () async => _source('a'));
      expect(service.calls, 0);
      expect(controller.hasText, isFalse);
    });
  });

  group('LiveTextOverlay', () {
    late LiveTextController controller;
    late int panStarts;

    Future<void> pumpOverlay(WidgetTester tester) async {
      controller = LiveTextController(_FakeRecognitionService());
      addTearDown(controller.dispose);
      panStarts = 0;
      await tester.runAsync(
        () => controller.analyze('a', () async => _source('a')),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (_) => panStarts++,
              child: SizedBox(
                width: 400,
                height: 200,
                child: LiveTextOverlay(controller: controller),
              ),
            ),
          ),
        ),
      );
    }

    // Overlay is 400x200: line 1 spans y 20–40, "Hello," x 40–160,
    // "world!" x 200–360; line 2 "Picavi" spans x 40–200, y 80–100.
    const hello = Offset(100, 30);
    const world = Offset(280, 30);
    const picavi = Offset(120, 90);
    const background = Offset(300, 170);

    testWidgets('dragging over text selects words instead of panning', (
      tester,
    ) async {
      await pumpOverlay(tester);

      final gesture = await tester.startGesture(hello);
      await gesture.moveTo(world);
      await gesture.moveTo(picavi);
      await gesture.up();
      await tester.pump();

      expect(controller.selectedText, 'Hello, world!\nPicavi');
      expect(panStarts, 0);
    });

    testWidgets('dragging outside text still pans and clears selection', (
      tester,
    ) async {
      await pumpOverlay(tester);
      controller.selectAll();

      final gesture = await tester.startGesture(background);
      await gesture.moveBy(const Offset(40, 0));
      await gesture.up();
      await tester.pump();

      expect(panStarts, 1);
      expect(controller.hasSelection, isFalse);
    });

    testWidgets('double-click selects a word, triple-click a line', (
      tester,
    ) async {
      await pumpOverlay(tester);

      await tester.tapAt(world, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(world, kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(controller.selectedText, 'world!');

      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(world, kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(controller.selectedText, 'Hello, world!');

      // A later single click clears it.
      await tester.pump(const Duration(seconds: 1));
      await tester.tapAt(hello, kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(controller.hasSelection, isFalse);
    });
  });
}

List<double> _quad(double left, double top, double right, double bottom) => [
  left,
  top,
  right,
  top,
  right,
  bottom,
  left,
  bottom,
];

final Map<String, Object?> _payload = {
  'lines': [
    {
      'text': 'Hello, world!',
      'quad': _quad(0.1, 0.1, 0.9, 0.2),
      'words': [
        {'start': 0, 'end': 6, 'quad': _quad(0.1, 0.1, 0.4, 0.2)},
        {'start': 7, 'end': 13, 'quad': _quad(0.5, 0.1, 0.9, 0.2)},
      ],
    },
    {
      'text': 'Picavi',
      'quad': _quad(0.1, 0.4, 0.5, 0.5),
      'words': [
        {'start': 0, 'end': 6, 'quad': _quad(0.1, 0.4, 0.5, 0.5)},
      ],
    },
  ],
};

TextRecognitionSource _source(String key) => FileTextRecognitionSource(key);

class _FakeRecognitionService implements TextRecognitionService {
  bool available = true;
  bool holdNext = false;
  int calls = 0;
  Completer<void>? _gate;

  void release() => _gate?.complete();

  @override
  bool get isAvailable => available;

  @override
  Future<RecognizedText?> recognize(TextRecognitionSource source) async {
    calls++;
    if (holdNext) {
      holdNext = false;
      _gate = Completer<void>();
      await _gate!.future;
    }
    return parseRecognizedText(_payload);
  }
}
