import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../domain/entities/catalog_image.dart';
import '../models/folder_tree.dart';
import '../models/library_state.dart';

enum FolderAction { hide, show, reveal, removeFromLibrary }

enum AlbumAction { rename, delete }

/// All photos / Starred, albums and the folder tree.
class LibrarySidebar extends StatelessWidget {
  const LibrarySidebar({
    super.key,
    required this.state,
    required this.onAllPhotos,
    required this.onStarred,
    required this.onPlaces,
    required this.onPeople,
    required this.onFolder,
    required this.onAlbum,
    required this.onAddFolder,
    required this.onFolderAction,
    required this.onCreateAlbum,
    required this.onAlbumAction,
  });

  static const double width = 270;

  final LibraryState state;
  final VoidCallback onAllPhotos;
  final VoidCallback onStarred;
  final VoidCallback onPlaces;
  final VoidCallback onPeople;
  final ValueChanged<String> onFolder;
  final ValueChanged<int> onAlbum;
  final VoidCallback onAddFolder;
  final void Function(FolderNode folder, FolderAction action) onFolderAction;
  final VoidCallback onCreateAlbum;
  final void Function(Album album, AlbumAction action) onAlbumAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tree = buildFolderTree(
      state.roots,
      state.folders,
      state.hiddenFolders,
    );
    final visibleTree = state.showHidden
        ? tree
        : tree.where((node) => !node.isHidden || node.isRoot).toList();

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.panel,
        shape: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _Entry(
              icon: Icons.photo_library_outlined,
              label: l10n.libraryAllPhotos,
              selected: state.source == LibrarySource.allPhotos,
              onTap: onAllPhotos,
            ),
            _Entry(
              icon: Icons.star_outline_rounded,
              label: l10n.libraryStarred,
              selected: state.source == LibrarySource.starred,
              onTap: onStarred,
            ),
            _Entry(
              icon: Icons.place_outlined,
              label: l10n.placesTitle,
              selected: state.source == LibrarySource.places,
              onTap: onPlaces,
            ),
            _Entry(
              icon: Icons.people_outline,
              label: l10n.peopleTitle,
              selected: state.source == LibrarySource.people,
              onTap: onPeople,
            ),
            _Header(
              label: l10n.libraryAlbums,
              actionTooltip: l10n.libraryNewAlbum,
              onAction: onCreateAlbum,
            ),
            if (state.albums.isEmpty)
              _Placeholder(text: l10n.libraryNoAlbums)
            else
              for (final album in state.albums)
                _Entry(
                  icon: Icons.collections_bookmark_outlined,
                  label: album.name,
                  count: album.imageCount,
                  selected:
                      state.source == LibrarySource.album &&
                      state.albumId == album.id,
                  onTap: () => onAlbum(album.id),
                  menu: PopupMenuButton<AlbumAction>(
                    tooltip: l10n.moreActionsTooltip,
                    icon: const Icon(Icons.more_horiz, size: 16),
                    onSelected: (action) => onAlbumAction(album, action),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: AlbumAction.rename,
                        child: Text(l10n.libraryRenameAlbum),
                      ),
                      PopupMenuItem(
                        value: AlbumAction.delete,
                        child: Text(l10n.libraryDeleteAlbum),
                      ),
                    ],
                  ),
                ),
            _Header(
              label: l10n.libraryFolders,
              actionTooltip: l10n.libraryAddFolder,
              onAction: onAddFolder,
            ),
            for (final node in visibleTree)
              _Entry(
                icon: node.isRoot
                    ? Icons.folder_special_outlined
                    : Icons.folder_outlined,
                label: node.name,
                tooltip: node.path,
                count: node.imageCount,
                indent: node.depth,
                dimmed: node.isHidden,
                selected:
                    state.source == LibrarySource.folder &&
                    state.folder == node.path,
                onTap: () => onFolder(node.path),
                menu: PopupMenuButton<FolderAction>(
                  tooltip: l10n.moreActionsTooltip,
                  icon: const Icon(Icons.more_horiz, size: 16),
                  onSelected: (action) => onFolderAction(node, action),
                  itemBuilder: (context) => [
                    if (node.isHidden)
                      PopupMenuItem(
                        value: FolderAction.show,
                        child: Text(l10n.libraryShowFolder),
                      )
                    else
                      PopupMenuItem(
                        value: FolderAction.hide,
                        child: Text(l10n.libraryHideFolder),
                      ),
                    PopupMenuItem(
                      value: FolderAction.reveal,
                      child: Text(l10n.libraryRevealFolder),
                    ),
                    if (node.isRoot)
                      PopupMenuItem(
                        value: FolderAction.removeFromLibrary,
                        child: Text(l10n.libraryRemoveFolder),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.actionTooltip,
    required this.onAction,
  });

  final String label;
  final String actionTooltip;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white54,
                letterSpacing: 0.8,
              ),
            ),
          ),
          IconButton(
            tooltip: actionTooltip,
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white38),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.indent = 0,
    this.dimmed = false,
    this.tooltip,
    this.menu,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final int indent;
  final bool dimmed;
  final String? tooltip;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: EdgeInsetsDirectional.only(
        start: 16 + indent * 14.0,
        end: 4,
      ),
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, size: 18),
      minLeadingWidth: 18,
      title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count != null && count! > 0)
            Text(
              '$count',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white38),
            ),
          ?menu,
        ],
      ),
      onTap: onTap,
    );
    final content = dimmed ? Opacity(opacity: 0.45, child: tile) : tile;
    return tooltip == null
        ? content
        : Tooltip(
            message: tooltip!,
            waitDuration: const Duration(milliseconds: 600),
            child: content,
          );
  }
}
