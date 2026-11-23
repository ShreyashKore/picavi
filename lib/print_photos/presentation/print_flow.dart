import 'dart:async';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../collage/domain/collage_options.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../editor/data/services/flutter_image_pixel_source.dart';
import '../../editor/domain/services/image_pixel_source.dart';
import '../data/print_pdf.dart';
import '../domain/print_layout.dart';

PrintLayout _lastLayout = PrintLayout.one;

/// Asks for a layout, prepares the photos (with their edits) and opens the
/// system print dialog. Returns false if printing couldn't start.
Future<bool> printPhotos(
  BuildContext context,
  List<CollagePhoto> photos, {
  ImagePixelSource pixelSource = const FlutterImagePixelSource(),
}) async {
  if (photos.isEmpty) {
    return false;
  }
  final layout = await showDialog<PrintLayout>(
    context: context,
    builder: (context) =>
        _PrintLayoutDialog(photoCount: photos.length, initial: _lastLayout),
  );
  if (layout == null || !context.mounted) {
    return true;
  }
  _lastLayout = layout;

  final progress = ValueNotifier<double?>(null);
  final l10n = context.l10n;
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
              Text(l10n.printPreparing),
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
  var progressOpen = true;
  void closeProgress() {
    if (progressOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    progressOpen = false;
  }

  try {
    final jpegs = await preparePrintImages(
      photos,
      layout,
      pixelSource,
      onProgress: (done, total) =>
          progress.value = total == 0 ? null : done / total,
    );
    closeProgress();
    if (jpegs.isEmpty) {
      return false;
    }
    await Printing.layoutPdf(
      name: l10n.printJobName(jpegs.length),
      onLayout: (format) => buildPrintPdf(jpegs, format, layout),
    );
    return true;
  } catch (error) {
    debugPrint('Unable to print: $error');
    closeProgress();
    return false;
  } finally {
    progress.dispose();
  }
}

class _PrintLayoutDialog extends StatefulWidget {
  const _PrintLayoutDialog({required this.photoCount, required this.initial});

  final int photoCount;
  final PrintLayout initial;

  @override
  State<_PrintLayoutDialog> createState() => _PrintLayoutDialogState();
}

class _PrintLayoutDialogState extends State<_PrintLayoutDialog> {
  late PrintLayout _layout = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.printTitle(widget.photoCount)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.printPerPage,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<PrintLayout>(
              showSelectedIcon: false,
              segments: [
                for (final layout in PrintLayout.values)
                  ButtonSegment(
                    value: layout,
                    label: Text('${layout.perPage}'),
                    icon: Icon(switch (layout) {
                      PrintLayout.one => Icons.crop_portrait,
                      PrintLayout.two => Icons.view_agenda_outlined,
                      PrintLayout.four => Icons.grid_view,
                      PrintLayout.nine => Icons.apps,
                    }),
                  ),
              ],
              selected: {_layout},
              onSelectionChanged: (selection) =>
                  setState(() => _layout = selection.single),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.printHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
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
          onPressed: () => Navigator.of(context).pop(_layout),
          child: Text(l10n.printContinue),
        ),
      ],
    );
  }
}
