import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../domain/services/file_operations_service.dart';

enum ViewerFileAction {
  edit,
  export,
  share,
  collage,
  print,
  feelingLucky,
  autoContrast,
  autoColor,
  blackAndWhite,
  sepia,
  removeEdits,
  captionTags,
  hide,
  unhide,
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
    this.canEdit = false,
    this.hasEdits = false,
    this.allHidden = false,
    this.canShare = false,
  });

  /// How many images multi-image actions apply to.
  final int targetCount;

  /// The current image can be opened in the editor.
  final bool canEdit;

  /// At least one target has edits that can be removed.
  final bool hasEdits;

  /// Every target is hidden from the library (offer "Show" instead of "Hide").
  final bool allHidden;

  /// The platform has a share menu.
  final bool canShare;
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
          ViewerFileAction.edit,
          Icons.tune_rounded,
          l10n.editImageTooltip,
          enabled: singleImage && canEdit,
        ),
        item(
          ViewerFileAction.export,
          Icons.ios_share,
          l10n.exportAction(targetCount),
        ),
        item(
          ViewerFileAction.collage,
          Icons.dashboard_outlined,
          l10n.collageAction,
        ),
        item(
          ViewerFileAction.print,
          Icons.print_outlined,
          l10n.printAction(targetCount),
        ),
        if (canShare)
          item(
            ViewerFileAction.share,
            Icons.share_outlined,
            l10n.shareAction(targetCount),
          ),
        PopupMenuItem<ViewerFileAction>(
          enabled: false,
          height: 32,
          child: Text(
            l10n.quickFixMenu(targetCount),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        item(
          ViewerFileAction.feelingLucky,
          Icons.auto_awesome,
          l10n.editorFeelingLucky,
        ),
        item(
          ViewerFileAction.autoContrast,
          Icons.contrast,
          l10n.editorAutoContrast,
        ),
        item(
          ViewerFileAction.autoColor,
          Icons.color_lens_outlined,
          l10n.editorAutoColor,
        ),
        item(
          ViewerFileAction.blackAndWhite,
          Icons.filter_b_and_w,
          l10n.effectBlackAndWhite,
        ),
        item(
          ViewerFileAction.sepia,
          Icons.filter_vintage_outlined,
          l10n.effectSepia,
        ),
        item(
          ViewerFileAction.removeEdits,
          Icons.restore,
          l10n.removeEditsAction,
          enabled: hasEdits,
        ),
        const PopupMenuDivider(),
        item(
          ViewerFileAction.captionTags,
          Icons.short_text_rounded,
          l10n.captionTagsAction,
          enabled: singleImage,
        ),
        if (allHidden)
          item(
            ViewerFileAction.unhide,
            Icons.visibility_outlined,
            l10n.showInLibraryAction(targetCount),
          )
        else
          item(
            ViewerFileAction.hide,
            Icons.visibility_off_outlined,
            l10n.hideFromLibraryAction(targetCount),
          ),
        const PopupMenuDivider(),
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

/// Where a share menu should point: the widget with [key], or the window's
/// top centre if it isn't laid out.
ShareAnchor shareAnchorFor(GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is RenderBox && box.hasSize) {
    final origin = box.localToGlobal(Offset.zero);
    return ShareAnchor(origin.dx, origin.dy, box.size.width, box.size.height);
  }
  return const ShareAnchor(0, 0, 1, 1);
}
