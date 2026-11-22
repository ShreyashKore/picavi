import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../domain/services/image_picker_service.dart';

class NativeFileChannelService {
  static const MethodChannel _channel = MethodChannel(
    'com.gyanoba.oiv/file_open',
  );

  Future<List<String>> consumePendingFiles() async {
    if (!Platform.isMacOS) {
      return const <String>[];
    }

    try {
      return await _channel.invokeListMethod<String>('consumePendingFiles') ??
          const <String>[];
    } on MissingPluginException {
      return const <String>[];
    } on PlatformException {
      return const <String>[];
    }
  }

  Future<Map<Object?, Object?>?> getDefaultViewerStatus() async {
    if (!Platform.isMacOS) {
      return null;
    }

    try {
      final status = await _channel.invokeMethod<Object>(
        'getDefaultViewerStatus',
      );
      return status is Map<Object?, Object?> ? status : null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<bool?> setAsDefaultViewer() async {
    if (!Platform.isMacOS) {
      return null;
    }

    try {
      return await _channel.invokeMethod<bool>('setAsDefaultViewer');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  void setOpenFilesHandler(Future<void> Function(List<String> paths)? handler) {
    _channel.setMethodCallHandler(
      handler == null
          ? null
          : (call) async {
              if (call.method != 'openFiles') {
                return;
              }

              final arguments = call.arguments;
              final paths = arguments is List<Object?>
                  ? arguments.whereType<String>().toList(growable: false)
                  : const <String>[];
              await handler(paths);
            },
    );
  }

  Future<String?> pickImageFile({
    required String initialDirectory,
    required ImagePickerTexts texts,
  }) async {
    if (!Platform.isMacOS) {
      return null;
    }

    try {
      return await _channel.invokeMethod<String>('pickImageFile', {
        'initialDirectory': initialDirectory,
        'prompt': texts.openViewerPrompt,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<String?> authorizeDirectoryAccess({
    required String initialDirectory,
    required DirectoryAccessTexts texts,
  }) async {
    if (!Platform.isMacOS) {
      return null;
    }

    try {
      return await _channel.invokeMethod<String>('authorizeDirectoryAccess', {
        'initialDirectory': initialDirectory,
        'prompt': texts.prompt,
        'message': texts.message,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> moveToTrash(String path) =>
      _invokeBool('moveToTrash', {'path': path});

  Future<bool> revealInFileManager(String path) =>
      _invokeBool('revealInFinder', {'path': path});

  Future<bool> copyImageToClipboard(String path) =>
      _invokeBool('copyImageToClipboard', {'path': path});

  Future<bool> openWith(String path, {required String prompt}) =>
      _invokeBool('openWith', {'path': path, 'prompt': prompt});

  Future<bool> _invokeBool(
    String method,
    Map<String, Object?> arguments,
  ) async {
    if (!Platform.isMacOS) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
