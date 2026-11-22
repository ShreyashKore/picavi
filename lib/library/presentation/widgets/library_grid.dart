import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/services/thumbnail_cache.dart';
import '../../domain/entities/catalog_image.dart';

/// The photo grid, optionally grouped into month sections (newest first).
class LibraryGrid extends StatelessWidget {
  const LibraryGrid({
    super.key,
    required this.images,
    required this.selection,
    required this.cache,
    required this.tileExtent,
    required this.groupByMonth,
    required this.onTap,
    required this.onOpen,
    this.scrollController,
  });

  final List<CatalogImage> images;
  final Set<String> selection;
  final ThumbnailCache cache;
  final double tileExtent;
  final bool groupByMonth;
  final ValueChanged<CatalogImage> onTap;
  final ValueChanged<CatalogImage> onOpen;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final sections = groupByMonth
        ? _byMonth(images)
        : [(null as DateTime?, images)];
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = DateFormat.yMMMM(locale);

    return Scrollbar(
      controller: scrollController,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          for (final (month, items) in sections) ...[
            if (month != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
                  child: Text(
                    '${format.format(month)}  ·  ${context.l10n.libraryPhotoCount(items.length)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(12, month == null ? 12 : 0, 12, 4),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: tileExtent,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final image = items[index];
                  return _Tile(
                    key: ValueKey(image.path),
                    image: image,
                    cache: cache,
                    selected: selection.contains(image.path),
                    onTap: () => onTap(image),
                    onOpen: () => onOpen(image),
                  );
                },
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  static List<(DateTime?, List<CatalogImage>)> _byMonth(
    List<CatalogImage> images,
  ) {
    final sections = <(DateTime?, List<CatalogImage>)>[];
    for (final image in images) {
      final month = DateTime(image.date.year, image.date.month);
      if (sections.isEmpty || sections.last.$1 != month) {
        sections.add((month, <CatalogImage>[]));
      }
      sections.last.$2.add(image);
    }
    return sections;
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    super.key,
    required this.image,
    required this.cache,
    required this.selected,
    required this.onTap,
    required this.onOpen,
  });

  final CatalogImage image;
  final ThumbnailCache cache;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  DateTime? _lastTap;

  /// Single clicks select right away; a second click soon after opens.
  void _handleTap() {
    final now = DateTime.now();
    final last = _lastTap;
    _lastTap = now;
    if (last != null &&
        now.difference(last) < const Duration(milliseconds: 400)) {
      _lastTap = null;
      widget.onOpen();
    } else {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final image = widget.image;
    Widget tile = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.brokenImage),
          Image(
            image: CachedThumbnailImage(widget.cache, image),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.broken_image_outlined, size: 20),
            ),
          ),
          if (image.info.starred)
            const PositionedDirectional(
              start: 4,
              top: 4,
              child: Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFFFC94D),
                shadows: [Shadow(blurRadius: 3)],
              ),
            ),
          if (image.edits.isNotEmpty)
            const PositionedDirectional(
              end: 4,
              bottom: 4,
              child: Icon(
                Icons.tune_rounded,
                size: 14,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 3)],
              ),
            ),
          if (widget.selected)
            DecoratedBox(
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.25),
                border: Border.all(color: primary, width: 3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
        ],
      ),
    );
    if (image.info.hidden) {
      tile = Opacity(opacity: 0.4, child: tile);
    }
    return Tooltip(
      message: image.info.caption.isEmpty
          ? image.name
          : '${image.name}\n${image.info.caption}',
      waitDuration: const Duration(milliseconds: 800),
      child: Semantics(
        label: image.name,
        selected: widget.selected,
        button: true,
        child: GestureDetector(onTap: _handleTap, child: tile),
      ),
    );
  }
}
