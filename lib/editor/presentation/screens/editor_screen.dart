import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../data/repositories/sidecar_image_edit_repository.dart';
import '../../data/services/flutter_image_pixel_source.dart';
import '../../data/services/isolate_edit_render_service.dart';
import '../../data/services/raster_image_export_service.dart';
import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/image_edits.dart';
import '../../domain/repositories/image_edit_repository.dart';
import '../../domain/services/edit_render_service.dart';
import '../../domain/services/image_export_service.dart';
import '../../domain/services/image_pixel_source.dart';
import '../controllers/editor_controller.dart';
import '../models/crop_geometry.dart';
import '../models/editor_state.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/editor_side_panel.dart';
import '../widgets/export_options_dialog.dart';

/// Edits one image. Pops with the image's [ImageEdits] when closed.
class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.path,
    required this.pickExportDirectory,
    this.repository,
    this.pixelSource = const FlutterImagePixelSource(),
    this.renderService = const IsolateEditRenderService(),
    this.exportService,
  });

  final String path;

  /// Asks for the folder edited copies go to; null if cancelled.
  final Future<String?> Function() pickExportDirectory;
  final ImageEditRepository? repository;
  final ImagePixelSource pixelSource;
  final EditRenderService renderService;
  final ImageExportService? exportService;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final EditorController _controller;
  EditorPanelTab _tab = EditorPanelTab.fixes;
  CropAspectPreset _cropPreset = CropAspectPreset.free;
  bool? _cropPortrait;
  double _redEyeRadius = 0.025;
  int? _lastNoticeId;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = EditorController(
      path: widget.path,
      repository: widget.repository ?? SidecarImageEditRepository(),
      pixelSource: widget.pixelSource,
      renderService: widget.renderService,
      exportService:
          widget.exportService ??
          RasterImageExportService(pixelSource: widget.pixelSource),
    )..addListener(_onControllerChanged);
    unawaited(_controller.open());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final notice = _controller.state.notice;
    if (notice != null && notice.id != _lastNoticeId) {
      _lastNoticeId = notice.id;
      final l10n = context.l10n;
      final message = switch (notice.type) {
        EditorNoticeType.saveFailed => l10n.editorSaveFailed,
        EditorNoticeType.exported => l10n.editorExported(
          p.basename(notice.detail ?? ''),
        ),
        EditorNoticeType.exportFailed => l10n.editorExportFailed,
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() {});
  }

  bool get _isPortraitImage {
    final base = _controller.state.base;
    return base != null && base.height > base.width;
  }

  bool get _cropIsPortrait => _cropPortrait ?? _isPortraitImage;

  double? get _cropAspect {
    final base = _controller.state.base;
    if (base == null) {
      return null;
    }
    return _cropPreset.ratio(
      Size(base.width.toDouble(), base.height.toDouble()),
      portrait: _cropIsPortrait,
    );
  }

  // -------------------------------------------------------------------------

  /// Applies an unfinished tool so nothing the user set up is lost.
  Future<void> _commitPendingDraft() async {
    if (_controller.state.hasDraftChanges) {
      await _controller.applyTool();
    } else if (_controller.state.tool != EditorTool.none) {
      _controller.cancelTool();
    }
  }

  Future<void> _changeTab(EditorPanelTab tab) async {
    if (tab == _tab) {
      return;
    }
    await _commitPendingDraft();
    if (!mounted) {
      return;
    }
    setState(() => _tab = tab);
    if (tab == EditorPanelTab.tuning) {
      _controller.selectTool(EditorTool.tune);
    }
  }

  void _selectTool(EditorTool tool) {
    _controller.selectTool(tool);
    if (tool == EditorTool.crop) {
      _resetCropRect();
    }
  }

  void _resetCropRect() {
    final aspect = _cropAspect;
    final base = _controller.state.base;
    if (base == null) {
      return;
    }
    _controller.updateDraft(
      CropEdit(
        aspect == null
            ? NormalizedRect.full
            : centeredCrop(
                aspect,
                Size(base.width.toDouble(), base.height.toDouble()),
              ),
      ),
    );
  }

  void _onDraftChanged(EditOperation draft) {
    if (draft is TuneEdit && _controller.state.tool != EditorTool.tune) {
      _controller.selectTool(EditorTool.tune);
    }
    _controller.updateDraft(draft);
  }

  Future<void> _apply() async {
    await _controller.applyTool();
    if (_tab == EditorPanelTab.tuning) {
      _controller.selectTool(EditorTool.tune);
    }
  }

  void _cancelTool() {
    _controller.cancelTool();
    if (_tab == EditorPanelTab.tuning) {
      _controller.selectTool(EditorTool.tune);
    }
  }

  Future<void> _export() async {
    await _commitPendingDraft();
    if (!mounted) {
      return;
    }
    final options = await showExportOptionsDialog(context, imageCount: 1);
    if (options == null) {
      return;
    }
    final directory = await widget.pickExportDirectory();
    if (directory == null) {
      return;
    }
    await _controller.export(options, directory);
  }

  Future<void> _close() async {
    if (_isClosing) {
      return;
    }
    _isClosing = true;
    await _commitPendingDraft();
    if (mounted) {
      Navigator.of(context).pop<ImageEdits>(_controller.state.edits);
    }
  }

  void _handleEscape() {
    final state = _controller.state;
    final toolOpen =
        state.tool == EditorTool.crop ||
        state.tool == EditorTool.straighten ||
        state.tool == EditorTool.redEye ||
        state.tool == EditorTool.effect;
    if (toolOpen) {
      _cancelTool();
    } else {
      unawaited(_close());
    }
  }

  void _handleEnter() {
    if (_controller.state.hasDraftChanges) {
      unawaited(_apply());
    }
  }

  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = _controller.state;
    final ready = !state.isLoading && !state.loadFailed && !state.isBusy;
    final useMeta = Platform.isMacOS;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _handleEscape,
        const SingleActivator(LogicalKeyboardKey.enter): _handleEnter,
        SingleActivator(
          LogicalKeyboardKey.keyZ,
          meta: useMeta,
          control: !useMeta,
        ): () =>
            unawaited(_controller.undo()),
        SingleActivator(
          LogicalKeyboardKey.keyZ,
          meta: useMeta,
          control: !useMeta,
          shift: true,
        ): () =>
            unawaited(_controller.redo()),
        if (!useMeta)
          const SingleActivator(LogicalKeyboardKey.keyY, control: true): () =>
              unawaited(_controller.redo()),
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              unawaited(_close());
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF0C0C10),
            appBar: AppBar(
              leadingWidth: 200,
              leading: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: BackButton(onPressed: () => unawaited(_close())),
              ),
              title: Text(
                p.basename(widget.path),
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  tooltip: l10n.editorUndo,
                  icon: const Icon(Icons.undo),
                  onPressed: ready && state.canUndo
                      ? () => unawaited(_controller.undo())
                      : null,
                ),
                IconButton(
                  tooltip: l10n.editorRedo,
                  icon: const Icon(Icons.redo),
                  onPressed: ready && state.canRedo
                      ? () => unawaited(_controller.redo())
                      : null,
                ),
                TextButton(
                  onPressed: ready && state.edits.isNotEmpty
                      ? () => unawaited(_controller.revert())
                      : null,
                  child: Text(l10n.editorRevert),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: ready ? () => unawaited(_export()) : null,
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: Text(l10n.editorExport),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => unawaited(_close()),
                  child: Text(l10n.editorDone),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: Row(
              children: [
                EditorSidePanel(
                  state: state,
                  tab: _tab,
                  onTabChanged: (tab) => unawaited(_changeTab(tab)),
                  onSelectTool: _selectTool,
                  onSelectEffect: _controller.selectEffect,
                  onDraftChanged: _onDraftChanged,
                  onApply: () => unawaited(_apply()),
                  onCancel: _cancelTool,
                  onRotate: (turns) => unawaited(_controller.rotate(turns)),
                  onAutoFix: (kind) => unawaited(_controller.autoFix(kind)),
                  cropPreset: _cropPreset,
                  cropPortrait: _cropIsPortrait,
                  onCropPresetChanged: (preset) {
                    setState(() => _cropPreset = preset);
                    _resetCropRect();
                  },
                  onCropOrientationToggled: () {
                    setState(() => _cropPortrait = !_cropIsPortrait);
                    _resetCropRect();
                  },
                  redEyeRadius: _redEyeRadius,
                  onRedEyeRadiusChanged: (radius) =>
                      setState(() => _redEyeRadius = radius),
                ),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.galleryOverlay,
                    child: state.loadFailed
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(l10n.editorLoadFailed),
                              ],
                            ),
                          )
                        : EditorCanvas(
                            state: state,
                            onDraftChanged: _onDraftChanged,
                            cropAspect: _cropAspect,
                            redEyeRadius: _redEyeRadius,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
