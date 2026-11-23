import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../../collage/data/raster_collage_service.dart';
import '../../../collage/domain/collage_options.dart';
import '../../../collage/presentation/collage_dialogs.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewer/presentation/widgets/viewer_actions_menu.dart'
    show shareAnchorFor, trashNameFor;
import '../../data/library_services.dart';
import '../../domain/entities/catalog_image.dart';
import '../controllers/library_controller.dart';
import '../models/folder_tree.dart';
import '../models/library_state.dart';
import '../widgets/library_dialogs.dart';
import '../widgets/library_grid.dart';
import '../widgets/library_sidebar.dart';
import 'duplicates_screen.dart';
import 'import_screen.dart';

/// Picasa-style library: every photo in the watched folders, by folder,
/// album or month. Pops with the path of a photo to open in the viewer.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.services,
    required this.pickFolder,
  });

  final LibraryServices services;

  /// Asks the user for a folder to add; null if cancelled.
  final Future<String?> Function() pickFolder;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static double _tileExtent = 170;

  late final LibraryController _controller;
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _searchDebounce;
  final GlobalKey _shareKey = GlobalKey();
  int? _lastNoticeId;

  @override
  void initState() {
    super.initState();
    final services = widget.services;
    _controller = LibraryController(
      catalog: services.catalog,
      indexer: services.indexer,
      settings: services.settings,
      photoInfo: services.photoInfo,
      fileOperations: services.fileOperations,
      duplicateFinder: services.duplicateFinder,
    )..addListener(_onChanged);
    unawaited(_controller.open());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    final notice = _controller.state.notice;
    if (notice != null && notice.id != _lastNoticeId) {
      _lastNoticeId = notice.id;
      final l10n = context.l10n;
      final bin = trashNameFor(l10n);
      final message = switch (notice.type) {
        LibraryNoticeType.saveFailed => l10n.photoInfoSaveFailedNotice,
        LibraryNoticeType.albumCreated => l10n.libraryAlbumCreated(
          notice.detail ?? '',
        ),
        LibraryNoticeType.addedToAlbum => l10n.libraryAddedToAlbum(
          notice.count,
        ),
        LibraryNoticeType.removedFromAlbum => l10n.libraryRemovedFromAlbum(
          notice.count,
        ),
        LibraryNoticeType.movedToTrash => l10n.movedToTrashNotice(
          notice.count,
          bin,
        ),
        LibraryNoticeType.trashFailed => l10n.trashFailedNotice(
          notice.count,
          bin,
        ),
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() {});
  }

  // -------------------------------------------------------------------------

  Future<void> _addFolder() async {
    final folder = await widget.pickFolder();
    if (folder != null) {
      await _controller.addRoot(folder);
    }
  }

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(_controller.setSearchText(text)),
    );
  }

  void _onTap(CatalogImage image) {
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isShiftPressed) {
      _controller.selectRange(image.path);
    } else if (keyboard.isMetaPressed || keyboard.isControlPressed) {
      _controller.toggleSelection(image.path);
    } else {
      _controller.select(image.path);
    }
  }

  void _open(CatalogImage image) {
    Navigator.of(context).pop<String>(image.path);
  }

  Future<void> _onFolderAction(FolderNode node, FolderAction action) async {
    final l10n = context.l10n;
    switch (action) {
      case FolderAction.hide:
        await _controller.setFolderHidden(node.path, true);
      case FolderAction.show:
        await _controller.setFolderHidden(node.path, false);
      case FolderAction.reveal:
        await widget.services.fileOperations.reveal(node.path);
      case FolderAction.removeFromLibrary:
        final ok = await confirm(
          context,
          title: l10n.libraryRemoveFolderTitle,
          message: l10n.libraryRemoveFolderMessage(node.path),
          confirmLabel: l10n.libraryRemoveFolder,
        );
        if (ok) {
          await _controller.removeRoot(node.path);
        }
    }
  }

  Future<void> _createAlbum() async {
    final l10n = context.l10n;
    final name = await showAlbumNameDialog(
      context,
      title: l10n.libraryNewAlbum,
      confirmLabel: l10n.libraryCreate,
    );
    if (name != null) {
      final album = await _controller.createAlbum(name);
      if (_controller.state.selection.isEmpty) {
        await _controller.showAlbum(album.id);
      }
    }
  }

  Future<void> _onAlbumAction(Album album, AlbumAction action) async {
    final l10n = context.l10n;
    switch (action) {
      case AlbumAction.rename:
        final name = await showAlbumNameDialog(
          context,
          title: l10n.libraryRenameAlbum,
          confirmLabel: l10n.saveLabel,
          initial: album.name,
        );
        if (name != null) {
          await _controller.renameAlbum(album.id, name);
        }
      case AlbumAction.delete:
        final ok = await confirm(
          context,
          title: l10n.libraryDeleteAlbumTitle(album.name),
          message: l10n.libraryDeleteAlbumMessage,
          confirmLabel: l10n.libraryDeleteAlbum,
        );
        if (ok) {
          await _controller.deleteAlbum(album.id);
        }
    }
  }

  Future<void> _openImport() async {
    final services = widget.services;
    final destination = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ImportScreen(
          service: services.importService,
          settings: services.settings,
          thumbnails: services.thumbnails,
          defaultDestination: services.defaultImportDestination,
          pickFolder: widget.pickFolder,
        ),
      ),
    );
    if (destination == null) {
      return;
    }
    final watched = _controller.state.roots.any(
      (root) => p.equals(root, destination) || p.isWithin(root, destination),
    );
    // Imported photos belong in the library: watch their folder if needed.
    if (watched) {
      _controller.reindex();
    } else {
      await _controller.addRoot(destination);
    }
  }

  Future<void> _makeCollage() async {
    final selected = [
      for (final image in _controller.state.images)
        if (_controller.state.selection.contains(image.path)) image,
    ];
    if (selected.length < 2) {
      return;
    }
    final options = await showCollageOptionsDialog(
      context,
      photoCount: selected.length,
    );
    if (options == null || !mounted) {
      return;
    }
    final directory = await widget.pickFolder();
    if (directory == null || !mounted) {
      return;
    }
    final written = await createCollageWithProgress(
      context,
      service: RasterCollageService(pixelSource: widget.services.pixelSource),
      photos: [
        for (final image in selected) CollagePhoto(image.path, image.edits),
      ],
      options: options,
      directory: directory,
    );
    if (!mounted) {
      return;
    }
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          written.isEmpty
              ? l10n.collageFailed
              : l10n.collageSaved(written.length, p.basename(written.first)),
        ),
      ),
    );
    _controller.reindex();
  }

  Future<void> _openDuplicates() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DuplicatesScreen(
          controller: _controller,
          cache: widget.services.thumbnails,
        ),
      ),
    );
  }

  void _handleEscape() {
    if (_controller.state.selection.isNotEmpty) {
      _controller.clearSelection();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _openSelected() {
    final selected = _controller.state.selectedInOrder;
    if (selected.length == 1) {
      Navigator.of(context).pop<String>(selected.single);
    }
  }

  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = _controller.state;
    final useMeta = Platform.isMacOS;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _handleEscape,
        const SingleActivator(LogicalKeyboardKey.enter): _openSelected,
        SingleActivator(
          LogicalKeyboardKey.keyA,
          meta: useMeta,
          control: !useMeta,
        ): _controller.selectAll,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFF0C0C10),
          appBar: AppBar(
            leadingWidth: 200,
            leading: const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: BackButton(),
            ),
            title: Text(l10n.libraryTitle),
            actions: [
              SizedBox(
                width: 260,
                height: 38,
                child: TextField(
                  controller: _search,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: l10n.librarySearchHint,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.libraryClearSearch,
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              _search.clear();
                              _onSearchChanged('');
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                child: Tooltip(
                  message: l10n.libraryThumbnailSize,
                  child: Slider(
                    value: _tileExtent,
                    min: 100,
                    max: 300,
                    onChanged: (value) => setState(() => _tileExtent = value),
                  ),
                ),
              ),
              IconButton(
                tooltip: state.showHidden
                    ? l10n.libraryHideHidden
                    : l10n.libraryShowHidden,
                isSelected: state.showHidden,
                icon: const Icon(Icons.visibility_off_outlined),
                selectedIcon: const Icon(Icons.visibility_outlined),
                onPressed: () =>
                    unawaited(_controller.setShowHidden(!state.showHidden)),
              ),
              IconButton(
                tooltip: l10n.importTitle,
                icon: const Icon(Icons.download_for_offline_outlined),
                onPressed: () => unawaited(_openImport()),
              ),
              IconButton(
                tooltip: l10n.duplicatesTitle,
                icon: const Icon(Icons.difference_outlined),
                onPressed: state.hasRoots
                    ? () => unawaited(_openDuplicates())
                    : null,
              ),
              IconButton(
                tooltip: l10n.libraryRescan,
                icon: const Icon(Icons.refresh),
                onPressed: state.hasRoots && !state.isIndexing
                    ? _controller.reindex
                    : null,
              ),
              const SizedBox(width: 12),
            ],
            bottom: state.isIndexing
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(2),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      value: state.progress!.found == 0
                          ? null
                          : state.progress!.processed / state.progress!.found,
                    ),
                  )
                : null,
          ),
          body: Row(
            children: [
              LibrarySidebar(
                state: state,
                onAllPhotos: () => unawaited(_controller.showAllPhotos()),
                onStarred: () => unawaited(_controller.showStarred()),
                onFolder: (folder) => unawaited(_controller.showFolder(folder)),
                onAlbum: (id) => unawaited(_controller.showAlbum(id)),
                onAddFolder: () => unawaited(_addFolder()),
                onFolderAction: (node, action) =>
                    unawaited(_onFolderAction(node, action)),
                onCreateAlbum: () => unawaited(_createAlbum()),
                onAlbumAction: (album, action) =>
                    unawaited(_onAlbumAction(album, action)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildContent(state)),
                    if (state.selection.isNotEmpty) _buildSelectionBar(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LibraryState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!state.hasRoots) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, size: 56),
              const SizedBox(height: 16),
              Text(l10n.libraryEmptyTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.libraryEmptyMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => unawaited(_addFolder()),
                icon: const Icon(Icons.create_new_folder_outlined),
                label: Text(l10n.libraryAddFolder),
              ),
            ],
          ),
        ),
      );
    }
    if (state.images.isEmpty) {
      return Center(
        child: Text(
          state.isIndexing
              ? l10n.libraryScanning(state.progress!.found)
              : state.searchText.isNotEmpty
              ? l10n.libraryNoMatches
              : l10n.libraryNothingHere,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      );
    }
    return LibraryGrid(
      images: state.images,
      selection: state.selection,
      cache: widget.services.thumbnails,
      tileExtent: _tileExtent,
      groupByMonth: state.groupsByMonth,
      scrollController: _scroll,
      onTap: _onTap,
      onOpen: _open,
    );
  }

  Widget _buildSelectionBar(LibraryState state) {
    final l10n = context.l10n;
    final selected = [
      for (final image in state.images)
        if (state.selection.contains(image.path)) image,
    ];
    final allStarred = selected.every((image) => image.info.starred);
    final allHidden = selected.every((image) => image.info.hidden);
    final count = selected.length;

    return Material(
      color: AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(l10n.selectionCount(count)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => unawaited(_controller.toggleStarSelection()),
              icon: Icon(
                allStarred ? Icons.star_rounded : Icons.star_outline_rounded,
              ),
              label: Text(allStarred ? l10n.libraryUnstar : l10n.libraryStar),
            ),
            PopupMenuButton<int>(
              tooltip: l10n.libraryAddToAlbum,
              onSelected: (id) => id < 0
                  ? unawaited(_createAlbum())
                  : unawaited(_controller.addSelectionToAlbum(id)),
              itemBuilder: (context) => [
                for (final album in state.albums)
                  PopupMenuItem(value: album.id, child: Text(album.name)),
                if (state.albums.isNotEmpty) const PopupMenuDivider(),
                PopupMenuItem(value: -1, child: Text(l10n.libraryNewAlbum)),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.collections_bookmark_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.libraryAddToAlbum),
                  ],
                ),
              ),
            ),
            if (count > 1)
              TextButton.icon(
                onPressed: () => unawaited(_makeCollage()),
                icon: const Icon(Icons.dashboard_outlined),
                label: Text(l10n.collageButton),
              ),
            if (_controller.canShare)
              TextButton.icon(
                key: _shareKey,
                onPressed: () => unawaited(
                  _controller.shareSelection(shareAnchorFor(_shareKey)),
                ),
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.shareAction(count)),
              ),
            if (state.source == LibrarySource.album)
              TextButton.icon(
                onPressed: () =>
                    unawaited(_controller.removeSelectionFromAlbum()),
                icon: const Icon(Icons.remove_circle_outline),
                label: Text(l10n.libraryRemoveFromAlbum),
              ),
            TextButton.icon(
              onPressed: () =>
                  unawaited(_controller.setSelectionHidden(!allHidden)),
              icon: Icon(
                allHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              label: Text(
                allHidden
                    ? l10n.showInLibraryAction(count)
                    : l10n.hideFromLibraryAction(count),
              ),
            ),
            IconButton(
              tooltip: l10n.clearSelectionTooltip,
              onPressed: _controller.clearSelection,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
