import 'dart:io';

import '../../viewer/data/services/native_file_channel_service.dart';

enum DefaultViewerActionType { direct, guided }

enum DefaultViewerRequestOutcome {
  success,
  launchedSystemSettings,
  failed,
  unsupported,
}

class DefaultViewerStatus {
  const DefaultViewerStatus({
    required this.isDefault,
    required this.isSupported,
    required this.actionType,
  });

  const DefaultViewerStatus.unsupported()
    : isDefault = false,
      isSupported = false,
      actionType = DefaultViewerActionType.guided;

  final bool isDefault;
  final bool isSupported;
  final DefaultViewerActionType actionType;

  bool get needsAttention => isSupported && !isDefault;
}

class DefaultViewerRequestResult {
  const DefaultViewerRequestResult({required this.outcome});

  final DefaultViewerRequestOutcome outcome;
}

class DefaultViewerService {
  DefaultViewerService({NativeFileChannelService? nativeFileChannelService})
    : _nativeFileChannelService =
          nativeFileChannelService ?? NativeFileChannelService();

  static const String _linuxDesktopEntryId = 'oiv.desktop';
  static const String _windowsProgId = 'Picavi.ImageFile';
  static const List<String> _windowsSupportedExtensions = <String>[
    '.bmp',
    '.gif',
    '.ico',
    '.jpeg',
    '.jpg',
    '.png',
    '.svg',
    '.webp',
  ];
  static const List<String> _linuxSupportedMimeTypes = <String>[
    'image/bmp',
    'image/gif',
    'image/jpeg',
    'image/png',
    'image/svg+xml',
    'image/webp',
    'image/x-icon',
  ];

  final NativeFileChannelService _nativeFileChannelService;

  Future<DefaultViewerStatus> getStatus() async {
    try {
      if (Platform.isMacOS) {
        final status = await _nativeFileChannelService.getDefaultViewerStatus();
        if (status == null) {
          return const DefaultViewerStatus.unsupported();
        }

        return DefaultViewerStatus(
          isDefault: status['isDefault'] == true,
          isSupported: status['isSupported'] == true,
          actionType: DefaultViewerActionType.direct,
        );
      }

      if (Platform.isWindows) {
        return await _getWindowsStatus();
      }

      if (Platform.isLinux) {
        return await _getLinuxStatus();
      }
    } catch (_) {
      // Fall through to unsupported state.
    }

    return const DefaultViewerStatus.unsupported();
  }

  Future<DefaultViewerRequestResult> requestSetAsDefault() async {
    try {
      if (Platform.isMacOS) {
        final didSetDefault =
            await _nativeFileChannelService.setAsDefaultViewer() ?? false;
        return DefaultViewerRequestResult(
          outcome: didSetDefault
              ? DefaultViewerRequestOutcome.success
              : DefaultViewerRequestOutcome.failed,
        );
      }

      if (Platform.isWindows) {
        final processResult = await Process.run('cmd', <String>[
          '/c',
          'start',
          '',
          'ms-settings:defaultapps',
        ]);
        return DefaultViewerRequestResult(
          outcome: processResult.exitCode == 0
              ? DefaultViewerRequestOutcome.launchedSystemSettings
              : DefaultViewerRequestOutcome.failed,
        );
      }

      if (Platform.isLinux) {
        final didSetDefault = await _setLinuxDefaultViewer();
        return DefaultViewerRequestResult(
          outcome: didSetDefault
              ? DefaultViewerRequestOutcome.success
              : DefaultViewerRequestOutcome.failed,
        );
      }
    } catch (_) {
      return const DefaultViewerRequestResult(
        outcome: DefaultViewerRequestOutcome.failed,
      );
    }

    return const DefaultViewerRequestResult(
      outcome: DefaultViewerRequestOutcome.unsupported,
    );
  }

  Future<DefaultViewerStatus> _getWindowsStatus() async {
    var checkedExtensions = 0;
    var matchingExtensions = 0;

    for (final extension in _windowsSupportedExtensions) {
      final progId = await _readWindowsUserChoiceProgId(extension);
      checkedExtensions += 1;
      if (progId == _windowsProgId) {
        matchingExtensions += 1;
      }
    }

    return DefaultViewerStatus(
      isDefault:
          checkedExtensions > 0 && matchingExtensions == checkedExtensions,
      isSupported: true,
      actionType: DefaultViewerActionType.guided,
    );
  }

  Future<String?> _readWindowsUserChoiceProgId(String extension) async {
    final queryPath =
        'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FileExts\\$extension\\UserChoice';
    final result = await Process.run('reg', <String>[
      'query',
      queryPath,
      '/v',
      'ProgId',
    ]);
    if (result.exitCode != 0) {
      return null;
    }

    final match = RegExp(
      r'ProgId\s+REG_SZ\s+([^\r\n]+)',
      caseSensitive: false,
    ).firstMatch('${result.stdout}');
    return match?.group(1)?.trim();
  }

  Future<DefaultViewerStatus> _getLinuxStatus() async {
    final resolvedDefaults = <String>[];

    for (final mimeType in _linuxSupportedMimeTypes) {
      final desktopEntry = await _queryLinuxDesktopEntry(mimeType);
      if (desktopEntry != null) {
        resolvedDefaults.add(desktopEntry);
      }
    }

    if (resolvedDefaults.isEmpty) {
      return DefaultViewerStatus(
        isDefault: false,
        isSupported: true,
        actionType: DefaultViewerActionType.direct,
      );
    }

    return DefaultViewerStatus(
      isDefault: resolvedDefaults.every(
        (entry) => entry == _linuxDesktopEntryId,
      ),
      isSupported: true,
      actionType: DefaultViewerActionType.direct,
    );
  }

  Future<String?> _queryLinuxDesktopEntry(String mimeType) async {
    final xdgMimeResult = await Process.run('xdg-mime', <String>[
      'query',
      'default',
      mimeType,
    ]);
    final xdgMimeValue = '${xdgMimeResult.stdout}'.trim();
    if (xdgMimeResult.exitCode == 0 && xdgMimeValue.isNotEmpty) {
      return xdgMimeValue;
    }

    final gioResult = await Process.run('gio', <String>['mime', mimeType]);
    if (gioResult.exitCode != 0) {
      return null;
    }

    final match = RegExp(
      r'Default application for .+?:\s*([^\r\n]+)',
      caseSensitive: false,
    ).firstMatch('${gioResult.stdout}');
    return match?.group(1)?.trim();
  }

  Future<bool> _setLinuxDefaultViewer() async {
    final xdgMimeResult = await Process.run('xdg-mime', <String>[
      'default',
      _linuxDesktopEntryId,
      ..._linuxSupportedMimeTypes,
    ]);
    if (xdgMimeResult.exitCode == 0) {
      return true;
    }

    var hadSuccess = false;
    for (final mimeType in _linuxSupportedMimeTypes) {
      final gioResult = await Process.run('gio', <String>[
        'mime',
        mimeType,
        _linuxDesktopEntryId,
      ]);
      if (gioResult.exitCode != 0) {
        return false;
      }
      hadSuccess = true;
    }

    return hadSuccess;
  }
}
