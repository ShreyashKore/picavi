import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../core/l10n/l10n_extensions.dart';
import '../../domain/services/file_operations_service.dart';

/// Asks for a new file name and calls [onRename] until it succeeds or the
/// user cancels. [onRename] returns the failure reason, or null on success.
Future<void> showRenameImageDialog(
  BuildContext context, {
  required String currentFileName,
  required Future<FileOperationError?> Function(String newName) onRename,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        RenameImageDialog(currentFileName: currentFileName, onRename: onRename),
  );
}

class RenameImageDialog extends StatefulWidget {
  const RenameImageDialog({
    super.key,
    required this.currentFileName,
    required this.onRename,
  });

  final String currentFileName;
  final Future<FileOperationError?> Function(String newName) onRename;

  @override
  State<RenameImageDialog> createState() => _RenameImageDialogState();
}

class _RenameImageDialogState extends State<RenameImageDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentFileName,
  );
  FileOperationError? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Select the name without its extension, like Finder and Explorer.
    final stem = p.basenameWithoutExtension(widget.currentFileName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: stem.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final error = await widget.onRename(_controller.text);
    if (!mounted) {
      return;
    }

    if (error == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSubmitting = false;
      _error = error;
    });
  }

  String? _errorText() {
    final l10n = context.l10n;
    return switch (_error) {
      null => null,
      FileOperationError.alreadyExists => l10n.renameErrorExists,
      FileOperationError.invalidName => l10n.renameErrorInvalid,
      FileOperationError.notFound ||
      FileOperationError.failed => l10n.renameErrorFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.renameDialogTitle),
      content: SizedBox(
        width: 380,
        child: TextField(
          controller: _controller,
          autofocus: true,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            labelText: l10n.renameFieldLabel,
            errorText: _errorText(),
            errorMaxLines: 3,
          ),
          onChanged: (_) {
            if (_error != null) {
              setState(() => _error = null);
            }
          },
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(l10n.renameConfirm),
        ),
      ],
    );
  }
}
