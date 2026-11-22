import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/image_edits.dart';
import '../../domain/repositories/image_edit_repository.dart';

/// Keeps edits in a hidden `.picavi.json` file in each folder, much like
/// Picasa's `.picasa.ini`. The images themselves are never touched.
///
/// ```json
/// {"version": 1, "images": {"IMG_0001.jpg": {"edits": [ ... ]}}}
/// ```
class SidecarImageEditRepository implements ImageEditRepository {
  static const String fileName = '.picavi.json';
  static const int _version = 1;

  /// Writes to one folder's sidecar are serialised so they can't interleave.
  final Map<String, Future<void>> _pendingWrites = {};

  @override
  Future<Map<String, ImageEdits>> loadDirectory(String directory) async {
    final entries = await _readImages(directory);
    return {
      for (final entry in entries.entries)
        p.join(directory, entry.key): entry.value,
    };
  }

  @override
  Future<ImageEdits> load(String imagePath) async {
    final entries = await _readImages(p.dirname(imagePath));
    return entries[p.basename(imagePath)] ?? ImageEdits.none;
  }

  @override
  Future<bool> save(String imagePath, ImageEdits edits) {
    return _update(p.dirname(imagePath), (images) {
      final name = p.basename(imagePath);
      if (edits.isEmpty) {
        images.remove(name);
      } else {
        images[name] = edits;
      }
    });
  }

  @override
  Future<void> move(String from, String to) async {
    final edits = await load(from);
    if (edits.isEmpty) {
      return;
    }
    await save(to, edits);
    if (!p.equals(p.dirname(from), p.dirname(to)) ||
        p.basename(from) != p.basename(to)) {
      await save(from, ImageEdits.none);
    }
  }

  @override
  Future<void> copy(String from, String to) async {
    final edits = await load(from);
    if (edits.isNotEmpty) {
      await save(to, edits);
    }
  }

  Future<Map<String, ImageEdits>> _readImages(String directory) async {
    final file = File(p.join(directory, fileName));
    try {
      if (!await file.exists()) {
        return {};
      }
      final json = jsonDecode(await file.readAsString());
      final images = json is Map ? json['images'] : null;
      if (images is! Map) {
        return {};
      }
      final result = <String, ImageEdits>{};
      for (final entry in images.entries) {
        final value = entry.value;
        final edits = ImageEdits.fromJson(value is Map ? value['edits'] : null);
        if (entry.key is String && edits.isNotEmpty) {
          result[entry.key as String] = edits;
        }
      }
      return result;
    } catch (error) {
      debugPrint('Unable to read edits in $directory: $error');
      return {};
    }
  }

  Future<bool> _update(
    String directory,
    void Function(Map<String, ImageEdits> images) change,
  ) {
    final previous = _pendingWrites[directory] ?? Future<void>.value();
    final completer = Completer<bool>();
    final next = previous.then((_) async {
      completer.complete(await _write(directory, change));
    });
    _pendingWrites[directory] = next;
    unawaited(
      next.whenComplete(() {
        if (identical(_pendingWrites[directory], next)) {
          _pendingWrites.remove(directory);
        }
      }),
    );
    return completer.future;
  }

  Future<bool> _write(
    String directory,
    void Function(Map<String, ImageEdits> images) change,
  ) async {
    final file = File(p.join(directory, fileName));
    final temporary = File(p.join(directory, '$fileName.picavi-tmp'));
    try {
      final images = await _readImages(directory);
      change(images);
      if (images.isEmpty) {
        if (await file.exists()) {
          await file.delete();
        }
        return true;
      }
      final sortedNames = images.keys.toList()..sort();
      final json = {
        'version': _version,
        'images': {
          for (final name in sortedNames)
            name: {'edits': images[name]!.toJson()},
        },
      };
      await temporary.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
        flush: true,
      );
      await temporary.rename(file.path);
      return true;
    } catch (error) {
      debugPrint('Unable to save edits in $directory: $error');
      try {
        if (await temporary.exists()) {
          await temporary.delete();
        }
      } catch (_) {}
      return false;
    }
  }
}
