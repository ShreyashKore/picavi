import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/services/thumbnail_cache.dart';
import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/import_models.dart';
import '../../domain/repositories/library_settings_repository.dart';
import '../../domain/services/import_service.dart';
import '../controllers/import_controller.dart';

/// Copies photos from a camera, card or folder into dated folders. Pops
/// with the destination folder when anything was imported.
class ImportScreen extends StatefulWidget {
  const ImportScreen({
    super.key,
    required this.service,
    required this.settings,
    required this.thumbnails,
    required this.defaultDestination,
    required this.pickFolder,
  });

  final ImportService service;
  final LibrarySettingsRepository settings;
  final ThumbnailCache thumbnails;
  final String defaultDestination;

  /// Asks for a folder; null if cancelled.
  final Future<String?> Function() pickFolder;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  late final ImportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImportController(
      service: widget.service,
      settings: widget.settings,
      defaultDestination: widget.defaultDestination,
    )..addListener(_onChanged);
    unawaited(_controller.open());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _chooseFolderSource() async {
    final folder = await widget.pickFolder();
    if (folder != null) {
      await _controller.chooseSource(folder);
    }
  }

  Future<void> _changeDestination() async {
    final folder = await widget.pickFolder();
    if (folder != null) {
      await _controller.setDestination(folder);
    }
  }

  void _close() {
    final progress = _controller.state.progress;
    Navigator.of(context).pop<String>(
      progress != null && progress.copied > 0
          ? _controller.state.destination
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = _controller.state;
    return PopScope(
      canPop: !state.isImporting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.isImporting) {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0C10),
        appBar: AppBar(
          leadingWidth: 200,
          leading: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: BackButton(onPressed: state.isImporting ? null : _close),
          ),
          title: Text(l10n.importTitle),
        ),
        body: Row(
          children: [
            SizedBox(
              width: 260,
              child: Material(
                color: AppColors.panel,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        8,
                        8,
                        4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.importDevices.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.white54),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.importRefreshDevices,
                            onPressed: state.isImporting
                                ? null
                                : () => unawaited(_controller.refreshSources()),
                            icon: const Icon(Icons.refresh, size: 18),
                          ),
                        ],
                      ),
                    ),
                    if (state.sources.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Text(
                          l10n.importNoDevices,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white38),
                        ),
                      ),
                    for (final source in state.sources)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.sd_card_outlined, size: 18),
                        title: Text(source.name),
                        selected: state.sourcePath == source.path,
                        enabled: !state.isImporting,
                        onTap: () =>
                            unawaited(_controller.chooseSource(source.path)),
                      ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.folder_open_outlined, size: 18),
                      title: Text(l10n.importFromFolder),
                      enabled: !state.isImporting,
                      onTap: () => unawaited(_chooseFolderSource()),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildMain(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildMain(ImportState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final source = state.sourcePath;
    if (source == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            l10n.importChooseSource,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
      );
    }

    final progress = state.progress;
    final selectedCount = state.selection.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.drive_folder_upload_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.importDestination(_shorten(state.destination)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: state.isImporting
                    ? null
                    : () => unawaited(_changeDestination()),
                child: Text(l10n.importChangeDestination),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isScanning
              ? const Center(child: CircularProgressIndicator())
              : state.candidates.isEmpty
              ? Center(child: Text(l10n.importNothingFound))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: state.candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = state.candidates[index];
                    return _CandidateTile(
                      candidate: candidate,
                      cache: widget.thumbnails,
                      selected: state.selection.contains(candidate.path),
                      onTap: state.isImporting
                          ? null
                          : () => _controller.toggle(candidate.path),
                      importedLabel: l10n.importAlreadyImported,
                    );
                  },
                ),
        ),
        Material(
          color: AppColors.panel,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: progress == null
                      ? Text(
                          l10n.importSelectedCount(
                            selectedCount,
                            state.candidates.length,
                          ),
                        )
                      : progress.done
                      ? Text(
                          l10n.importDone(
                            progress.copied,
                            progress.skipped,
                            progress.failed,
                          ),
                        )
                      : Row(
                          children: [
                            SizedBox(
                              width: 200,
                              child: LinearProgressIndicator(
                                value: progress.total == 0
                                    ? null
                                    : progress.handled / progress.total,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.importProgress(
                                progress.handled,
                                progress.total,
                              ),
                            ),
                          ],
                        ),
                ),
                if (!state.isImporting && !state.isDone) ...[
                  TextButton(
                    onPressed: _controller.selectNew,
                    child: Text(l10n.importSelectNew),
                  ),
                  TextButton(
                    onPressed: _controller.selectNone,
                    child: Text(l10n.importSelectNone),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: selectedCount == 0
                        ? null
                        : () => unawaited(_controller.startImport()),
                    icon: const Icon(Icons.download_rounded),
                    label: Text(l10n.importButton(selectedCount)),
                  ),
                ],
                if (state.isDone)
                  FilledButton(onPressed: _close, child: Text(l10n.editorDone)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _shorten(String folder) {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && (p.equals(home, folder) || p.isWithin(home, folder))) {
      return p.join('~', p.relative(folder, from: home));
    }
    return folder;
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.cache,
    required this.selected,
    required this.onTap,
    required this.importedLabel,
  });

  final ImportCandidate candidate;
  final ThumbnailCache cache;
  final bool selected;
  final VoidCallback? onTap;
  final String importedLabel;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final image = CatalogImage(
      path: candidate.path,
      folder: p.dirname(candidate.path),
      name: p.basename(candidate.path),
      stamp: candidate.stamp,
    );
    return Semantics(
      label: image.name,
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: selected ? 1 : 0.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.brokenImage),
                Image(
                  image: CachedThumbnailImage(cache, image),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
                PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: selected ? primary : Colors.white70,
                    shadows: const [Shadow(blurRadius: 3)],
                  ),
                ),
                if (candidate.alreadyImported)
                  PositionedDirectional(
                    start: 4,
                    bottom: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        child: Text(
                          importedLabel,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
