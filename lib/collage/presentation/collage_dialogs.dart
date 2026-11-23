import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../domain/collage_options.dart';

CollageOptions _lastUsed = const CollageOptions();

/// Asks how the collage should look. Returns null if cancelled.
Future<CollageOptions?> showCollageOptionsDialog(
  BuildContext context, {
  required int photoCount,
}) async {
  final options = await showDialog<CollageOptions>(
    context: context,
    builder: (context) =>
        _CollageOptionsDialog(photoCount: photoCount, initial: _lastUsed),
  );
  if (options != null) {
    _lastUsed = options;
  }
  return options;
}

/// Makes the collage while showing progress. Returns the files written.
Future<List<String>> createCollageWithProgress(
  BuildContext context, {
  required CollageService service,
  required List<CollagePhoto> photos,
  required CollageOptions options,
  required String directory,
}) async {
  final progress = ValueNotifier<double?>(null);
  final l10n = context.l10n;
  final fileName = options.layout == CollageLayout.contactSheet
      ? l10n.contactSheetFileName
      : l10n.collageFileName;
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.collageWorking),
              const SizedBox(height: 16),
              ValueListenableBuilder<double?>(
                valueListenable: progress,
                builder: (context, value, _) =>
                    LinearProgressIndicator(value: value),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await service.create(
      photos,
      options,
      directory,
      fileName: fileName,
      onProgress: (done, total) =>
          progress.value = total == 0 ? null : done / total,
    );
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    progress.dispose();
  }
}

class _CollageOptionsDialog extends StatefulWidget {
  const _CollageOptionsDialog({
    required this.photoCount,
    required this.initial,
  });

  final int photoCount;
  final CollageOptions initial;

  @override
  State<_CollageOptionsDialog> createState() => _CollageOptionsDialogState();
}

class _CollageOptionsDialogState extends State<_CollageOptionsDialog> {
  late CollageOptions _options = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isSheet = _options.layout == CollageLayout.contactSheet;

    String sizeLabel(CollageSize size) => switch (size) {
      CollageSize.hd => l10n.collageSizeWide(size.width, size.height),
      CollageSize.large => l10n.collageSizeLarge(size.width, size.height),
      CollageSize.square => l10n.collageSizeSquare(size.width, size.height),
      CollageSize.portrait => l10n.collageSizePortrait(size.width, size.height),
    };

    return AlertDialog(
      title: Text(l10n.collageTitle(widget.photoCount)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<CollageLayout>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: CollageLayout.mosaic,
                  icon: const Icon(Icons.dashboard_outlined),
                  label: Text(l10n.collageMosaic),
                ),
                ButtonSegment(
                  value: CollageLayout.grid,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: Text(l10n.collageGrid),
                ),
                ButtonSegment(
                  value: CollageLayout.contactSheet,
                  icon: const Icon(Icons.view_comfy_alt_outlined),
                  label: Text(l10n.collageContactSheet),
                ),
              ],
              selected: {_options.layout},
              onSelectionChanged: (selection) => setState(
                () => _options = _options.copyWith(layout: selection.single),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSheet ? l10n.collageContactSheetHint : l10n.collageHint,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            if (!isSheet) ...[
              const SizedBox(height: 20),
              Text(l10n.exportSizeLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<CollageSize>(
                initialValue: _options.size,
                items: [
                  for (final size in CollageSize.values)
                    DropdownMenuItem(value: size, child: Text(sizeLabel(size))),
                ],
                onChanged: (size) =>
                    setState(() => _options = _options.copyWith(size: size)),
              ),
              const SizedBox(height: 20),
              Text(l10n.collageSpacing, style: theme.textTheme.labelLarge),
              Slider(
                value: _options.spacing,
                max: 0.04,
                divisions: 8,
                onChanged: (spacing) => setState(
                  () => _options = _options.copyWith(spacing: spacing),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(l10n.collageBackground, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final background in CollageBackground.values)
                  ChoiceChip(
                    label: Text(switch (background) {
                      CollageBackground.white => l10n.collageWhite,
                      CollageBackground.black => l10n.collageBlack,
                      CollageBackground.charcoal => l10n.collageCharcoal,
                    }),
                    avatar: CircleAvatar(
                      backgroundColor: Color(background.argb),
                      radius: 8,
                    ),
                    selected: _options.background == background,
                    onSelected: (_) => setState(
                      () =>
                          _options = _options.copyWith(background: background),
                    ),
                  ),
              ],
            ),
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
