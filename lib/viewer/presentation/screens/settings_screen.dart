import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/services/default_viewer_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/slideshow_settings_store.dart';
import '../../domain/entities/slideshow_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.appPreferencesService,
    required this.defaultViewerService,
    required this.slideshowSettingsStore,
    this.initialStatus,
    this.showLiveTextSetting = false,
  });

  final AppPreferencesService appPreferencesService;
  final DefaultViewerService defaultViewerService;
  final SlideshowSettingsStore slideshowSettingsStore;
  final DefaultViewerStatus? initialStatus;

  /// Shows the "Select text in images" switch (platforms with Live Text).
  final bool showLiveTextSetting;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  DefaultViewerStatus? _status;
  bool _isLoadingStatus = true;
  bool _isUpdatingDefaultViewer = false;
  bool _isLoadingResumePreference = true;
  bool _isUpdatingResumePreference = false;
  bool _restoreLastOpenedImageEnabled = false;
  bool _isUpdatingRecentFoldersPreference = false;
  bool _showRecentFoldersEnabled = false;
  bool _liveTextEnabled = true;
  String _versionLabel = '—';
  bool _isVersionUnavailable = false;
  SlideshowSettings? _slideshowSettings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _status = widget.initialStatus;
    _isLoadingStatus = widget.initialStatus == null;
    unawaited(_loadScreenData(refreshStatus: widget.initialStatus == null));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshDefaultViewerStatus());
    }
  }

  Future<void> _loadScreenData({required bool refreshStatus}) async {
    final versionFuture = _loadVersionLabel();
    final statusFuture = refreshStatus
        ? widget.defaultViewerService.getStatus()
        : Future<DefaultViewerStatus?>.value(_status);
    final restoreLastOpenedImageEnabledFuture = widget.appPreferencesService
        .isRestoreLastOpenedImageEnabled();
    final showRecentFoldersEnabledFuture = widget.appPreferencesService
        .isShowRecentFoldersEnabled();
    final slideshowSettingsFuture = widget.slideshowSettingsStore.load();
    final liveTextEnabledFuture = widget.appPreferencesService
        .isLiveTextEnabled();

    final versionLabel = await versionFuture;
    final status = await statusFuture;
    final restoreLastOpenedImageEnabled =
        await restoreLastOpenedImageEnabledFuture;
    final showRecentFoldersEnabled = await showRecentFoldersEnabledFuture;
    final slideshowSettings = await slideshowSettingsFuture;
    final liveTextEnabled = await liveTextEnabledFuture;
    if (!mounted) {
      return;
    }

    setState(() {
      _versionLabel = versionLabel ?? _versionLabel;
      _isVersionUnavailable = versionLabel == null;
      _status = status;
      _isLoadingStatus = false;
      _restoreLastOpenedImageEnabled = restoreLastOpenedImageEnabled;
      _showRecentFoldersEnabled = showRecentFoldersEnabled;
      _slideshowSettings = slideshowSettings;
      _liveTextEnabled = liveTextEnabled;
      _isLoadingResumePreference = false;
    });
  }

  Future<void> _refreshDefaultViewerStatus() async {
    final status = await widget.defaultViewerService.getStatus();
    if (!mounted) {
      return;
    }

    setState(() {
      _status = status;
      _isLoadingStatus = false;
    });
  }

  Future<String?> _loadVersionLabel() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildSuffix = packageInfo.buildNumber.isEmpty
          ? ''
          : ' (${packageInfo.buildNumber})';
      return '${packageInfo.version}$buildSuffix';
    } catch (_) {
      return null;
    }
  }

  Future<void> _setDefaultViewer() async {
    if (_isUpdatingDefaultViewer) {
      return;
    }

    setState(() {
      _isUpdatingDefaultViewer = true;
    });

    final result = await widget.defaultViewerService.requestSetAsDefault();
    final status = await widget.defaultViewerService.getStatus();
    if (!mounted) {
      return;
    }

    setState(() {
      _isUpdatingDefaultViewer = false;
      _status = status;
      _isLoadingStatus = false;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(_resultMessage(result.outcome))));
  }

  Future<void> _setRestoreLastOpenedImageEnabled(bool enabled) async {
    if (_isUpdatingResumePreference) {
      return;
    }

    setState(() {
      _isUpdatingResumePreference = true;
    });

    await widget.appPreferencesService.setRestoreLastOpenedImageEnabled(
      enabled,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _restoreLastOpenedImageEnabled = enabled;
      _isLoadingResumePreference = false;
      _isUpdatingResumePreference = false;
    });
  }

  Future<void> _setShowRecentFoldersEnabled(bool enabled) async {
    if (_isUpdatingRecentFoldersPreference) {
      return;
    }

    setState(() {
      _isUpdatingRecentFoldersPreference = true;
    });

    await widget.appPreferencesService.setShowRecentFoldersEnabled(enabled);
    if (!mounted) {
      return;
    }

    setState(() {
      _showRecentFoldersEnabled = enabled;
      _isUpdatingRecentFoldersPreference = false;
    });
  }

  Future<void> _setLiveTextEnabled(bool enabled) async {
    setState(() => _liveTextEnabled = enabled);
    await widget.appPreferencesService.setLiveTextEnabled(enabled);
  }

  Future<void> _updateSlideshowSettings(SlideshowSettings settings) async {
    setState(() => _slideshowSettings = settings);
    await widget.slideshowSettingsStore.save(settings);
  }

  List<Widget> _buildSlideshowSection(SlideshowSettings settings) {
    final l10n = context.l10n;
    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          l10n.slideshowSectionTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      const SizedBox(height: 8),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(child: Icon(Icons.timer_outlined)),
        title: Text(l10n.slideshowIntervalTitle),
        trailing: DropdownButton<int>(
          value: settings.intervalSeconds,
          underline: const SizedBox.shrink(),
          onChanged: (value) {
            if (value != null) {
              unawaited(
                _updateSlideshowSettings(
                  settings.copyWith(intervalSeconds: value),
                ),
              );
            }
          },
          items: [
            for (final seconds in SlideshowSettings.intervalChoices)
              DropdownMenuItem<int>(
                value: seconds,
                child: Text(l10n.slideshowIntervalValue(seconds)),
              ),
          ],
        ),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        secondary: const CircleAvatar(child: Icon(Icons.shuffle_rounded)),
        value: settings.shuffle,
        onChanged: (value) => unawaited(
          _updateSlideshowSettings(settings.copyWith(shuffle: value)),
        ),
        title: Text(l10n.slideshowShuffleTitle),
        subtitle: Text(l10n.slideshowShuffleDescription),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        secondary: const CircleAvatar(child: Icon(Icons.repeat_rounded)),
        value: settings.loop,
        onChanged: (value) =>
            unawaited(_updateSlideshowSettings(settings.copyWith(loop: value))),
        title: Text(l10n.slideshowLoopTitle),
        subtitle: Text(l10n.slideshowLoopDescription),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        secondary: const CircleAvatar(child: Icon(Icons.fullscreen_rounded)),
        value: settings.fullScreen,
        onChanged: (value) => unawaited(
          _updateSlideshowSettings(settings.copyWith(fullScreen: value)),
        ),
        title: Text(l10n.slideshowFullScreenTitle),
        subtitle: Text(l10n.slideshowFullScreenDescription),
      ),
    ];
  }

  String _resultMessage(DefaultViewerRequestOutcome outcome) {
    return switch (outcome) {
      DefaultViewerRequestOutcome.success =>
        context.l10n.defaultViewerSetSuccess,
      DefaultViewerRequestOutcome.launchedSystemSettings =>
        context.l10n.defaultViewerFlowOpened,
      DefaultViewerRequestOutcome.failed => context.l10n.defaultViewerSetFailed,
      DefaultViewerRequestOutcome.unsupported =>
        context.l10n.defaultViewerUnsupported,
    };
  }

  String _statusDescription(DefaultViewerStatus? status) {
    if (status == null) {
      return context.l10n.defaultViewerChecking;
    }

    if (!status.isSupported) {
      return context.l10n.defaultViewerUnsupported;
    }

    if (status.isDefault) {
      return context.l10n.defaultViewerStatusDefault;
    }

    if (status.actionType == DefaultViewerActionType.guided) {
      return context.l10n.defaultViewerGuidedHelp;
    }

    return context.l10n.defaultViewerStatusNotDefault;
  }

  String _defaultViewerActionLabel(DefaultViewerStatus? status) {
    if (status?.actionType == DefaultViewerActionType.guided) {
      return context.l10n.defaultViewerActionOpenSystemSettings;
    }

    return context.l10n.defaultViewerActionSet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        leadingWidth: 200,
        title: Text(context.l10n.settingsTitle),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.shellStart, AppColors.shellEnd],
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.image_search_outlined),
                            ),
                            title: Text(context.l10n.defaultViewerTitle),
                            subtitle: Text(_statusDescription(_status)),
                            trailing: _isLoadingStatus
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : FilledButton(
                                    onPressed:
                                        (_status?.isSupported ?? false) &&
                                            !_isUpdatingDefaultViewer
                                        ? _setDefaultViewer
                                        : null,
                                    child: Text(
                                      _isUpdatingDefaultViewer
                                          ? context.l10n.defaultViewerChecking
                                          : _defaultViewerActionLabel(_status),
                                    ),
                                  ),
                          ),
                          const Divider(height: 28),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            secondary: const CircleAvatar(
                              child: Icon(Icons.history_toggle_off),
                            ),
                            value: _restoreLastOpenedImageEnabled,
                            onChanged:
                                _isLoadingResumePreference ||
                                    _isUpdatingResumePreference
                                ? null
                                : (value) => unawaited(
                                    _setRestoreLastOpenedImageEnabled(value),
                                  ),
                            title: Text(
                              context.l10n.restoreLastOpenedImageTitle,
                            ),
                            subtitle: Text(
                              context.l10n.restoreLastOpenedImageDescription,
                            ),
                          ),
                          if (_isLoadingResumePreference ||
                              _isUpdatingResumePreference)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: LinearProgressIndicator(minHeight: 2),
                            ),
                          const Divider(height: 28),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            secondary: const CircleAvatar(
                              child: Icon(Icons.folder_copy_outlined),
                            ),
                            value: _showRecentFoldersEnabled,
                            onChanged:
                                _isLoadingResumePreference ||
                                    _isUpdatingRecentFoldersPreference
                                ? null
                                : (value) => unawaited(
                                    _setShowRecentFoldersEnabled(value),
                                  ),
                            title: Text(context.l10n.showRecentFoldersTitle),
                            subtitle: Text(
                              context.l10n.showRecentFoldersDescription,
                            ),
                          ),
                          if (_isUpdatingRecentFoldersPreference)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: LinearProgressIndicator(minHeight: 2),
                            ),
                          const Divider(height: 28),
                          if (widget.showLiveTextSetting) ...[
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              secondary: const CircleAvatar(
                                child: Icon(Icons.text_fields),
                              ),
                              value: _liveTextEnabled,
                              onChanged: _isLoadingResumePreference
                                  ? null
                                  : (value) =>
                                        unawaited(_setLiveTextEnabled(value)),
                              title: Text(context.l10n.liveTextSettingTitle),
                              subtitle: Text(
                                context.l10n.liveTextSettingDescription,
                              ),
                            ),
                            const Divider(height: 28),
                          ],
                          if (_slideshowSettings case final settings?) ...[
                            ..._buildSlideshowSection(settings),
                            const Divider(height: 28),
                          ],
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.info_outline),
                            ),
                            title: Text(context.l10n.versionTitle),
                            subtitle: Text(
                              _isVersionUnavailable
                                  ? context.l10n.unknownValue
                                  : _versionLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
