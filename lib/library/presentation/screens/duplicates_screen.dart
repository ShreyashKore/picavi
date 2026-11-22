import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../viewer/presentation/widgets/viewer_actions_menu.dart'
    show trashNameFor;
import '../../data/services/thumbnail_cache.dart';
import '../../domain/entities/catalog_image.dart';
import '../controllers/library_controller.dart';
import '../widgets/library_dialogs.dart';

/// Lists groups of identical photos so extra copies can be moved to the
/// Trash. Nothing is ever deleted permanently.
class DuplicatesScreen extends StatefulWidget {
  const DuplicatesScreen({
    super.key,
    required this.controller,
    required this.cache,
  });

  final LibraryController controller;
  final ThumbnailCache cache;

  @override
  State<DuplicatesScreen> createState() => _DuplicatesScreenState();
}

class _DuplicatesScreenState extends State<DuplicatesScreen> {
  List<List<CatalogImage>>? _groups;
  (int, int) _progress = (0, 0);

  @override
  void initState() {
    super.initState();
    unawaited(_search());
  }

  Future<void> _search() async {
    final groups = await widget.controller.findDuplicates(
      onProgress: (checked, total) {
        if (mounted) {
          setState(() => _progress = (checked, total));
        }
      },
    );
    if (mounted) {
      setState(() => _groups = groups);
    }
  }

  Future<void> _trash(
    List<CatalogImage> group,
    List<CatalogImage> extra,
  ) async {
    final l10n = context.l10n;
    final bin = trashNameFor(l10n);
    final ok = await confirm(
      context,
      title: l10n.trashConfirmTitle(extra.length, bin),
      message: l10n.trashConfirmMessage(bin),
      confirmLabel: l10n.moveToTrashAction(extra.length, bin),
    );
    if (!ok) {
      return;
    }
    final trashed = await widget.controller.moveToTrash([
      for (final image in extra) image.path,
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      group.removeWhere((image) => trashed.contains(image.path));
      _groups!.removeWhere((group) => group.length < 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groups = _groups;
    final bin = trashNameFor(l10n);

    Widget body;
    if (groups == null) {
      final (checked, total) = _progress;
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 240,
              child: LinearProgressIndicator(
                value: total == 0 ? null : checked / total,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.duplicatesSearching),
          ],
        ),
      );
    } else if (groups.isEmpty) {
      body = Center(child: Text(l10n.duplicatesNone));
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: groups.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              l10n.duplicatesSummary(groups.length, bin),
              style: Theme.of(context).textTheme.bodyMedium,
            );
          }
          final group = groups[index - 1];
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final image in group)
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 130,
                              width: 200,
                              child: Image(
                                image: CachedThumbnailImage(
                                  widget.cache,
                                  image,
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const ColoredBox(
                                  color: AppColors.brokenImage,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            image.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Tooltip(
                            message: image.folder,
                            child: Text(
                              _shortFolder(image.folder),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white54),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: () => unawaited(
                                  _trash(group, [
                                    for (final other in group)
                                      if (other != image) other,
                                  ]),
                                ),
                                child: Text(l10n.duplicatesKeepOnly),
                              ),
                              IconButton(
                                tooltip: l10n.moveToTrashAction(1, bin),
                                onPressed: () =>
                                    unawaited(_trash(group, [image])),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C10),
      appBar: AppBar(
        leadingWidth: 200,
        leading: const Align(
          alignment: AlignmentDirectional.centerEnd,
          child: BackButton(),
        ),
        title: Text(l10n.duplicatesTitle),
      ),
      body: body,
    );
  }

  static String _shortFolder(String folder) {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && p.isWithin(home, folder)) {
      return p.join('~', p.relative(folder, from: home));
    }
    return folder;
  }
}
