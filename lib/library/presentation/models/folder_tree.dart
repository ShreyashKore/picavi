import 'package:path/path.dart' as p;

import '../../domain/entities/catalog_image.dart';

/// One row of the folder sidebar.
class FolderNode {
  const FolderNode({
    required this.path,
    required this.depth,
    required this.imageCount,
    required this.isRoot,
    required this.isHidden,
  });

  final String path;

  /// 0 for a watched folder, 1 for its sub-folders, …
  final int depth;

  /// Photos directly in this folder (0 for folders that only hold others).
  final int imageCount;
  final bool isRoot;
  final bool isHidden;

  String get name => isRoot ? path : p.basename(path);
}

/// Each watched folder followed by its sub-folders that hold photos (and
/// the folders in between), depth-first, alphabetical.
List<FolderNode> buildFolderTree(
  List<String> roots,
  List<CatalogFolder> folders,
  Set<String> hiddenFolders,
) {
  final counts = {for (final folder in folders) folder.path: folder.imageCount};
  final nodes = <FolderNode>[];
  for (final root in [...roots]..sort()) {
    final paths = <String>{root};
    for (final folder in counts.keys) {
      if (!p.isWithin(root, folder)) {
        continue;
      }
      var current = folder;
      while (!p.equals(current, root) && paths.add(current)) {
        current = p.dirname(current);
      }
    }
    final ordered = paths.toList()
      ..sort((a, b) {
        final left = p.split(p.relative(a, from: root));
        final right = p.split(p.relative(b, from: root));
        for (var i = 0; i < left.length && i < right.length; i++) {
          final order = left[i].toLowerCase().compareTo(right[i].toLowerCase());
          if (order != 0) {
            return order;
          }
        }
        return left.length.compareTo(right.length);
      });
    for (final path in ordered) {
      final isRoot = p.equals(path, root);
      nodes.add(
        FolderNode(
          path: path,
          depth: isRoot ? 0 : p.split(p.relative(path, from: root)).length,
          imageCount: counts[path] ?? 0,
          isRoot: isRoot,
          isHidden: hiddenFolders.contains(path),
        ),
      );
    }
  }
  return nodes;
}
