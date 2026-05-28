import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ViewerControlBar extends StatelessWidget {
  const ViewerControlBar({
    super.key,
    required this.canNavigate,
    required this.isPlaying,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onZoomOneToOne,
    required this.onPrevious,
    required this.onTogglePlay,
    required this.onNext,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onToggleInfo,
    required this.showInfo,
  });

  final bool canNavigate;
  final bool isPlaying;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomOneToOne;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onToggleInfo;
  final bool showInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _ControlGroup(
            children: [
              _ControlButton(
                tooltip: 'Zoom out',
                icon: Icons.remove,
                onPressed: onZoomOut,
              ),
              _ControlButton(
                tooltip: 'Zoom in',
                icon: Icons.add,
                onPressed: onZoomIn,
              ),
              _OneToOneButton(onPressed: onZoomOneToOne),
            ],
          ),
          if (canNavigate)
            _PlaybackGroup(
              enabled: canNavigate,
              isPlaying: isPlaying,
              onPrevious: onPrevious,
              onTogglePlay: onTogglePlay,
              onNext: onNext,
            ),
          _ControlGroup(
            children: [
              _ControlButton(
                tooltip: 'Rotate left',
                icon: Icons.rotate_90_degrees_ccw_outlined,
                onPressed: onRotateLeft,
              ),
              _ControlButton(
                tooltip: 'Rotate right',
                icon: Icons.rotate_90_degrees_cw_outlined,
                onPressed: onRotateRight,
              ),
              _ControlButton(
                tooltip: showInfo ? 'Hide image info' : 'Show image info',
                icon: showInfo ? Icons.info : Icons.info_outline,
                onPressed: onToggleInfo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlGroup extends StatelessWidget {
  const _ControlGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.topOverlay,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _OneToOneButton extends StatelessWidget {
  const _OneToOneButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('1:1'),
    );
  }
}

class _PlaybackGroup extends StatelessWidget {
  const _PlaybackGroup({
    required this.enabled,
    required this.isPlaying,
    required this.onPrevious,
    required this.onTogglePlay,
    required this.onNext,
  });

  final bool enabled;
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.topOverlay,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ControlButton(
              tooltip: 'Previous image',
              icon: Icons.skip_previous_rounded,
              onPressed: disabled ? null : onPrevious,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: isPlaying ? 'Pause slideshow' : 'Play slideshow',
                  onPressed: disabled ? null : onTogglePlay,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            _ControlButton(
              tooltip: 'Next image',
              icon: Icons.skip_next_rounded,
              onPressed: disabled ? null : onNext,
            ),
          ],
        ),
      ),
    );
  }
}
