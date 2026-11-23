import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../viewer/data/platform_image_formats.dart';
import '../../domain/entities/import_models.dart';
import '../../domain/services/import_service.dart';
import 'file_system_library_indexer.dart';

class FileSystemImportService implements ImportService {
  FileSystemImportService({
    List<String> Function()? volumeRoots,
    Set<String>? extensions,
  }) : _volumeRoots = volumeRoots ?? defaultVolumeRoots,
       _extensions = extensions ?? platformImageExtensions;

  final List<String> Function() _volumeRoots;
  final Set<String> _extensions;

  /// Folders whose sub-folders are mounted volumes on this platform.
  static List<String> defaultVolumeRoots() {
    if (Platform.isMacOS) {
      return ['/Volumes'];
    }
    if (Platform.isLinux) {
      final user = Platform.environment['USER'] ?? '';
      return ['/media/$user', '/run/media/$user', '/media', '/mnt'];
    }
    return const [];
  }

  /// The user's Pictures folder, where imports go by default.
  static String defaultDestination() {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    return home == null ? Directory.current.path : p.join(home, 'Pictures');
  }

  @override
  Future<List<ImportSource>> findSources() async {
    final candidates = <String>[];
    if (Platform.isWindows && _volumeRoots == defaultVolumeRoots) {
      for (
        var letter = 'D'.codeUnitAt(0);
        letter <= 'Z'.codeUnitAt(0);
        letter++
      ) {
        candidates.add('${String.fromCharCode(letter)}:\\');
      }
    } else {
      for (final root in _volumeRoots()) {
        try {
          for (final entity in Directory(root).listSync(followLinks: false)) {
            // On macOS the startup disk shows up as a link to "/".
            if (entity is Directory) {
              candidates.add(entity.path);
            }
          }
        } catch (_) {}
      }
    }

    final sources = <ImportSource>[];
    final seen = <String>{};
    for (final path in candidates) {
      try {
        if (await Directory(p.join(path, 'DCIM')).exists() && seen.add(path)) {
          sources.add(ImportSource(path: path, name: p.basename(path)));
        }
      } catch (_) {}
    }
    return sources;
  }

  @override
  Future<List<ImportCandidate>> scan(
    String sourcePath,
    String destinationRoot,
  ) async {
    final dcim = p.join(sourcePath, 'DCIM');
    final root = await Directory(dcim).exists() ? dcim : sourcePath;
    final extensions = _extensions;
    final files = (await Isolate.run(
      () => scanLibraryRoot(root, extensions),
    )).files;
    final paths = [for (final file in files) file.path];
    final facts = paths.isEmpty
        ? const <String, PhotoFacts>{}
        : await Isolate.run(() => readPhotoFacts(paths));

    final candidates = <ImportCandidate>[];
    for (final file in files) {
      final candidate = ImportCandidate(
        path: file.path,
        stamp: file.stamp,
        taken: facts[file.path]?.taken,
      );
      final target = File(
        p.join(
          destinationFolder(candidate, destinationRoot),
          p.basename(file.path),
        ),
      );
      var imported = false;
      try {
        imported =
            await target.exists() && await target.length() == file.stamp.size;
      } catch (_) {}
      candidates.add(
        ImportCandidate(
          path: file.path,
          stamp: file.stamp,
          taken: candidate.taken,
          alreadyImported: imported,
        ),
      );
    }
    candidates.sort((a, b) {
      final order = a.date.compareTo(b.date);
      return order != 0 ? order : a.path.compareTo(b.path);
    });
    return candidates;
  }

  @override
  String destinationFolder(ImportCandidate candidate, String destinationRoot) {
    final date = candidate.date;
    String two(int value) => value.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return p.join(
      destinationRoot,
      year,
      '$year-${two(date.month)}-${two(date.day)}',
    );
  }

  @override
  Stream<ImportProgress> import(
    List<ImportCandidate> candidates,
    String destinationRoot,
  ) async* {
    var copied = 0;
    var skipped = 0;
    var failed = 0;
    ImportProgress progress({bool done = false}) => ImportProgress(
      copied: copied,
      skipped: skipped,
      failed: failed,
      total: candidates.length,
      done: done,
    );

    yield progress();
    for (final candidate in candidates) {
      try {
        final folder = destinationFolder(candidate, destinationRoot);
        await Directory(folder).create(recursive: true);
        final name = p.basename(candidate.path);
        final existing = File(p.join(folder, name));
        if (await existing.exists() &&
            await existing.length() == candidate.stamp.size) {
          skipped += 1;
        } else {
          final target = await _available(folder, name);
          final temporary = File(p.join(folder, '.$name.picavi-tmp'));
          await File(candidate.path).copy(temporary.path);
          await temporary.rename(target);
          // Keep the camera's timestamp so "date modified" stays meaningful.
          await File(target).setLastModified(
            DateTime.fromMillisecondsSinceEpoch(candidate.stamp.modifiedMs),
          );
          copied += 1;
        }
      } catch (error) {
        debugPrint('Unable to import ${candidate.path}: $error');
        failed += 1;
      }
      yield progress();
    }
    yield progress(done: true);
  }

  static Future<String> _available(String folder, String name) async {
    final base = p.basenameWithoutExtension(name);
    final extension = p.extension(name);
    var candidate = p.join(folder, name);
    var counter = 2;
    while (await FileSystemEntity.type(candidate) !=
        FileSystemEntityType.notFound) {
      candidate = p.join(folder, '$base ($counter)$extension');
      counter += 1;
    }
    return candidate;
  }
}
