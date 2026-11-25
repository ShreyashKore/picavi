import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/edit_operation.dart';
import '../models/crop_geometry.dart';
import '../models/editor_state.dart';

enum EditorPanelTab { fixes, tuning, effects }

/// Picasa-style side panel: Basic fixes / Tuning / Effects, or the settings
/// of the tool that is open.
class EditorSidePanel extends StatelessWidget {
  const EditorSidePanel({
    super.key,
    required this.state,
    required this.tab,
    required this.onTabChanged,
    required this.onSelectTool,
    required this.onSelectEffect,
    required this.onDraftChanged,
    required this.onApply,
    required this.onCancel,
    required this.onRotate,
    required this.onAutoFix,
    required this.cropPreset,
    required this.cropPortrait,
    required this.onCropPresetChanged,
    required this.onCropOrientationToggled,
    required this.redEyeRadius,
    required this.onRedEyeRadiusChanged,
  });

  static const double width = 320;

  final EditorState state;
  final EditorPanelTab tab;
  final ValueChanged<EditorPanelTab> onTabChanged;
  final ValueChanged<EditorTool> onSelectTool;
  final ValueChanged<EffectKind> onSelectEffect;
  final ValueChanged<EditOperation> onDraftChanged;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final ValueChanged<int> onRotate;
  final ValueChanged<AutoFixKind> onAutoFix;
  final CropAspectPreset cropPreset;
  final bool cropPortrait;
  final ValueChanged<CropAspectPreset> onCropPresetChanged;
  final VoidCallback onCropOrientationToggled;
  final double redEyeRadius;
  final ValueChanged<double> onRedEyeRadiusChanged;

  bool get _enabled => !state.isLoading && !state.loadFailed && !state.isBusy;

  @override
  Widget build(BuildContext context) {
    final toolPanel = switch (state.tool) {
      EditorTool.crop => _buildCropPanel(context),
      EditorTool.straighten => _buildStraightenPanel(context),
      EditorTool.redEye => _buildRedEyePanel(context),
      _ => null,
    };

    // A Material (not a coloured box) so list tiles show hover and ink.
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.panel,
        shape: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: toolPanel ?? _buildTabs(context),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<EditorPanelTab>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            segments: [
              ButtonSegment(
                value: EditorPanelTab.fixes,
                label: _TabLabel(context.l10n.editorTabFixes),
              ),
              ButtonSegment(
                value: EditorPanelTab.tuning,
                label: _TabLabel(context.l10n.editorTabTuning),
              ),
              ButtonSegment(
                value: EditorPanelTab.effects,
                label: _TabLabel(context.l10n.editorTabEffects),
              ),
            ],
            selected: {tab},
            onSelectionChanged: _enabled
                ? (selection) => onTabChanged(selection.single)
                : null,
          ),
        ),
        Expanded(
          child: switch (tab) {
            EditorPanelTab.fixes => _buildFixes(context),
            EditorPanelTab.tuning => _buildTuning(context),
            EditorPanelTab.effects => _buildEffects(context),
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tabs

  Widget _buildFixes(BuildContext context) {
    final l10n = context.l10n;
    Widget action(IconData icon, String label, VoidCallback onPressed) {
      return ListTile(
        dense: true,
        enabled: _enabled,
        leading: Icon(icon, size: 20),
        title: Text(label),
        onTap: onPressed,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        action(
          Icons.crop,
          l10n.editorCrop,
          () => onSelectTool(EditorTool.crop),
        ),
        action(
          Icons.straighten,
          l10n.editorStraighten,
          () => onSelectTool(EditorTool.straighten),
        ),
        action(
          Icons.remove_red_eye_outlined,
          l10n.editorRedEye,
          () => onSelectTool(EditorTool.redEye),
        ),
        action(Icons.rotate_left, l10n.rotateLeftTooltip, () => onRotate(-1)),
        action(Icons.rotate_right, l10n.rotateRightTooltip, () => onRotate(1)),
        const Divider(indent: 16, endIndent: 16),
        action(
          Icons.auto_awesome,
          l10n.editorFeelingLucky,
          () => onAutoFix(AutoFixKind.feelingLucky),
        ),
        action(
          Icons.contrast,
          l10n.editorAutoContrast,
          () => onAutoFix(AutoFixKind.autoContrast),
        ),
        action(
          Icons.color_lens_outlined,
          l10n.editorAutoColor,
          () => onAutoFix(AutoFixKind.autoColor),
        ),
      ],
    );
  }

  Widget _buildTuning(BuildContext context) {
    final l10n = context.l10n;
    final draft = state.draft;
    final tune = draft is TuneEdit ? draft : const TuneEdit();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        _LabeledSlider(
          label: l10n.editorTuneFillLight,
          value: tune.fillLight,
          enabled: _enabled,
          onChanged: (v) => onDraftChanged(tune.copyWith(fillLight: v)),
        ),
        _LabeledSlider(
          label: l10n.editorTuneHighlights,
          value: tune.highlights,
          enabled: _enabled,
          onChanged: (v) => onDraftChanged(tune.copyWith(highlights: v)),
        ),
        _LabeledSlider(
          label: l10n.editorTuneShadows,
          value: tune.shadows,
          enabled: _enabled,
          onChanged: (v) => onDraftChanged(tune.copyWith(shadows: v)),
        ),
        _LabeledSlider(
          label: l10n.editorTuneTemperature,
          value: tune.temperature,
          min: -1,
          enabled: _enabled,
          onChanged: (v) => onDraftChanged(tune.copyWith(temperature: v)),
        ),
        const SizedBox(height: 12),
        _ApplyRow(
          applyLabel: l10n.editorApply,
          cancelLabel: l10n.editorReset,
          onApply: state.hasDraftChanges ? onApply : null,
          onCancel: state.hasDraftChanges
              ? () => onDraftChanged(const TuneEdit())
              : null,
        ),
      ],
    );
  }

  Widget _buildEffects(BuildContext context) {
    final l10n = context.l10n;
    final draft = state.draft;
    final active = state.tool == EditorTool.effect && draft is EffectEdit
        ? draft
        : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in EffectKind.values)
              ChoiceChip(
                avatar: Icon(effectIcon(kind), size: 18),
                label: Text(effectLabel(l10n, kind)),
                selected: active?.kind == kind,
                onSelected: _enabled ? (_) => onSelectEffect(kind) : null,
              ),
          ],
        ),
        if (active != null) ...[
          const SizedBox(height: 16),
          _LabeledSlider(
            label: l10n.editorStrength,
            value: active.amount,
            min: active.kind.minAmount,
            enabled: _enabled,
            onChanged: (v) => onDraftChanged(EffectEdit(active.kind, v)),
          ),
          const SizedBox(height: 8),
          _ApplyRow(
            applyLabel: l10n.editorApply,
            cancelLabel: l10n.cancelLabel,
            onApply: state.hasDraftChanges ? onApply : null,
            onCancel: onCancel,
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tools

  Widget _buildCropPanel(BuildContext context) {
    final l10n = context.l10n;
    return _ToolPanel(
      title: l10n.editorCrop,
      hint: l10n.editorCropHint,
      onApply: state.hasDraftChanges ? onApply : null,
      onCancel: onCancel,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in CropAspectPreset.values)
              ChoiceChip(
                label: Text(cropPresetLabel(l10n, preset)),
                selected: preset == cropPreset,
                onSelected: (_) => onCropPresetChanged(preset),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed:
                cropPreset == CropAspectPreset.free ||
                    cropPreset == CropAspectPreset.square
                ? null
                : onCropOrientationToggled,
            icon: Icon(
              cropPortrait ? Icons.crop_portrait : Icons.crop_landscape,
            ),
            label: Text(l10n.editorCropSwapOrientation),
          ),
        ),
      ],
    );
  }

  Widget _buildStraightenPanel(BuildContext context) {
    final l10n = context.l10n;
    final draft = state.draft;
    final degrees = draft is StraightenEdit ? draft.degrees : 0.0;
    return _ToolPanel(
      title: l10n.editorStraighten,
      hint: l10n.editorStraightenHint,
      onApply: state.hasDraftChanges ? onApply : null,
      onCancel: onCancel,
      children: [
        Text(
          l10n.editorDegrees(degrees.toStringAsFixed(1)),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Slider(
          value: degrees,
          min: -StraightenEdit.maxDegrees,
          max: StraightenEdit.maxDegrees,
          onChanged: (v) =>
              onDraftChanged(StraightenEdit((v * 10).roundToDouble() / 10)),
        ),
      ],
    );
  }

  Widget _buildRedEyePanel(BuildContext context) {
    final l10n = context.l10n;
    return _ToolPanel(
      title: l10n.editorRedEye,
      hint: l10n.editorRedEyeHint,
      onApply: state.hasDraftChanges ? onApply : null,
      onCancel: onCancel,
      children: [
        _LabeledSlider(
          label: l10n.editorRedEyeSize,
          value: redEyeRadius,
          min: 0.008,
          max: 0.08,
          onChanged: onRedEyeRadiusChanged,
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: state.hasDraftChanges
                ? () => onDraftChanged(const RedEyeEdit([]))
                : null,
            icon: const Icon(Icons.clear),
            label: Text(l10n.editorClear),
          ),
        ),
      ],
    );
  }
}

/// Keeps a tab's label on one line, shrinking long translations to fit.
class _TabLabel extends StatelessWidget {
  const _TabLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, softWrap: false),
    );
  }
}

String effectLabel(AppLocalizations l10n, EffectKind kind) => switch (kind) {
  EffectKind.blackAndWhite => l10n.effectBlackAndWhite,
  EffectKind.sepia => l10n.effectSepia,
  EffectKind.warmify => l10n.effectWarmify,
  EffectKind.saturation => l10n.effectSaturation,
  EffectKind.sharpen => l10n.effectSharpen,
  EffectKind.softFocus => l10n.effectSoftFocus,
  EffectKind.glow => l10n.effectGlow,
  EffectKind.filmGrain => l10n.effectFilmGrain,
  EffectKind.vignette => l10n.effectVignette,
};

IconData effectIcon(EffectKind kind) => switch (kind) {
  EffectKind.blackAndWhite => Icons.filter_b_and_w,
  EffectKind.sepia => Icons.filter_vintage_outlined,
  EffectKind.warmify => Icons.wb_sunny_outlined,
  EffectKind.saturation => Icons.palette_outlined,
  EffectKind.sharpen => Icons.deblur,
  EffectKind.softFocus => Icons.blur_on,
  EffectKind.glow => Icons.flare,
  EffectKind.filmGrain => Icons.grain,
  EffectKind.vignette => Icons.vignette_outlined,
};

String cropPresetLabel(AppLocalizations l10n, CropAspectPreset preset) =>
    switch (preset) {
      CropAspectPreset.free => l10n.editorCropFree,
      CropAspectPreset.original => l10n.editorCropOriginal,
      CropAspectPreset.square => l10n.editorCropSquare,
      CropAspectPreset.print4x6 => l10n.editorCrop4x6,
      CropAspectPreset.print5x7 => l10n.editorCrop5x7,
      CropAspectPreset.print8x10 => l10n.editorCrop8x10,
      CropAspectPreset.wide16x9 => l10n.editorCrop16x9,
    };

class _ToolPanel extends StatelessWidget {
  const _ToolPanel({
    required this.title,
    required this.hint,
    required this.children,
    required this.onApply,
    required this.onCancel,
  });

  final String title;
  final String hint;
  final List<Widget> children;
  final VoidCallback? onApply;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          hint,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 16),
        _ApplyRow(
          applyLabel: context.l10n.editorApply,
          cancelLabel: context.l10n.cancelLabel,
          onApply: onApply,
          onCancel: onCancel,
        ),
      ],
    );
  }
}

class _ApplyRow extends StatelessWidget {
  const _ApplyRow({
    required this.applyLabel,
    required this.cancelLabel,
    required this.onApply,
    required this.onCancel,
  });

  final String applyLabel;
  final String cancelLabel;
  final VoidCallback? onApply;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: onCancel, child: Text(cancelLabel)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(onPressed: onApply, child: Text(applyLabel)),
        ),
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.enabled = true,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
