/// What the user said about a photo: Picasa's star, caption and tags, and
/// whether it is hidden from the library. Stored next to the photo, never
/// inside it.
class PhotoInfo {
  const PhotoInfo({
    this.starred = false,
    this.caption = '',
    this.tags = const <String>[],
    this.hidden = false,
  });

  static const PhotoInfo none = PhotoInfo();

  final bool starred;
  final String caption;
  final List<String> tags;
  final bool hidden;

  bool get isEmpty => !starred && caption.isEmpty && tags.isEmpty && !hidden;

  PhotoInfo copyWith({
    bool? starred,
    String? caption,
    List<String>? tags,
    bool? hidden,
  }) {
    return PhotoInfo(
      starred: starred ?? this.starred,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      hidden: hidden ?? this.hidden,
    );
  }

  /// Splits comma-separated text into trimmed, de-duplicated tags.
  static List<String> parseTags(String text) {
    final seen = <String>{};
    return [
      for (final raw in text.split(','))
        if (raw.trim().isNotEmpty && seen.add(raw.trim().toLowerCase()))
          raw.trim(),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is PhotoInfo &&
      other.starred == starred &&
      other.caption == caption &&
      other.hidden == hidden &&
      other.tags.length == tags.length &&
      Iterable<int>.generate(
        tags.length,
      ).every((i) => other.tags[i] == tags[i]);

  @override
  int get hashCode =>
      Object.hash(starred, caption, Object.hashAll(tags), hidden);
}
