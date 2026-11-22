import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/catalog_image.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/services/duplicate_finder.dart';

/// Only files that share a size can be identical, so just those are read,
/// and hashed (SHA-1) in a background isolate.
class HashingDuplicateFinder implements DuplicateFinder {
  const HashingDuplicateFinder(this._catalog, {this.batchSize = 50});

  final CatalogRepository _catalog;
  final int batchSize;

  @override
  Future<List<List<CatalogImage>>> find({
    void Function(int checked, int total)? onProgress,
  }) async {
    final candidates = await _catalog.sameSizeCandidates();
    final hashes = <String, String>{};
    onProgress?.call(0, candidates.length);
    for (var start = 0; start < candidates.length; start += batchSize) {
      final paths = [
        for (final image in candidates.sublist(
          start,
          math.min(start + batchSize, candidates.length),
        ))
          image.path,
      ];
      hashes.addAll(await Isolate.run(() => hashFiles(paths)));
      onProgress?.call(
        math.min(start + batchSize, candidates.length),
        candidates.length,
      );
    }

    final groups = <String, List<CatalogImage>>{};
    for (final image in candidates) {
      final hash = hashes[image.path];
      if (hash != null) {
        (groups['${image.stamp.size}:$hash'] ??= []).add(image);
      }
    }
    return groups.values.where((group) => group.length > 1).toList()
      ..sort((a, b) => b.first.stamp.size.compareTo(a.first.stamp.size));
  }
}

/// SHA-1 of each readable file. Runs in an isolate.
@visibleForTesting
Future<Map<String, String>> hashFiles(List<String> paths) async {
  final result = <String, String>{};
  for (final path in paths) {
    try {
      result[path] = (await sha1.bind(File(path).openRead()).first).toString();
    } catch (_) {
      // Missing or unreadable: can't be compared.
    }
  }
  return result;
}
