import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../domain/entities/export_options.dart';

/// The options last confirmed in this session, offered again next time.
ExportOptions _lastUsedOptions = const ExportOptions();

/// Asks how edited copies should be written. Returns null if cancelled.
Future<ExportOptions?> showExportOptionsDialog(
  BuildContext context, {
  required int imageCount,
}) async {
  final options = await showDialog<ExportOptions>(
    context: context,
    builder: (context) =>
        _ExportOptionsDialog(imageCount: imageCount, initial: _lastUsedOptions),
  );
  if (options != null) {
    _lastUsedOptions = options;
  }
  return options;
}

class _ExportOptionsDialog extends StatefulWidget {
  const _ExportOptionsDialog({required this.imageCount, required this.initial});

  final int imageCount;
  final ExportOptions initial;

  @override
  State<_ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<_ExportOptionsDialog> {
  late ExportOptions _options = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.exportDialogTitle(widget.imageCount)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.exportDialogDescription,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Text(l10n.exportFormatLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ExportFormat>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ExportFormat.jpeg,
                  label: Text(l10n.exportFormatJpeg),
                ),
                ButtonSegment(
                  value: ExportFormat.png,
                  label: Text(l10n.exportFormatPng),
                ),
              ],
              selected: {_options.format},
              onSelectionChanged: (selection) => setState(
                () => _options = _options.copyWith(format: selection.single),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.exportSizeLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              initialValue: _options.maxDimension,
              items: [
                for (final size in ExportOptions.sizeChoices)
                  DropdownMenuItem(
                    value: size,
                    child: Text(
                      size == null
                          ? l10n.exportSizeOriginal
                          : l10n.exportSizePixels(size),
                    ),
                  ),
              ],
              onChanged: (size) => setState(
                () => _options = _options.copyWith(maxDimension: () => size),
              ),
            ),
            if (_options.format == ExportFormat.jpeg) ...[
              const SizedBox(height: 20),
              Text(
                l10n.exportQualityLabel(_options.jpegQuality),
                style: theme.textTheme.labelLarge,
              ),
              Slider(
                value: _options.jpegQuality.toDouble(),
                min: 50,
                max: 100,
                divisions: 10,
                onChanged: (quality) => setState(
                  () => _options = _options.copyWith(
                    jpegQuality: quality.round(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_options),
          child: Text(l10n.exportChooseFolder),
        ),
      ],
    );
  }
}
