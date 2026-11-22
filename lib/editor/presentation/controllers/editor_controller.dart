import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/entities/image_edits.dart';
import '../../domain/entities/rgba_image.dart';
import '../../domain/repositories/image_edit_repository.dart';
import '../../domain/services/edit_render_service.dart';
import '../../domain/services/image_export_service.dart';
import '../../domain/services/image_pixel_source.dart';
import '../models/editor_state.dart';

/// Drives the editor for one image: applied edits with undo/redo, the
/// active tool's draft, and the rendered preview. Every applied change is
/// saved to the sidecar straight away; the original file is never touched.
class EditorController extends ChangeNotifier {
  EditorController({
    required String path,
    required ImageEditRepository repository,
    required ImagePixelSource pixelSource,
    required EditRenderService renderService,
    required ImageExportService exportService,
    this.previewMaxDimension = 2048,
  }) : _repository = repository,
       _pixelSource = pixelSource,
       _renderService = renderService,
       _exportService = exportService,
       _state = EditorState(path: path);

  final ImageEditRepository _repository;
  final ImagePixelSource _pixelSource;
  final EditRenderService _renderService;
  final ImageExportService _exportService;
  final int previewMaxDimension;

  EditorState _state;
  RgbaImage? _source;
  final List<ImageEdits> _undo = [];
  final List<ImageEdits> _redo = [];
  int _baseGeneration = 0;
  int _draftGeneration = 0;
  bool _draftRenderRunning = false;
  bool _draftRenderQueued = false;
  int _noticeCounter = 0;
  bool _isDisposed = false;

  EditorState get state => _state;

  Future<void> open() async {
    final results = await Future.wait<Object?>([
      _pixelSource.load(_state.path, maxDimension: previewMaxDimension),
      _repository.load(_state.path),
    ]);
    final source = results[0] as RgbaImage?;
    final edits = results[1]! as ImageEdits;
    if (source == null) {
      _setState(_state.copyWith(isLoading: false, loadFailed: true));
      return;
    }
    _source = source;
    _setState(_state.copyWith(edits: edits));
    await _renderBase();
    _setState(_state.copyWith(isLoading: false));
  }

  // -------------------------------------------------------------------------
  // Tools

  void selectTool(EditorTool tool) {
    if (_state.isLoading || _state.loadFailed) {
      return;
    }
    final EditOperation? draft = switch (tool) {
      EditorTool.none => null,
      EditorTool.crop => const CropEdit(NormalizedRect.full),
      EditorTool.straighten => const StraightenEdit(0),
      EditorTool.redEye => const RedEyeEdit([]),
      EditorTool.tune => const TuneEdit(),
      EditorTool.effect => null,
    };
    _draftGeneration += 1;
    _setState(
      _state.copyWith(tool: tool, draft: () => draft, preview: _state.base),
    );
  }

  void selectEffect(EffectKind kind) {
    if (_state.isLoading || _state.loadFailed) {
      return;
    }
    _setState(_state.copyWith(tool: EditorTool.effect));
    updateDraft(EffectEdit(kind, kind.defaultAmount));
  }

  /// Changes the active tool's settings. Colour and red-eye drafts are
  /// rendered in the background; crop and straighten are previewed by the
  /// screen itself.
  void updateDraft(EditOperation draft) {
    _setState(_state.copyWith(draft: () => draft));
    if (draft is TuneEdit || draft is EffectEdit || draft is RedEyeEdit) {
      _scheduleDraftRender();
    }
  }

  void cancelTool() {
    _draftGeneration += 1;
    _setState(
      _state.copyWith(
        tool: EditorTool.none,
        draft: () => null,
        preview: _state.base,
        isRendering: false,
      ),
    );
  }

  /// Applies the active tool's draft (if it changes anything) and closes it.
  Future<void> applyTool() async {
    final draft = _state.draft;
    if (draft == null || !_state.hasDraftChanges) {
      cancelTool();
      return;
    }
    // Keep showing the draft until the new base has rendered.
    _draftGeneration += 1;
    _setState(_state.copyWith(tool: EditorTool.none, draft: () => null));
    await _commit(_state.edits.adding(draft));
  }

  // -------------------------------------------------------------------------
  // One-click edits

  Future<void> rotate(int clockwiseTurns) async {
    _closeTool();
    final operations = [..._state.edits.operations];
    var turns = clockwiseTurns;
    // Merge with a rotation applied just before, so four clicks cancel out.
    if (operations.isNotEmpty && operations.last is RotateEdit) {
      turns += (operations.removeLast() as RotateEdit).turns;
    }
    if (turns % 4 != 0) {
      operations.add(RotateEdit(turns % 4));
    }
    await _commit(ImageEdits(operations));
  }

  Future<void> autoFix(AutoFixKind kind) async {
    final base = _state.base;
    if (base == null || _state.isBusy) {
      return;
    }
    _closeTool();
    _setState(_state.copyWith(isBusy: true));
    try {
      final fix = await _renderService.autoFix(base, kind);
      if (_isDisposed) {
        return;
      }
      await _commit(_state.edits.adding(fix));
    } finally {
      _setState(_state.copyWith(isBusy: false));
    }
  }

  // -------------------------------------------------------------------------
  // History

  Future<void> undo() async {
    _closeTool();
    if (_undo.isEmpty) {
      return;
    }
    _redo.add(_state.edits);
    await _setEdits(_undo.removeLast());
  }

  Future<void> redo() async {
    _closeTool();
    if (_redo.isEmpty) {
      return;
    }
    _undo.add(_state.edits);
    await _setEdits(_redo.removeLast());
  }

  /// Removes every edit (can be undone).
  Future<void> revert() async {
    _closeTool();
    if (_state.edits.isEmpty) {
      return;
    }
    await _commit(ImageEdits.none);
  }

  // -------------------------------------------------------------------------
  // Export

  Future<String?> export(ExportOptions options, String directory) async {
    _setState(_state.copyWith(isBusy: true));
    try {
      final exported = await _exportService.export(
        _state.path,
        _state.edits,
        options,
        directory,
      );
      _emitNotice(
        exported == null
            ? EditorNoticeType.exportFailed
            : EditorNoticeType.exported,
        detail: exported,
      );
      return exported;
    } finally {
      _setState(_state.copyWith(isBusy: false));
    }
  }

  // -------------------------------------------------------------------------

  /// One-click edits replace whatever tool was open, discarding its draft.
  void _closeTool() {
    if (_state.tool != EditorTool.none) {
      cancelTool();
    }
  }

  Future<void> _commit(ImageEdits edits) async {
    if (edits == _state.edits) {
      return;
    }
    _undo.add(_state.edits);
    _redo.clear();
    await _setEdits(edits);
  }

  Future<void> _setEdits(ImageEdits edits) async {
    _setState(
      _state.copyWith(
        edits: edits,
        canUndo: _undo.isNotEmpty,
        canRedo: _redo.isNotEmpty,
      ),
    );
    final saved = await _repository.save(_state.path, edits);
    if (!saved) {
      _emitNotice(EditorNoticeType.saveFailed);
    }
    await _renderBase();
  }

  Future<void> _renderBase() async {
    final source = _source;
    if (source == null) {
      return;
    }
    final generation = ++_baseGeneration;
    _setState(_state.copyWith(isRendering: true));
    final operations = _state.edits.operations;
    final rendered = await _renderService.render(source, operations);
    if (_isDisposed || generation != _baseGeneration) {
      return;
    }
    _setState(
      _state.copyWith(base: rendered, preview: rendered, isRendering: false),
    );
    if (_state.draft != null) {
      _scheduleDraftRender();
    }
  }

  /// Renders the draft on top of the base, coalescing rapid slider moves:
  /// at most one render runs, and only the latest settings are rendered next.
  void _scheduleDraftRender() {
    if (_draftRenderRunning) {
      _draftRenderQueued = true;
      return;
    }
    unawaited(_renderDraft());
  }

  Future<void> _renderDraft() async {
    final base = _state.base;
    final draft = _state.draft;
    if (base == null ||
        draft == null ||
        draft is CropEdit ||
        draft is StraightenEdit) {
      return;
    }
    _draftRenderRunning = true;
    final generation = _draftGeneration;
    _setState(_state.copyWith(isRendering: true));
    try {
      final rendered = await _renderService.render(base, [draft]);
      if (_isDisposed) {
        return;
      }
      if (generation == _draftGeneration && identical(base, _state.base)) {
        _setState(_state.copyWith(preview: rendered));
      }
    } finally {
      _draftRenderRunning = false;
      if (!_isDisposed) {
        if (_draftRenderQueued) {
          _draftRenderQueued = false;
          unawaited(_renderDraft());
        } else {
          _setState(_state.copyWith(isRendering: false));
        }
      }
    }
  }

  void _emitNotice(EditorNoticeType type, {String? detail}) {
    _noticeCounter += 1;
    _setState(
      _state.copyWith(
        notice: EditorNotice(id: _noticeCounter, type: type, detail: detail),
      ),
    );
  }

  void _setState(EditorState state) {
    if (_isDisposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
