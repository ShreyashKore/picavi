import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../library/domain/entities/photo_info.dart';

/// Edits a photo's caption and tags. Returns (caption, tags), or null if
/// cancelled.
Future<(String, List<String>)?> showCaptionTagsDialog(
  BuildContext context, {
  required PhotoInfo info,
}) {
  return showDialog<(String, List<String>)>(
    context: context,
    builder: (context) => _CaptionTagsDialog(info: info),
  );
}

class _CaptionTagsDialog extends StatefulWidget {
  const _CaptionTagsDialog({required this.info});

  final PhotoInfo info;

  @override
  State<_CaptionTagsDialog> createState() => _CaptionTagsDialogState();
}

class _CaptionTagsDialogState extends State<_CaptionTagsDialog> {
  late final TextEditingController _caption = TextEditingController(
    text: widget.info.caption,
  );
  late final TextEditingController _tags = TextEditingController(
    text: widget.info.tags.join(', '),
  );

  @override
  void dispose() {
    _caption.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(
      context,
    ).pop((_caption.text.trim(), PhotoInfo.parseTags(_tags.text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.captionTagsTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360, maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _caption,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(labelText: l10n.captionLabel),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tags,
              decoration: InputDecoration(
                labelText: l10n.tagsLabel,
                helperText: l10n.tagsHint,
              ),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.saveLabel)),
      ],
    );
  }
}
