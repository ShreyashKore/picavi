import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../domain/entities/recognized_text.dart';
import '../../domain/services/text_recognition_service.dart';

/// A word's position in [RecognizedText]: line index and word index.
@immutable
class LiveTextWordRef {
  const LiveTextWordRef(this.line, this.word);

  final int line;
  final int word;

  @override
  bool operator ==(Object other) =>
      other is LiveTextWordRef && other.line == line && other.word == word;

  @override
  int get hashCode => Object.hash(line, word);
}

/// Runs Live Text recognition for the image on screen and holds the word
/// selection. Words are addressed by their index in reading order.
class LiveTextController extends ChangeNotifier {
  LiveTextController(this._service, {this.cacheSize = 8});

  final TextRecognitionService _service;
  final int cacheSize;
  final LinkedHashMap<String, RecognizedText> _cache =
      LinkedHashMap<String, RecognizedText>();

  String? _key;
  RecognizedText? _text;
  List<LiveTextWordRef> _words = const [];
  int? _anchor;
  int? _extent;
  bool _isDisposed = false;

  bool get isAvailable => _service.isAvailable;

  /// Identifies the image the current [text] belongs to.
  String? get key => _key;

  /// Text in the current image; null while recognizing or when none.
  RecognizedText? get text => _text;

  bool get hasText => _words.isNotEmpty;

  /// Every word in reading order.
  List<LiveTextWordRef> get words => _words;

  bool get hasSelection => _anchor != null && _extent != null;

  /// First and last selected word index (inclusive), or null.
  (int, int)? get selectedRange {
    final anchor = _anchor;
    final extent = _extent;
    if (anchor == null || extent == null) {
      return null;
    }
    return (math.min(anchor, extent), math.max(anchor, extent));
  }

  bool isSelected(int wordIndex) {
    final range = selectedRange;
    return range != null && wordIndex >= range.$1 && wordIndex <= range.$2;
  }

  /// The selected text with the original spacing inside each line and a
  /// newline between lines.
  String? get selectedText {
    final range = selectedRange;
    final text = _text;
    if (range == null || text == null) {
      return null;
    }

    final parts = <String>[];
    var index = 0;
    for (final line in text.lines) {
      int? first;
      int? last;
      for (final word in line.words) {
        if (index >= range.$1 && index <= range.$2) {
          first ??= word.start;
          last = word.end;
        }
        index++;
      }
      if (first != null && last != null) {
        parts.add(line.text.substring(first, last));
      }
    }
    return parts.isEmpty ? null : parts.join('\n');
  }

  /// Recognizes text for the image identified by [key]. Results are cached;
  /// a response for an image that is no longer current is dropped.
  Future<void> analyze(
    String key,
    Future<TextRecognitionSource?> Function() loadSource,
  ) async {
    if (!isAvailable || key == _key) {
      return;
    }

    _key = key;
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      _setText(cached);
      return;
    }
    _setText(null);

    RecognizedText? result;
    try {
      final source = await loadSource();
      if (source != null && _key == key) {
        result = await _service.recognize(source);
      }
    } catch (error) {
      debugPrint('Live Text: unable to analyze $key: $error');
    }
    if (_isDisposed || result == null) {
      return;
    }

    _cache[key] = result;
    while (_cache.length > cacheSize) {
      _cache.remove(_cache.keys.first);
    }
    if (_key == key) {
      _setText(result);
    }
  }

  /// Forgets the current image (e.g. while Live Text is off).
  void clear() {
    _key = null;
    _setText(null);
  }

  /// Drops cached results, e.g. after files changed on disk.
  void evict(bool Function(String key) test) {
    _cache.removeWhere((key, _) => test(key));
  }

  void select(int anchor, int extent) {
    if (_words.isEmpty) {
      return;
    }
    final last = _words.length - 1;
    final nextAnchor = anchor.clamp(0, last);
    final nextExtent = extent.clamp(0, last);
    if (nextAnchor == _anchor && nextExtent == _extent) {
      return;
    }
    _anchor = nextAnchor;
    _extent = nextExtent;
    notifyListeners();
  }

  void selectWord(int index) => select(index, index);

  /// Selects every word on the line containing word [index].
  void selectLine(int index) {
    if (index < 0 || index >= _words.length) {
      return;
    }
    final line = _words[index].line;
    final first = _words.indexWhere((ref) => ref.line == line);
    final last = _words.lastIndexWhere((ref) => ref.line == line);
    select(first, last);
  }

  void selectAll() {
    if (_words.isNotEmpty) {
      select(0, _words.length - 1);
    }
  }

  void clearSelection() {
    if (!hasSelection) {
      return;
    }
    _anchor = null;
    _extent = null;
    notifyListeners();
  }

  void _setText(RecognizedText? text) {
    _text = text;
    _words = [
      if (text != null)
        for (var line = 0; line < text.lines.length; line++)
          for (var word = 0; word < text.lines[line].words.length; word++)
            LiveTextWordRef(line, word),
    ];
    _anchor = null;
    _extent = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
