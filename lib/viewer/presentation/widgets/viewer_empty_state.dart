import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ViewerEmptyState extends StatelessWidget {
  const ViewerEmptyState({
    super.key,
    required this.isBootstrapping,
    required this.supportedExtensions,
    required this.title,
    required this.description,
    required this.openImageLabel,
    required this.tipsText,
    required this.onOpenImage,
  });

  final bool isBootstrapping;
  final Iterable<String> supportedExtensions;
  final String title;
  final String description;
  final String openImageLabel;
  final String tipsText;
  final VoidCallback onOpenImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBootstrapping) ...[
                  const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      supportedExtensions
                          .map(
                            (extension) => Chip(
                              label: Text(
                                extension.replaceFirst('.', '').toUpperCase(),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList()
                        ..sort(
                          (left, right) => (left.label as Text).data!.compareTo(
                            (right.label as Text).data!,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onOpenImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(openImageLabel),
                ),
                const SizedBox(height: 10),
                Text(
                  tipsText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    height: 1.35,
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
