import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:oiv/core/services/app_preferences_service.dart';
import 'package:oiv/viewer/data/services/slideshow_settings_store.dart';
import 'package:oiv/viewer/domain/entities/slideshow_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<int?> run(SlideshowSequencer sequencer, int steps) =>
      List<int?>.generate(steps, (_) => sequencer.next());

  group('SlideshowSequencer', () {
    test('in order, looping', () {
      final sequencer = SlideshowSequencer(
        imageCount: 3,
        startIndex: 1,
        shuffle: false,
        loop: true,
      );
      expect(run(sequencer, 4), <int?>[2, 0, 1, 2]);
    });

    test('in order, stops after the last image without loop', () {
      final sequencer = SlideshowSequencer(
        imageCount: 3,
        startIndex: 0,
        shuffle: false,
        loop: false,
      );
      expect(run(sequencer, 3), <int?>[1, 2, null]);
    });

    test('follows manual navigation', () {
      final sequencer = SlideshowSequencer(
        imageCount: 5,
        startIndex: 0,
        shuffle: false,
        loop: true,
      );
      expect(sequencer.next(currentIndex: 3), 4);
    });

    test('shuffle visits every other image once per pass', () {
      final sequencer = SlideshowSequencer(
        imageCount: 6,
        startIndex: 2,
        shuffle: true,
        loop: false,
        random: Random(7),
      );
      final shown = run(sequencer, 6);
      expect(shown.last, isNull);
      expect(shown.take(5).toSet(), <int>{0, 1, 3, 4, 5});
    });

    test('shuffle with loop keeps going and never repeats back to back', () {
      final sequencer = SlideshowSequencer(
        imageCount: 4,
        startIndex: 0,
        shuffle: true,
        loop: true,
        random: Random(1),
      );
      final shown = run(sequencer, 20);
      expect(shown, everyElement(isNotNull));
      for (var i = 1; i < shown.length; i++) {
        expect(shown[i], isNot(shown[i - 1]));
      }
    });

    test('single image never advances', () {
      final sequencer = SlideshowSequencer(
        imageCount: 1,
        startIndex: 0,
        shuffle: false,
        loop: true,
      );
      expect(sequencer.next(), isNull);
    });
  });

  group('SlideshowSettingsStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('defaults, then round-trips saved settings', () async {
      final store = SlideshowSettingsStore(AppPreferencesService());
      final defaults = await store.load();
      expect(
        defaults.intervalSeconds,
        SlideshowSettings.defaultIntervalSeconds,
      );
      expect(defaults.loop, isTrue);
      expect(defaults.shuffle, isFalse);

      await store.save(
        const SlideshowSettings(
          intervalSeconds: 10,
          shuffle: true,
          loop: false,
          fullScreen: true,
        ),
      );
      final loaded = await store.load();
      expect(loaded.intervalSeconds, 10);
      expect(loaded.shuffle, isTrue);
      expect(loaded.loop, isFalse);
      expect(loaded.fullScreen, isTrue);
    });

    test('ignores an interval that is not offered', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'slideshowIntervalSeconds': 999,
      });
      final store = SlideshowSettingsStore(AppPreferencesService());
      expect(
        (await store.load()).intervalSeconds,
        SlideshowSettings.defaultIntervalSeconds,
      );
    });
  });
}
