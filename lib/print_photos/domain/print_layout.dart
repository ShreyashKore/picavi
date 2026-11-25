/// How many photos go on each printed page.
enum PrintLayout {
  one(1, 1),
  two(1, 2),
  four(2, 2),
  nine(3, 3);

  const PrintLayout(this.columns, this.rows);

  /// For a portrait page; swapped on landscape pages.
  final int columns;
  final int rows;

  int get perPage => columns * rows;

  /// Long edge to render each photo at: plenty for 300 dpi at its size.
  int get renderSize => switch (this) {
    one => 3000,
    two => 2200,
    four => 1600,
    nine => 1100,
  };
}
