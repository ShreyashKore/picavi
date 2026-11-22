import 'dart:math';

/// How the slideshow advances.
class SlideshowSettings {
  const SlideshowSettings({
    this.intervalSeconds = defaultIntervalSeconds,
    this.shuffle = false,
    this.loop = true,
    this.fullScreen = false,
  });

  static const int defaultIntervalSeconds = 3;

  /// Choices offered in Settings.
  static const List<int> intervalChoices = <int>[2, 3, 5, 8, 10, 15, 30];

  final int intervalSeconds;
  final bool shuffle;
  final bool loop;

  /// Switch the window to full screen while the slideshow plays.
  final bool fullScreen;

  Duration get interval => Duration(seconds: intervalSeconds);

  SlideshowSettings copyWith({
    int? intervalSeconds,
    bool? shuffle,
    bool? loop,
    bool? fullScreen,
  }) {
    return SlideshowSettings(
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      shuffle: shuffle ?? this.shuffle,
      loop: loop ?? this.loop,
      fullScreen: fullScreen ?? this.fullScreen,
    );
  }
}

/// Decides which image the slideshow shows next.
class SlideshowSequencer {
  SlideshowSequencer({
    required this.imageCount,
    required int startIndex,
    required this.shuffle,
    required this.loop,
    Random? random,
  }) : _random = random ?? Random(),
       _current = startIndex {
    if (shuffle) {
      _refillShuffleQueue();
    }
  }

  final int imageCount;
  final bool shuffle;
  final bool loop;
  final Random _random;
  final List<int> _queue = <int>[];
  int _current;

  /// The next index to show, or null when the slideshow should stop.
  ///
  /// [currentIndex] is the image on screen now; an in-order slideshow
  /// continues from it, so manual navigation while playing is respected.
  int? next({int? currentIndex}) {
    if (imageCount < 2) {
      return null;
    }

    if (!shuffle) {
      if (currentIndex != null) {
        _current = currentIndex;
      }
      final candidate = _current + 1;
      if (candidate >= imageCount) {
        if (!loop) {
          return null;
        }
        return _current = 0;
      }
      return _current = candidate;
    }

    if (_queue.isEmpty) {
      if (!loop) {
        return null;
      }
      _refillShuffleQueue();
    }
    return _current = _queue.removeLast();
  }

  /// Every image except the current one, in random order, so a pass never
  /// repeats an image and never starts with the one already on screen.
  void _refillShuffleQueue() {
    _queue
      ..clear()
      ..addAll(
        List<int>.generate(
          imageCount,
          (index) => index,
        ).where((index) => index != _current),
      )
      ..shuffle(_random);
  }
}
