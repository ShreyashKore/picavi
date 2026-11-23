import 'package:path/path.dart' as p;

import '../../../core/sidecar/picavi_sidecar_store.dart';
import '../../domain/entities/face.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/photo_info.dart';
import '../../domain/repositories/photo_info_repository.dart';

/// Keeps [PhotoInfo] in the `starred`, `caption`, `tags` and `hidden` fields
/// of each image's entry in the folder's `.picavi.json`.
class SidecarPhotoInfoRepository implements PhotoInfoRepository {
  const SidecarPhotoInfoRepository({this.store = const PicaviSidecarStore()});

  static const Set<String> fields = {
    'starred',
    'caption',
    'tags',
    'hidden',
    'location',
    'people',
  };

  final PicaviSidecarStore store;

  /// Reads [PhotoInfo] from one sidecar entry.
  static PhotoInfo fromFields(Map<String, Object?>? entry) {
    if (entry == null) {
      return PhotoInfo.none;
    }
    final tags = entry['tags'];
    final caption = entry['caption'];
    return PhotoInfo(
      starred: entry['starred'] == true,
      caption: caption is String ? caption : '',
      tags: tags is List ? tags.whereType<String>().toList() : const [],
      hidden: entry['hidden'] == true,
      location: GeoPoint.fromJson(entry['location']),
      people: entry['people'] is List
          ? (entry['people'] as List)
                .map(PersonTag.fromJson)
                .whereType<PersonTag>()
                .toList()
          : const [],
    );
  }

  @override
  Future<Map<String, PhotoInfo>> loadDirectory(String directory) async {
    final entries = await store.read(directory);
    return {
      for (final MapEntry(key: name, value: entry) in entries.entries)
        if (!fromFields(entry).isEmpty)
          p.join(directory, name): fromFields(entry),
    };
  }

  @override
  Future<PhotoInfo> load(String imagePath) async {
    final entries = await store.read(p.dirname(imagePath));
    return fromFields(entries[p.basename(imagePath)]);
  }

  @override
  Future<bool> save(String imagePath, PhotoInfo info) {
    return store.update(p.dirname(imagePath), (entries) {
      final entry = entries[p.basename(imagePath)] ??= {};
      entry.removeWhere((key, _) => fields.contains(key));
      if (info.starred) entry['starred'] = true;
      if (info.caption.isNotEmpty) entry['caption'] = info.caption;
      if (info.tags.isNotEmpty) entry['tags'] = info.tags;
      if (info.hidden) entry['hidden'] = true;
      if (info.location != null) entry['location'] = info.location!.toJson();
      if (info.people.isNotEmpty) {
        entry['people'] = [for (final tag in info.people) tag.toJson()];
      }
    });
  }

  @override
  Future<void> move(String from, String to) =>
      store.moveFields(from, to, fields);

  @override
  Future<void> copy(String from, String to) =>
      store.copyFields(from, to, fields);
}
