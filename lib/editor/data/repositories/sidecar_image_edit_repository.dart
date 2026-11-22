import 'package:path/path.dart' as p;

import '../../../core/sidecar/picavi_sidecar_store.dart';
import '../../domain/entities/image_edits.dart';
import '../../domain/repositories/image_edit_repository.dart';

/// Keeps edits in the `edits` field of each image's entry in the folder's
/// `.picavi.json`. The images themselves are never touched.
class SidecarImageEditRepository implements ImageEditRepository {
  SidecarImageEditRepository({this.store = const PicaviSidecarStore()});

  static const String fileName = PicaviSidecarStore.fileName;
  static const String _field = 'edits';

  final PicaviSidecarStore store;

  @override
  Future<Map<String, ImageEdits>> loadDirectory(String directory) async {
    final entries = await store.read(directory);
    final result = <String, ImageEdits>{};
    for (final MapEntry(key: name, value: fields) in entries.entries) {
      final edits = ImageEdits.fromJson(fields[_field]);
      if (edits.isNotEmpty) {
        result[p.join(directory, name)] = edits;
      }
    }
    return result;
  }

  @override
  Future<ImageEdits> load(String imagePath) async {
    final entries = await store.read(p.dirname(imagePath));
    return ImageEdits.fromJson(entries[p.basename(imagePath)]?[_field]);
  }

  @override
  Future<bool> save(String imagePath, ImageEdits edits) {
    return store.update(p.dirname(imagePath), (entries) {
      final name = p.basename(imagePath);
      if (edits.isEmpty) {
        entries[name]?.remove(_field);
      } else {
        (entries[name] ??= {})[_field] = edits.toJson();
      }
    });
  }

  @override
  Future<void> move(String from, String to) =>
      store.moveFields(from, to, const {_field});

  @override
  Future<void> copy(String from, String to) =>
      store.copyFields(from, to, const {_field});
}
