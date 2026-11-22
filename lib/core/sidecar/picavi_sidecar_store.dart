import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Per-image entries as stored in a sidecar: file name → JSON fields.
typedef SidecarEntries = Map<String, Map<String, Object?>>;

/// Reads and writes the hidden `.picavi.json` file Picavi keeps in each
/// folder, much like Picasa's `.picasa.ini`. Several features share one
/// file (edits, stars, captions…), each owning its own fields of an entry:
///
/// ```json
/// {"version": 1, "images": {"IMG_0001.jpg": {"edits": [], "starred": true}}}
/// ```
///
/// Writes go through a temp file + rename and are serialised per folder
/// across the whole app, so features can't overwrite each other's changes.
class PicaviSidecarStore {
  const PicaviSidecarStore();

  static const String fileName = '.picavi.json';
  static const int _version = 1;

  static final Map<String, Future<void>> _pendingWrites = {};

  static String sidecarPathFor(String directory) => p.join(directory, fileName);

  /// Every entry in [directory]'s sidecar (empty if there is none or it is
  /// unreadable).
  Future<SidecarEntries> read(String directory) async {
    final file = File(sidecarPathFor(directory));
    try {
      if (!await file.exists()) {
        return {};
      }
      return parse(await file.readAsString());
    } catch (error) {
      debugPrint('Unable to read $fileName in $directory: $error');
      return {};
    }
  }

  /// Parses sidecar JSON text; tolerant of anything malformed.
  static SidecarEntries parse(String text) {
    try {
      final json = jsonDecode(text);
      final images = json is Map ? json['images'] : null;
      if (images is! Map) {
        return {};
      }
      return {
        for (final entry in images.entries)
          if (entry.key is String && entry.value is Map)
            entry.key as String: Map<String, Object?>.from(entry.value as Map),
      };
    } catch (_) {
      return {};
    }
  }

  /// Applies [change] to the entries of [directory] and writes the result.
  /// Entries left empty are dropped; with none left the file is deleted.
  /// Returns false when the sidecar couldn't be written.
  Future<bool> update(
    String directory,
    void Function(SidecarEntries entries) change,
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
    void Function(SidecarEntries entries) change,
  ) async {
    final file = File(sidecarPathFor(directory));
    final temporary = File('${file.path}.picavi-tmp');
    try {
      final entries = await read(directory);
      change(entries);
      entries.removeWhere((_, fields) => fields.isEmpty);
      if (entries.isEmpty) {
        if (await file.exists()) {
          await file.delete();
        }
        return true;
      }
      final names = entries.keys.toList()..sort();
      final json = {
        'version': _version,
        'images': {for (final name in names) name: entries[name]},
      };
      await temporary.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
        flush: true,
      );
      await temporary.rename(file.path);
      return true;
    } catch (error) {
      debugPrint('Unable to write $fileName in $directory: $error');
      try {
        if (await temporary.exists()) {
          await temporary.delete();
        }
      } catch (_) {}
      return false;
    }
  }

  /// Moves the [keys] of [from]'s entry to [to] (another folder or name).
  Future<void> moveFields(String from, String to, Set<String> keys) async {
    final fields = await _takeFields(from, keys, remove: true);
    if (fields.isNotEmpty) {
      await _putFields(to, fields);
    }
  }

  /// Copies the [keys] of [from]'s entry to [to].
  Future<void> copyFields(String from, String to, Set<String> keys) async {
    final fields = await _takeFields(from, keys, remove: false);
    if (fields.isNotEmpty) {
      await _putFields(to, fields);
    }
  }

  Future<Map<String, Object?>> _takeFields(
    String path,
    Set<String> keys, {
    required bool remove,
  }) async {
    final entry = (await read(p.dirname(path)))[p.basename(path)] ?? {};
    final fields = {
      for (final key in keys)
        if (entry.containsKey(key)) key: entry[key],
    };
    if (remove && fields.isNotEmpty) {
      await update(p.dirname(path), (entries) {
        entries[p.basename(path)]?.removeWhere((key, _) => keys.contains(key));
      });
    }
    return fields;
  }

  Future<void> _putFields(String path, Map<String, Object?> fields) {
    return update(p.dirname(path), (entries) {
      (entries[p.basename(path)] ??= {}).addAll(fields);
    });
  }
}
