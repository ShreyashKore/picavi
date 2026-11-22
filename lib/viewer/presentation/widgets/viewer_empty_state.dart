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
    required this.settingsLabel,
    required this.tipsText,
    required this.onOpenImage,
    required this.onOpenSettings,
    this.recentFolders,
    this.libraryLabel,
    this.onOpenLibrary,
  });

  final bool isBootstrapping;
  final Iterable<String> supportedExtensions;
  final String title;
  final String description;
  final String openImageLabel;
  final String settingsLabel;
  final String tipsText;
  final VoidCallback onOpenImage;
  final VoidCallback onOpenSettings;
  final String? libraryLabel;
  final VoidCallback? onOpenLibrary;

  /// Optional recent-folders section rendered below the welcome card.
  final Widget? recentFolders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                          extension
                                              .replaceFirst('.', '')
                                              .toUpperCase(),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList()
                                  ..sort(
                                    (left, right) => (left.label as Text).data!
                                        .compareTo((right.label as Text).data!),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: onOpenImage,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: Text(openImageLabel),
                              ),
                              if (onOpenLibrary != null && libraryLabel != null)
                                OutlinedButton.icon(
                                  onPressed: onOpenLibrary,
                                  icon: const Icon(Icons.collections_outlined),
                                  label: Text(libraryLabel!),
                                ),
                              OutlinedButton.icon(
                                onPressed: onOpenSettings,
                                icon: const Icon(Icons.settings_outlined),
                                label: Text(settingsLabel),
                              ),
                            ],
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
                    if (isBootstrapping)
                      LinearProgressIndicator(
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
              if (recentFolders != null) ...[
                const SizedBox(height: 16),
                recentFolders!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
