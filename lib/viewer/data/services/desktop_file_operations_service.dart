import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../domain/services/file_operations_service.dart';
import 'native_file_channel_service.dart';

/// File actions for macOS (native channel), Windows and Linux (system tools).
///
/// Paths are handed to helper processes through environment variables or
/// argument lists, never interpolated into a shell script.
class DesktopFileOperationsService implements FileOperationsService {
  DesktopFileOperationsService({
    required NativeFileChannelService nativeChannel,
  }) : _nativeChannel = nativeChannel;

  final NativeFileChannelService _nativeChannel;

  @override
  bool get canShare => Platform.isMacOS;

  @override
  Future<bool> share(List<String> paths, ShareAnchor anchor) async {
    if (!canShare || paths.isEmpty) {
      return false;
    }
    return _nativeChannel.shareFiles(
      paths,
      left: anchor.left,
      top: anchor.top,
      width: anchor.width,
      height: anchor.height,
    );
  }

  @override
  Future<bool> moveToTrash(String path) async {
    try {
      if (Platform.isMacOS) {
        return await _nativeChannel.moveToTrash(path);
      }
      if (Platform.isWindows) {
        return await _runPowerShell(
          'Add-Type -AssemblyName Microsoft.VisualBasic; '
          '[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('
          r"$env:OIV_PATH, 'OnlyErrorDialogs', 'SendToRecycleBin')",
          path,
        );
      }
      if (Platform.isLinux) {
        return await _run('gio', ['trash', '--', path]);
      }
    } catch (error) {
      debugPrint('Unable to move $path to the trash: $error');
    }
    return false;
  }

  @override
  Future<String> rename(String path, String newFileName) async {
    final name = newFileName.trim();
    if (!isValidFileName(name)) {
      throw const FileOperationException(FileOperationError.invalidName);
    }

    final source = File(path);
    if (!await source.exists()) {
      throw const FileOperationException(FileOperationError.notFound);
    }

    final target = p.join(p.dirname(path), name);
    if (target == path) {
      return path;
    }

    final isCaseOnlyChange = target.toLowerCase() == path.toLowerCase();
    if (!isCaseOnlyChange &&
        await FileSystemEntity.type(target) != FileSystemEntityType.notFound) {
      throw const FileOperationException(FileOperationError.alreadyExists);
    }

    try {
      return (await source.rename(target)).path;
    } on FileSystemException catch (error) {
      throw FileOperationException(FileOperationError.failed, error.message);
    }
  }

  @override
  Future<Map<String, String>> copyTo(
    List<String> paths,
    String destinationDirectory,
  ) async {
    final copied = <String, String>{};
    for (final path in paths) {
      try {
        final target = await _availableTarget(path, destinationDirectory);
        await File(path).copy(target);
        copied[path] = target;
      } catch (error) {
        debugPrint('Unable to copy $path: $error');
      }
    }
    return copied;
  }

  @override
  Future<Map<String, String>> moveTo(
    List<String> paths,
    String destinationDirectory,
  ) async {
    final moved = <String, String>{};
    for (final path in paths) {
      if (p.equals(p.dirname(path), destinationDirectory)) {
        continue;
      }
      try {
        final target = await _availableTarget(path, destinationDirectory);
        final source = File(path);
        try {
          await source.rename(target);
        } on FileSystemException {
          // Different volume: copy, then remove the original only once the
          // copy is complete.
          await source.copy(target);
          if (await File(target).length() != await source.length()) {
            throw const FileOperationException(FileOperationError.failed);
          }
          await source.delete();
        }
        moved[path] = target;
      } catch (error) {
        debugPrint('Unable to move $path: $error');
      }
    }
    return moved;
  }

  @override
  Future<bool> reveal(String path) async {
    try {
      if (Platform.isMacOS) {
        return await _nativeChannel.revealInFileManager(path);
      }
      if (Platform.isWindows) {
        // explorer.exe exits with 1 even when it succeeds.
        await Process.run('explorer.exe', ['/select,$path']);
        return true;
      }
      if (Platform.isLinux) {
        final shown = await _run('dbus-send', [
          '--session',
          '--dest=org.freedesktop.FileManager1',
          '--type=method_call',
          '/org/freedesktop/FileManager1',
          'org.freedesktop.FileManager1.ShowItems',
          'array:string:${Uri.file(path)}',
          'string:',
        ]);
        return shown || await _run('xdg-open', [p.dirname(path)]);
      }
    } catch (error) {
      debugPrint('Unable to reveal $path: $error');
    }
    return false;
  }

  @override
  Future<bool> copyImageToClipboard(String path) async {
    try {
      if (Platform.isMacOS) {
        return await _nativeChannel.copyImageToClipboard(path);
      }
      if (Platform.isWindows) {
        return await _runPowerShell(
          'Add-Type -AssemblyName System.Windows.Forms; '
          'Add-Type -AssemblyName System.Drawing; '
          r'$image = [System.Drawing.Image]::FromFile($env:OIV_PATH); '
          r'[System.Windows.Forms.Clipboard]::SetImage($image); '
          r'$image.Dispose()',
          path,
          sta: true,
        );
      }
      if (Platform.isLinux) {
        final mimeType = _mimeTypeFor(path);
        if (Platform.environment.containsKey('WAYLAND_DISPLAY')) {
          final process = await Process.start('wl-copy', ['--type', mimeType]);
          await process.stdin.addStream(File(path).openRead());
          await process.stdin.close();
          return await process.exitCode == 0;
        }
        return await _run('xclip', [
          '-selection',
          'clipboard',
          '-t',
          mimeType,
          '-i',
          path,
        ]);
      }
    } catch (error) {
      debugPrint('Unable to copy $path to the clipboard: $error');
    }
    return false;
  }

  @override
  Future<bool> openWith(String path, {required String prompt}) async {
    try {
      if (Platform.isMacOS) {
        return await _nativeChannel.openWith(path, prompt: prompt);
      }
      if (Platform.isWindows) {
        await Process.start('rundll32.exe', [
          'shell32.dll,OpenAs_RunDLL',
          path,
        ], mode: ProcessStartMode.detached);
        return true;
      }
      if (Platform.isLinux) {
        await Process.start('xdg-open', [
          path,
        ], mode: ProcessStartMode.detached);
        return true;
      }
    } catch (error) {
      debugPrint('Unable to open $path with another app: $error');
    }
    return false;
  }

  /// True when [name] can be used as a file name on every desktop platform.
  static bool isValidFileName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty &&
        trimmed != '.' &&
        trimmed != '..' &&
        !trimmed.startsWith('.') &&
        !RegExp(r'[\\/:*?"<>|\x00-\x1F]').hasMatch(trimmed);
  }

  /// A path for [sourcePath] inside [directory] that doesn't exist yet,
  /// adding " (2)", " (3)", … before the extension when needed.
  static Future<String> _availableTarget(
    String sourcePath,
    String directory,
  ) async {
    final base = p.basenameWithoutExtension(sourcePath);
    final extension = p.extension(sourcePath);
    var candidate = p.join(directory, '$base$extension');
    var counter = 2;
    while (await FileSystemEntity.type(candidate) !=
        FileSystemEntityType.notFound) {
      candidate = p.join(directory, '$base ($counter)$extension');
      counter += 1;
    }
    return candidate;
  }

  static String _mimeTypeFor(String path) {
    return switch (p.extension(path).toLowerCase()) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      '.bmp' => 'image/bmp',
      '.svg' => 'image/svg+xml',
      '.ico' => 'image/x-icon',
      _ => 'image/png',
    };
  }

  static Future<bool> _run(String executable, List<String> arguments) async {
    try {
      final result = await Process.run(executable, arguments);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  static Future<bool> _runPowerShell(
    String script,
    String path, {
    bool sta = false,
  }) async {
    final result = await Process.run(
      'powershell.exe',
      ['-NoProfile', '-NonInteractive', if (sta) '-STA', '-Command', script],
      environment: {'OIV_PATH': path},
    );
    return result.exitCode == 0;
  }
}
