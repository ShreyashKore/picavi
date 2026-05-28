import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/services/default_viewer_service.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.defaultViewerService,
    this.initialStatus,
  });

  final DefaultViewerService defaultViewerService;
  final DefaultViewerStatus? initialStatus;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  DefaultViewerStatus? _status;
  bool _isLoadingStatus = true;
  bool _isUpdatingDefaultViewer = false;
  String _versionLabel = '—';

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

    final versionLabel = await versionFuture;
    final status = await statusFuture;
    if (!mounted) {
      return;
    }

    setState(() {
      _versionLabel = versionLabel;
      _status = status;
      _isLoadingStatus = false;
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

  Future<String> _loadVersionLabel() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildSuffix = packageInfo.buildNumber.isEmpty
          ? ''
          : ' (${packageInfo.buildNumber})';
      return '${packageInfo.version}$buildSuffix';
    } catch (_) {
      return 'Unknown';
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
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.info_outline),
                          ),
                          title: Text(context.l10n.versionTitle),
                          subtitle: Text(_versionLabel),
                        ),
                      ],
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
