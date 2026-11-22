import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/image_edits.dart';
import '../../domain/entities/rgba_image.dart';

/// The tool whose settings are being adjusted before they are applied.
enum EditorTool { none, crop, straighten, redEye, tune, effect }

enum EditorNoticeType { saveFailed, exported, exportFailed }

class EditorNotice {
  const EditorNotice({required this.id, required this.type, this.detail});

  final int id;
  final EditorNoticeType type;
  final String? detail;
}

class EditorState {
  const EditorState({
    required this.path,
    this.isLoading = true,
    this.loadFailed = false,
    this.edits = ImageEdits.none,
    this.canUndo = false,
    this.canRedo = false,
    this.tool = EditorTool.none,
    this.draft,
    this.base,
    this.preview,
    this.isRendering = false,
    this.isBusy = false,
    this.notice,
  });

  final String path;
  final bool isLoading;
  final bool loadFailed;

  /// The applied edits (what's saved in the sidecar).
  final ImageEdits edits;
  final bool canUndo;
  final bool canRedo;

  final EditorTool tool;

  /// The active tool's settings, not applied yet.
  final EditOperation? draft;

  /// The image with [edits] applied, at preview size.
  final RgbaImage? base;

  /// What to show: [base] plus the [draft] where it is rendered on the CPU.
  final RgbaImage? preview;

  final bool isRendering;

  /// An automatic fix or export is running.
  final bool isBusy;
  final EditorNotice? notice;

  bool get hasDraftChanges => switch (draft) {
    null => false,
    CropEdit(:final rect) => !rect.isFull,
    StraightenEdit(:final degrees) => degrees != 0,
    final TuneEdit tune => !tune.isNeutral,
    EffectEdit(:final amount) => amount != 0,
    RedEyeEdit(:final spots) => spots.isNotEmpty,
    _ => true,
  };

  EditorState copyWith({
    bool? isLoading,
    bool? loadFailed,
    ImageEdits? edits,
    bool? canUndo,
    bool? canRedo,
    EditorTool? tool,
    EditOperation? Function()? draft,
    RgbaImage? base,
    RgbaImage? preview,
    bool? isRendering,
    bool? isBusy,
    EditorNotice? notice,
  }) {
    return EditorState(
      path: path,
      isLoading: isLoading ?? this.isLoading,
      loadFailed: loadFailed ?? this.loadFailed,
      edits: edits ?? this.edits,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      tool: tool ?? this.tool,
      draft: draft != null ? draft() : this.draft,
      base: base ?? this.base,
      preview: preview ?? this.preview,
      isRendering: isRendering ?? this.isRendering,
      isBusy: isBusy ?? this.isBusy,
      notice: notice ?? this.notice,
    );
  }
}
