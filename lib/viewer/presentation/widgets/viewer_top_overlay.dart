import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/image_sort_order.dart';

class ViewerTopOverlay extends StatelessWidget {
  const ViewerTopOverlay({
    super.key,
    required this.fileName,
    required this.positionLabel,
    required this.settingsTooltip,
    required this.onOpenSettings,
    required this.sortOrder,
    required this.onSortOrderChanged,
    required this.onShowShortcuts,
    required this.actionsMenu,
    this.selectionCount = 0,
    this.onClearSelection,
    this.isStarred = false,
    this.onToggleStar,
    this.onOpenLibrary,
  });

  final String fileName;
  final String positionLabel;
  final String settingsTooltip;
  final VoidCallback onOpenSettings;
  final ImageSortOrder sortOrder;
  final ValueChanged<ImageSortOrder> onSortOrderChanged;
  final VoidCallback onShowShortcuts;
  final Widget actionsMenu;
  final int selectionCount;
  final VoidCallback? onClearSelection;
  final bool isStarred;
  final VoidCallback? onToggleStar;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.topOverlay,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            positionLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onToggleStar != null)
                    IconButton(
                      tooltip: isStarred
                          ? context.l10n.unstarTooltip
                          : context.l10n.starTooltip,
                      onPressed: onToggleStar,
                      icon: Icon(
                        isStarred
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 20,
                        color: isStarred ? const Color(0xFFFFC94D) : null,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  const SizedBox(width: 8),
                  if (selectionCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InputChip(
                        label: Text(
                          context.l10n.selectionCount(selectionCount),
                        ),
                        onDeleted: onClearSelection,
                        deleteButtonTooltipMessage:
                            context.l10n.clearSelectionTooltip,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  if (onOpenLibrary != null)
                    IconButton(
                      tooltip: context.l10n.libraryTitle,
                      onPressed: onOpenLibrary,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                  actionsMenu,
                  _SortMenuButton(
                    sortOrder: sortOrder,
                    onChanged: onSortOrderChanged,
                  ),
                  IconButton(
                    tooltip: context.l10n.keyboardShortcutsTitle,
                    onPressed: onShowShortcuts,
                    icon: const Icon(Icons.keyboard_outlined, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: settingsTooltip,
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({required this.sortOrder, required this.onChanged});

  final ImageSortOrder sortOrder;
  final ValueChanged<ImageSortOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fieldLabels = <ImageSortField, String>{
      ImageSortField.name: l10n.sortByName,
      ImageSortField.modified: l10n.sortByModified,
      ImageSortField.size: l10n.sortBySize,
      ImageSortField.type: l10n.sortByType,
    };

    return PopupMenuButton<ImageSortOrder>(
      tooltip: l10n.sortTooltip,
      icon: const Icon(Icons.sort_rounded, size: 18),
      style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
      onSelected: onChanged,
      itemBuilder: (context) => <PopupMenuEntry<ImageSortOrder>>[
        for (final entry in fieldLabels.entries)
          CheckedPopupMenuItem<ImageSortOrder>(
            value: sortOrder.copyWith(field: entry.key),
            checked: sortOrder.field == entry.key,
            child: Text(entry.value),
          ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem<ImageSortOrder>(
          value: sortOrder.copyWith(ascending: true),
          checked: sortOrder.ascending,
          child: Text(l10n.sortAscending),
        ),
        CheckedPopupMenuItem<ImageSortOrder>(
          value: sortOrder.copyWith(ascending: false),
          checked: !sortOrder.ascending,
          child: Text(l10n.sortDescending),
        ),
      ],
    );
  }
}
