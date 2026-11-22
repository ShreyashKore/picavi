import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../l10n/generated/app_localizations.dart';

enum ViewerFileAction {
  rename,
  copyToFolder,
  moveToFolder,
  copyImage,
  reveal,
  openWith,
  moveToTrash,
}

/// Localized name of the system trash on this platform.
String trashNameFor(AppLocalizations l10n) =>
    Platform.isWindows ? l10n.recycleBinName : l10n.trashName;

String revealLabelFor(AppLocalizations l10n) {
  if (Platform.isMacOS) {
    return l10n.revealInFinderAction;
  }
  if (Platform.isWindows) {
    return l10n.revealInExplorerAction;
  }
  return l10n.revealInFileManagerAction;
}

/// The "⋯" menu with file actions for the current image or selection.
class ViewerActionsMenu extends StatelessWidget {
  const ViewerActionsMenu({
    super.key,
    required this.targetCount,
    required this.onSelected,
  });

  /// How many images multi-image actions apply to.
  final int targetCount;
  final ValueChanged<ViewerFileAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final singleImage = targetCount <= 1;

    PopupMenuItem<ViewerFileAction> item(
      ViewerFileAction action,
      IconData icon,
      String label, {
      bool enabled = true,
    }) {
      return PopupMenuItem<ViewerFileAction>(
        value: action,
        enabled: enabled,
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Flexible(child: Text(label)),
          ],
        ),
      );
    }

    return PopupMenuButton<ViewerFileAction>(
      tooltip: l10n.moreActionsTooltip,
      icon: const Icon(Icons.more_horiz_rounded, size: 18),
      style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
      onSelected: onSelected,
      itemBuilder: (context) => <PopupMenuEntry<ViewerFileAction>>[
        item(
          ViewerFileAction.rename,
          Icons.drive_file_rename_outline,
          l10n.renameAction,
          enabled: singleImage,
        ),
        item(
          ViewerFileAction.copyToFolder,
          Icons.file_copy_outlined,
          l10n.copyToFolderAction(targetCount),
        ),
        item(
          ViewerFileAction.moveToFolder,
          Icons.drive_file_move_outline,
          l10n.moveToFolderAction(targetCount),
        ),
        const PopupMenuDivider(),
        item(
          ViewerFileAction.copyImage,
          Icons.content_copy_rounded,
          l10n.copyImageAction,
          enabled: singleImage,
        ),
        item(
          ViewerFileAction.reveal,
          Icons.folder_open_outlined,
          revealLabelFor(l10n),
          enabled: singleImage,
        ),
        item(
          ViewerFileAction.openWith,
          Icons.open_in_new_rounded,
          l10n.openWithAction,
          enabled: singleImage,
        ),
        const PopupMenuDivider(),
        item(
          ViewerFileAction.moveToTrash,
          Icons.delete_outline_rounded,
          l10n.moveToTrashAction(targetCount, trashNameFor(l10n)),
        ),
      ],
    );
  }
}
