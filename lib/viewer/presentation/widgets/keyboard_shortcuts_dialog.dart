import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'viewer_actions_menu.dart';

/// One row in the shortcuts dialog: the keys and what they do.
class _ShortcutEntry {
  const _ShortcutEntry(this.keys, this.describe, {this.appendClick = false});

  final List<String> keys;
  final String Function(AppLocalizations l10n) describe;

  /// Replaces the "·" placeholder in [keys] with the localized "Click".
  final bool appendClick;

  List<String> labels(AppLocalizations l10n) => appendClick
      ? keys.map((key) => key.replaceAll('·', l10n.clickLabel)).toList()
      : keys;
}

/// Keep in sync with `_ViewerScreenState._handleKeyEvent`.
List<_ShortcutEntry> _shortcutsForPlatform() {
  final command = Platform.isMacOS ? '⌘' : 'Ctrl+';
  return <_ShortcutEntry>[
    _ShortcutEntry(['→', '←'], (l10n) => l10n.shortcutNextPrevious),
    _ShortcutEntry(['Home', 'End'], (l10n) => l10n.shortcutFirstLast),
    _ShortcutEntry(['Space'], (l10n) => l10n.shortcutPlayPause),
    _ShortcutEntry(['+', '−'], (l10n) => l10n.shortcutZoom),
    _ShortcutEntry(['1'], (l10n) => l10n.shortcutActualSize),
    _ShortcutEntry(['0'], (l10n) => l10n.shortcutFitFill),
    _ShortcutEntry(['F', 'F11'], (l10n) => l10n.shortcutFullScreen),
    _ShortcutEntry(['R', '⇧R'], (l10n) => l10n.shortcutRotate),
    _ShortcutEntry(['I'], (l10n) => l10n.shortcutInfo),
    _ShortcutEntry(['E'], (l10n) => l10n.shortcutEdit),
    _ShortcutEntry(['S'], (l10n) => l10n.shortcutStar),
    _ShortcutEntry(['${command}S'], (l10n) => l10n.shortcutSaveRotation),
    _ShortcutEntry(['F2'], (l10n) => l10n.shortcutRename),
    _ShortcutEntry([
      Platform.isMacOS ? '⌫' : 'Delete',
    ], (l10n) => l10n.shortcutTrash(trashNameFor(l10n))),
    _ShortcutEntry(['${command}C'], (l10n) => l10n.shortcutCopyImage),
    _ShortcutEntry(['${command}A'], (l10n) => l10n.shortcutSelectAll),
    _ShortcutEntry(
      ['$command ·', '⇧ ·'],
      (l10n) => l10n.shortcutSelect,
      appendClick: true,
    ),
    _ShortcutEntry(['?'], (l10n) => l10n.shortcutHelp),
    _ShortcutEntry(['Esc'], (l10n) => l10n.shortcutEscape),
  ];
}

Future<void> showKeyboardShortcutsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const KeyboardShortcutsDialog(),
  );
}

class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.keyboardShortcutsTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final shortcut in _shortcutsForPlatform())
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final key in shortcut.labels(l10n))
                              _KeyCap(key),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          shortcut.describe(l10n),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.closeLabel),
        ),
      ],
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
