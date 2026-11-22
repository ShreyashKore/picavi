import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../l10n/generated/app_localizations.dart';

/// One row in the shortcuts dialog: the keys and what they do.
class _ShortcutEntry {
  const _ShortcutEntry(this.keys, this.describe);

  final List<String> keys;
  final String Function(AppLocalizations l10n) describe;
}

/// Keep in sync with `_ViewerScreenState._handleKeyEvent`.
final List<_ShortcutEntry> _shortcuts = <_ShortcutEntry>[
  _ShortcutEntry(['→', '←'], (l10n) => l10n.shortcutNextPrevious),
  _ShortcutEntry(['Home', 'End'], (l10n) => l10n.shortcutFirstLast),
  _ShortcutEntry(['Space'], (l10n) => l10n.shortcutPlayPause),
  _ShortcutEntry(['+', '−'], (l10n) => l10n.shortcutZoom),
  _ShortcutEntry(['1'], (l10n) => l10n.shortcutActualSize),
  _ShortcutEntry(['0'], (l10n) => l10n.shortcutFit),
  _ShortcutEntry(['R', '⇧R'], (l10n) => l10n.shortcutRotate),
  _ShortcutEntry(['I'], (l10n) => l10n.shortcutInfo),
  _ShortcutEntry(['?'], (l10n) => l10n.shortcutHelp),
  _ShortcutEntry(['Esc'], (l10n) => l10n.shortcutClose),
];

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
              for (final shortcut in _shortcuts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final key in shortcut.keys) _KeyCap(key),
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
