import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../editor/domain/entities/rgba_image.dart';
import '../domain/collage_options.dart';

/// A photo ready to place: its pixels and its file name (for captions).
class CollageTile {
  const CollageTile(this.image, this.name);

  final RgbaImage image;
  final String name;

  double get aspect => image.width / image.height;
}

/// One rectangle on the canvas, in pixels.
class Slot {
  const Slot(this.x, this.y, this.width, this.height);

  final int x;
  final int y;
  final int width;
  final int height;
}

/// Renders a collage page as a pure-Dart image. Runs in an isolate.
List<img.Image> renderCollagePages(
  List<CollageTile> tiles,
  CollageOptions options,
) {
  switch (options.layout) {
    case CollageLayout.grid:
      return [
        _renderSlots(
          tiles,
          gridSlots(tiles.length, options),
          options,
          cover: true,
        ),
      ];
    case CollageLayout.mosaic:
      return [
        _renderSlots(
          tiles,
          mosaicSlots([for (final t in tiles) t.aspect], options),
          options,
          cover: true,
        ),
      ];
    case CollageLayout.contactSheet:
      const perPage = CollageOptions.sheetColumns * CollageOptions.sheetRows;
      return [
        for (var start = 0; start < tiles.length; start += perPage)
          _renderContactSheet(
            tiles.sublist(start, math.min(start + perPage, tiles.length)),
            options,
          ),
      ];
  }
}

int _gap(CollageOptions options) =>
    (math.min(options.width, options.height) * options.spacing).round();

/// A near-square grid of equal cells that fills the canvas.
List<Slot> gridSlots(int count, CollageOptions options) {
  if (count == 0) {
    return const [];
  }
  final gap = _gap(options);
  final w = options.width;
  final h = options.height;
  var columns = math.max(1, math.sqrt(count * w / h).round());
  columns = math.min(columns, count);
  final rows = (count / columns).ceil();
  final cellWidth = (w - gap * (columns + 1)) / columns;
  final cellHeight = (h - gap * (rows + 1)) / rows;
  return [
    for (var i = 0; i < count; i++)
      Slot(
        (gap + (i % columns) * (cellWidth + gap)).round(),
        (gap + (i ~/ columns) * (cellHeight + gap)).round(),
        cellWidth.floor(),
        cellHeight.floor(),
      ),
  ];
}

/// Justified rows: each row keeps its photos' shapes and spans the full
/// width; the row height is chosen so all rows fill the canvas height.
List<Slot> mosaicSlots(List<double> aspects, CollageOptions options) {
  if (aspects.isEmpty) {
    return const [];
  }
  final gap = _gap(options);
  final width = options.width - 2 * gap;
  final height = options.height - 2 * gap;

  List<List<int>> rowsFor(double target) {
    final rows = <List<int>>[];
    var row = <int>[];
    var rowAspect = 0.0;
    for (var i = 0; i < aspects.length; i++) {
      row.add(i);
      rowAspect += aspects[i];
      if (rowAspect * target + gap * (row.length - 1) >= width) {
        rows.add(row);
        row = <int>[];
        rowAspect = 0;
      }
    }
    if (row.isNotEmpty) {
      rows.add(row);
    }
    return rows;
  }

  double rowHeight(List<int> row) {
    final aspect = row.fold<double>(0, (sum, i) => sum + aspects[i]);
    return (width - gap * (row.length - 1)) / aspect;
  }

  double totalHeight(List<List<int>> rows) =>
      rows.fold<double>(0, (sum, row) => sum + rowHeight(row)) +
      gap * (rows.length - 1);

  // Find the target row height whose rows best fill the canvas height.
  var best = rowsFor(height.toDouble());
  var bestError = double.infinity;
  for (var target = 20.0; target <= height; target *= 1.05) {
    final rows = rowsFor(target);
    final error = (totalHeight(rows) - height).abs();
    if (error < bestError) {
      bestError = error;
      best = rows;
    }
  }

  // Scale rows vertically so they fill the height exactly.
  final scale =
      (height - gap * (best.length - 1)) /
      best.fold<double>(0, (sum, row) => sum + rowHeight(row));
  final slots = List<Slot?>.filled(aspects.length, null);
  var y = gap.toDouble();
  for (final row in best) {
    final rowH = rowHeight(row) * scale;
    var x = gap.toDouble();
    for (final i in row) {
      final cellW = rowHeight(row) * aspects[i];
      slots[i] = Slot(x.round(), y.round(), cellW.round(), rowH.round());
      x += cellW + gap;
    }
    y += rowH + gap;
  }
  return slots.cast<Slot>();
}

img.Image _canvas(CollageOptions options) {
  final canvas = img.Image(width: options.width, height: options.height);
  final argb = options.background.argb;
  img.fill(
    canvas,
    color: img.ColorRgb8((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF),
  );
  return canvas;
}

img.Image _toImage(RgbaImage rgba) => img.Image.fromBytes(
  width: rgba.width,
  height: rgba.height,
  bytes: rgba.pixels.buffer,
  bytesOffset: rgba.pixels.offsetInBytes,
  numChannels: 4,
);

img.Image _renderSlots(
  List<CollageTile> tiles,
  List<Slot> slots,
  CollageOptions options, {
  required bool cover,
}) {
  final canvas = _canvas(options);
  for (var i = 0; i < tiles.length && i < slots.length; i++) {
    _place(canvas, _toImage(tiles[i].image), slots[i], cover: cover);
  }
  return canvas;
}

/// Draws [photo] into [slot]: cropped to fill it ([cover]) or fitted inside.
void _place(
  img.Image canvas,
  img.Image photo,
  Slot slot, {
  required bool cover,
}) {
  if (slot.width <= 0 || slot.height <= 0) {
    return;
  }
  final scale = cover
      ? math.max(slot.width / photo.width, slot.height / photo.height)
      : math.min(slot.width / photo.width, slot.height / photo.height);
  final drawWidth = math.max(1, (photo.width * scale).round());
  final drawHeight = math.max(1, (photo.height * scale).round());
  final resized = img.copyResize(
    photo,
    width: drawWidth,
    height: drawHeight,
    interpolation: img.Interpolation.average,
  );
  final cropX = math.max(0, (drawWidth - slot.width) ~/ 2);
  final cropY = math.max(0, (drawHeight - slot.height) ~/ 2);
  final offsetX = math.max(0, (slot.width - drawWidth) ~/ 2);
  final offsetY = math.max(0, (slot.height - drawHeight) ~/ 2);
  img.compositeImage(
    canvas,
    resized,
    dstX: slot.x + offsetX,
    dstY: slot.y + offsetY,
    srcX: cropX,
    srcY: cropY,
    srcW: math.min(slot.width, drawWidth),
    srcH: math.min(slot.height, drawHeight),
  );
}

img.Image _renderContactSheet(List<CollageTile> tiles, CollageOptions options) {
  final canvas = _canvas(options);
  const columns = CollageOptions.sheetColumns;
  const rows = CollageOptions.sheetRows;
  const margin = 60;
  const caption = 26;
  final cellWidth = (options.width - margin * 2) / columns;
  final cellHeight = (options.height - margin * 2) / rows;
  final argb = options.background.argb;
  final dark =
      ((argb >> 16) & 0xFF) + ((argb >> 8) & 0xFF) + (argb & 0xFF) < 384;
  final textColor = dark
      ? img.ColorRgb8(230, 230, 230)
      : img.ColorRgb8(40, 40, 40);
  for (var i = 0; i < tiles.length; i++) {
    final x = margin + (i % columns) * cellWidth;
    final y = margin + (i ~/ columns) * cellHeight;
    final slot = Slot(
      (x + 8).round(),
      (y + 8).round(),
      (cellWidth - 16).floor(),
      (cellHeight - 16 - caption).floor(),
    );
    _place(canvas, _toImage(tiles[i].image), slot, cover: false);
    img.drawString(
      canvas,
      _ellipsize(p.basename(tiles[i].name), 24),
      font: img.arial14,
      x: slot.x,
      y: slot.y + slot.height + 6,
      color: textColor,
    );
  }
  return canvas;
}

String _ellipsize(String text, int max) =>
    text.length <= max ? text : '${text.substring(0, max - 3)}...';
