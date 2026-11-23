import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/sidecar/picavi_sidecar_store.dart';
import '../../../editor/domain/entities/image_edits.dart';
import '../../../viewer/data/platform_image_formats.dart';
import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/library_query.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/services/library_indexer.dart';
import '../repositories/sidecar_photo_info_repository.dart';

/// Walks the watched folders in background isolates. Unchanged photos keep
/// what was read before; new or changed ones get their EXIF date and camera
/// read (from the start of the file only). Stars, captions, tags and edits
/// come from each folder's sidecar.
class FileSystemLibraryIndexer implements LibraryIndexer {
  FileSystemLibraryIndexer(
    this._catalog, {
    Set<String>? extensions,
    this.batchSize = 200,
  }) : _extensions = extensions ?? platformImageExtensions;

  final CatalogRepository _catalog;
  final Set<String> _extensions;
  final int batchSize;

  /// [roots] without duplicates or folders inside another root.
  static List<String> normalizeRoots(List<String> roots) {
    final sorted = roots.map(p.normalize).toSet().toList()
      ..sort((a, b) => a.length.compareTo(b.length));
    final result = <String>[];
    for (final root in sorted) {
      if (!result.any(
        (kept) => p.equals(kept, root) || p.isWithin(kept, root),
      )) {
        result.add(root);
      }
    }
    return result..sort();
  }

  @override
  Stream<IndexProgress> index(List<String> roots) async* {
    final normalized = normalizeRoots(roots);
    await _catalog.removeOutside(normalized);
    var found = 0;
    var processed = 0;
    yield IndexProgress(found: found, processed: processed);

    for (final root in normalized) {
      final extensions = _extensions;
      final scan = await Isolate.run(() => scanLibraryRoot(root, extensions));
      found += scan.files.length;
      yield IndexProgress(found: found, processed: processed);

      final existing = await _catalog.imagesUnder(root);
      final present = {for (final file in scan.files) file.path};
      await _catalog.remove(
        existing.keys.where((path) => !present.contains(path)),
      );

      for (var start = 0; start < scan.files.length; start += batchSize) {
        final batch = scan.files.sublist(
          start,
          math.min(start + batchSize, scan.files.length),
        );
        final changed = [
          for (final file in batch)
            if (existing[file.path]?.stamp != file.stamp) file.path,
        ];
        final facts = changed.isEmpty
            ? const <String, PhotoFacts>{}
            : await Isolate.run(() => readPhotoFacts(changed));

        await _catalog.upsert([
          for (final file in batch)
            _catalogImage(file, existing[file.path], facts[file.path], scan),
        ]);
        processed += batch.length;
        yield IndexProgress(found: found, processed: processed);
      }
    }
    yield IndexProgress(found: found, processed: processed, done: true);
  }

  static CatalogImage _catalogImage(
    ScannedFile file,
    CatalogImage? previous,
    PhotoFacts? facts,
    LibraryScan scan,
  ) {
    final folder = p.dirname(file.path);
    final name = p.basename(file.path);
    final entry = scan.sidecars[folder]?[name];
    final reuse = facts == null && previous != null;
    return CatalogImage(
      path: file.path,
      folder: folder,
      name: name,
      stamp: file.stamp,
      taken: reuse ? previous.taken : facts?.taken,
      camera: reuse ? previous.camera : facts?.camera,
      info: SidecarPhotoInfoRepository.fromFields(entry),
      edits: ImageEdits.fromJson(entry?['edits']),
    );
  }
}

class ScannedFile {
  const ScannedFile(this.path, this.stamp);

  final String path;
  final FileStamp stamp;
}

class LibraryScan {
  const LibraryScan(this.files, this.sidecars);

  final List<ScannedFile> files;

  /// Parsed `.picavi.json` entries by folder.
  final Map<String, SidecarEntries> sidecars;
}

/// Lists every photo under [root], skipping hidden folders and following no
/// links. Unreadable folders are skipped. Runs in an isolate.
LibraryScan scanLibraryRoot(String root, Set<String> extensions) {
  final files = <ScannedFile>[];
  final sidecars = <String, SidecarEntries>{};
  final pending = [root];
  while (pending.isNotEmpty) {
    final directory = pending.removeLast();
    List<FileSystemEntity> entries;
    try {
      entries = Directory(directory).listSync(followLinks: false);
    } catch (_) {
      continue;
    }
    for (final entity in entries) {
      final name = p.basename(entity.path);
      if (entity is Directory) {
        if (!name.startsWith('.')) {
          pending.add(entity.path);
        }
        continue;
      }
      if (entity is! File) {
        continue;
      }
      if (name == PicaviSidecarStore.fileName) {
        try {
          sidecars[directory] = PicaviSidecarStore.parse(
            entity.readAsStringSync(),
          );
        } catch (_) {}
        continue;
      }
      if (name.startsWith('.') ||
          !extensions.contains(p.extension(name).toLowerCase())) {
        continue;
      }
      try {
        final stat = entity.statSync();
        files.add(
          ScannedFile(
            entity.path,
            FileStamp(stat.size, stat.modified.millisecondsSinceEpoch),
          ),
        );
      } catch (_) {}
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return LibraryScan(files, sidecars);
}

class PhotoFacts {
  const PhotoFacts({this.taken, this.camera});

  final DateTime? taken;
  final String? camera;
}

/// Reads when each photo was taken and with what camera. Only the first
/// 256 KB are read: that is where JPEG and TIFF keep their EXIF.
Future<Map<String, PhotoFacts>> readPhotoFacts(List<String> paths) async {
  const headBytes = 256 * 1024;
  final result = <String, PhotoFacts>{};
  for (final path in paths) {
    final extension = p.extension(path).toLowerCase();
    if (extension == '.svg' || extension == '.gif' || extension == '.ico') {
      continue;
    }
    RandomAccessFile? file;
    try {
      file = await File(path).open();
      final bytes = await file.read(headBytes);
      final tags = await readExifFromBytes(bytes);
      String? value(String key) {
        final text = tags[key]?.printable.trim();
        return text == null || text.isEmpty ? null : text;
      }

      final make = value('Image Make');
      final model = value('Image Model');
      final camera = [
        if (make != null && !(model?.startsWith(make) ?? false)) make,
        ?model,
      ].join(' ');
      result[path] = PhotoFacts(
        taken: parseExifDate(
          value('EXIF DateTimeOriginal') ??
              value('EXIF DateTimeDigitized') ??
              value('Image DateTime'),
        ),
        camera: camera.isEmpty ? null : camera,
      );
    } catch (_) {
      // No readable EXIF: the timeline falls back to the file date.
    } finally {
      await file?.close();
    }
  }
  return result;
}

/// Parses EXIF's `2019:07:14 18:02:11`.
@visibleForTesting
DateTime? parseExifDate(String? raw) {
  if (raw == null) {
    return null;
  }
  final match = RegExp(
    r'^(\d{4}):(\d{2}):(\d{2})[ T](\d{2}):(\d{2}):(\d{2})',
  ).firstMatch(raw);
  if (match == null) {
    return null;
  }
  final parts = [for (var i = 1; i <= 6; i++) int.parse(match.group(i)!)];
  if (parts[0] < 1800 || parts[1] == 0 || parts[2] == 0) {
    return null; // "0000:00:00 00:00:00" means unknown.
  }
  return DateTime(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]);
}
