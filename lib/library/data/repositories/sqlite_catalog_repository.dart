import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../../../editor/domain/entities/image_edits.dart';
import '../../domain/entities/catalog_image.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/library_query.dart';
import '../../domain/entities/photo_info.dart';
import '../../domain/repositories/catalog_repository.dart';

/// The catalog in a local SQLite database. Photo rows are a cache of what
/// is on disk (and in the sidecars) and can be rebuilt by re-indexing;
/// albums exist only here.
class SqliteCatalogRepository implements CatalogRepository {
  SqliteCatalogRepository._(this._db) {
    _migrate();
  }

  /// Opens (creating if needed) the catalog at [path]. A corrupt file is
  /// set aside and a fresh catalog started, since photos can be re-indexed.
  factory SqliteCatalogRepository.open(String path) {
    Directory(p.dirname(path)).createSync(recursive: true);
    try {
      return SqliteCatalogRepository._(sqlite3.open(path));
    } catch (error) {
      debugPrint('Catalog at $path is unusable, starting over: $error');
      final broken = File(path);
      if (broken.existsSync()) {
        broken.renameSync('$path.broken');
      }
      return SqliteCatalogRepository._(sqlite3.open(path));
    }
  }

  factory SqliteCatalogRepository.inMemory() =>
      SqliteCatalogRepository._(sqlite3.openInMemory());

  static const int _schemaVersion = 2;

  final Database _db;

  void _migrate() {
    _db.execute('PRAGMA foreign_keys = ON');
    _db.execute('PRAGMA journal_mode = WAL');
    final version = _db.select('PRAGMA user_version').first.columnAt(0) as int;
    if (version >= _schemaVersion) {
      return;
    }
    if (version < 1) {
      _createVersion1();
    }
    if (version < 2) {
      // Version 2: where photos were taken (camera GPS, and set by hand).
      _db.execute('''
        ALTER TABLE images ADD COLUMN gps_lat REAL;
        ALTER TABLE images ADD COLUMN gps_lon REAL;
        ALTER TABLE images ADD COLUMN loc_lat REAL;
        ALTER TABLE images ADD COLUMN loc_lon REAL;
        CREATE INDEX IF NOT EXISTS images_place ON images(
          COALESCE(loc_lat, gps_lat), COALESCE(loc_lon, gps_lon));
      ''');
    }
    _db.execute('PRAGMA user_version = $_schemaVersion');
  }

  void _createVersion1() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS images (
        path TEXT PRIMARY KEY,
        folder TEXT NOT NULL,
        name TEXT NOT NULL,
        size INTEGER NOT NULL,
        modified INTEGER NOT NULL,
        taken INTEGER,
        camera TEXT,
        starred INTEGER NOT NULL DEFAULT 0,
        caption TEXT NOT NULL DEFAULT '',
        tags TEXT NOT NULL DEFAULT '[]',
        hidden INTEGER NOT NULL DEFAULT 0,
        edits TEXT NOT NULL DEFAULT '[]',
        search TEXT NOT NULL DEFAULT ''
      );
      CREATE INDEX IF NOT EXISTS images_folder ON images(folder);
      CREATE INDEX IF NOT EXISTS images_date ON images(COALESCE(taken, modified));
      CREATE INDEX IF NOT EXISTS images_size ON images(size);
      CREATE TABLE IF NOT EXISTS albums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created INTEGER NOT NULL
      );
      CREATE TABLE IF NOT EXISTS album_items (
        album_id INTEGER NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
        path TEXT NOT NULL,
        position INTEGER NOT NULL,
        PRIMARY KEY (album_id, path)
      );
    ''');
  }

  // -------------------------------------------------------------------------
  // Photos

  @override
  Future<Map<String, CatalogImage>> imagesUnder(String root) async {
    final rows = _db.select(
      'SELECT * FROM images WHERE folder = ? OR folder LIKE ? ESCAPE ?',
      [root, '${_escapeLike(root)}${p.separator}%', r'\'],
    );
    return {for (final row in rows) row['path'] as String: _fromRow(row)};
  }

  @override
  Future<void> upsert(List<CatalogImage> images) async {
    if (images.isEmpty) {
      return;
    }
    final statement = _db.prepare('''
      INSERT INTO images (path, folder, name, size, modified, taken, camera,
        starred, caption, tags, hidden, edits, search,
        gps_lat, gps_lon, loc_lat, loc_lon)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(path) DO UPDATE SET
        folder = excluded.folder, name = excluded.name, size = excluded.size,
        modified = excluded.modified, taken = excluded.taken,
        camera = excluded.camera, starred = excluded.starred,
        caption = excluded.caption, tags = excluded.tags,
        hidden = excluded.hidden, edits = excluded.edits,
        search = excluded.search, gps_lat = excluded.gps_lat,
        gps_lon = excluded.gps_lon, loc_lat = excluded.loc_lat,
        loc_lon = excluded.loc_lon
    ''');
    _transaction(() {
      for (final image in images) {
        statement.execute([
          image.path,
          image.folder,
          image.name,
          image.stamp.size,
          image.stamp.modifiedMs,
          image.taken?.millisecondsSinceEpoch,
          image.camera,
          image.info.starred ? 1 : 0,
          image.info.caption,
          jsonEncode(image.info.tags),
          image.info.hidden ? 1 : 0,
          jsonEncode(image.edits.toJson()),
          _searchText(image),
          image.gps?.latitude,
          image.gps?.longitude,
          image.info.location?.latitude,
          image.info.location?.longitude,
        ]);
      }
    });
    statement.close();
  }

  @override
  Future<void> remove(Iterable<String> paths) async {
    final statement = _db.prepare('DELETE FROM images WHERE path = ?');
    _transaction(() {
      for (final path in paths) {
        statement.execute([path]);
      }
    });
    statement.close();
  }

  @override
  Future<void> removeOutside(List<String> roots) async {
    if (roots.isEmpty) {
      _db.execute('DELETE FROM images');
      return;
    }
    final conditions = [
      for (final _ in roots) "(folder = ? OR folder LIKE ? ESCAPE '\\')",
    ].join(' OR ');
    _db.execute('DELETE FROM images WHERE NOT ($conditions)', [
      for (final root in roots) ...[
        root,
        '${_escapeLike(root)}${p.separator}%',
      ],
    ]);
  }

  @override
  Future<List<CatalogFolder>> folders(LibraryQuery query) async {
    final (where, arguments) = _filters(query.copyForFolders());
    final rows = _db.select(
      'SELECT folder, COUNT(*) AS count FROM images $where '
      'GROUP BY folder ORDER BY folder',
      arguments,
    );
    return [
      for (final row in rows)
        CatalogFolder(
          path: row['folder'] as String,
          imageCount: row['count'] as int,
        ),
    ];
  }

  @override
  Future<List<CatalogImage>> search(LibraryQuery query) async {
    final (where, arguments) = _filters(query);
    final order = query.albumId != null
        ? 'ORDER BY (SELECT position FROM album_items '
              'WHERE album_id = ${query.albumId} AND path = images.path)'
        : query.folder != null
        ? 'ORDER BY name COLLATE NOCASE'
        : 'ORDER BY COALESCE(taken, modified) DESC, path';
    return [
      for (final row in _db.select(
        'SELECT * FROM images $where $order',
        arguments,
      ))
        _fromRow(row),
    ];
  }

  @override
  Future<CatalogImage?> image(String path) async {
    final rows = _db.select('SELECT * FROM images WHERE path = ?', [path]);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<void> updateInfo(String path, PhotoInfo info) async {
    final existing = await image(path);
    if (existing != null) {
      await upsert([existing.copyWith(info: info)]);
    }
  }

  @override
  Future<void> updateEdits(String path, ImageEdits edits) async {
    final existing = await image(path);
    if (existing != null) {
      await upsert([existing.copyWith(edits: edits)]);
    }
  }

  @override
  Future<List<CatalogImage>> sameSizeCandidates() async {
    return [
      for (final row in _db.select('''
        SELECT * FROM images WHERE size IN
          (SELECT size FROM images GROUP BY size HAVING COUNT(*) > 1)
        ORDER BY size, path
      '''))
        _fromRow(row),
    ];
  }

  // -------------------------------------------------------------------------
  // Albums

  @override
  Future<List<Album>> albums() async {
    final rows = _db.select('''
      SELECT a.id, a.name,
        (SELECT COUNT(*) FROM album_items i JOIN images m ON m.path = i.path
          WHERE i.album_id = a.id) AS count,
        (SELECT i.path FROM album_items i JOIN images m ON m.path = i.path
          WHERE i.album_id = a.id ORDER BY i.position LIMIT 1) AS cover
      FROM albums a ORDER BY a.name COLLATE NOCASE, a.id
    ''');
    return [
      for (final row in rows)
        Album(
          id: row['id'] as int,
          name: row['name'] as String,
          imageCount: row['count'] as int,
          coverPath: row['cover'] as String?,
        ),
    ];
  }

  @override
  Future<Album> createAlbum(String name) async {
    _db.execute('INSERT INTO albums (name, created) VALUES (?, ?)', [
      name,
      DateTime.now().millisecondsSinceEpoch,
    ]);
    return Album(id: _db.lastInsertRowId, name: name);
  }

  @override
  Future<void> renameAlbum(int id, String name) async {
    _db.execute('UPDATE albums SET name = ? WHERE id = ?', [name, id]);
  }

  @override
  Future<void> deleteAlbum(int id) async {
    _db.execute('DELETE FROM albums WHERE id = ?', [id]);
  }

  @override
  Future<void> addToAlbum(int id, List<String> paths) async {
    final next =
        (_db
                .select(
                  'SELECT COALESCE(MAX(position), -1) + 1 FROM album_items '
                  'WHERE album_id = ?',
                  [id],
                )
                .first
                .columnAt(0)
            as int);
    final statement = _db.prepare(
      'INSERT OR IGNORE INTO album_items (album_id, path, position) '
      'VALUES (?, ?, ?)',
    );
    _transaction(() {
      for (var i = 0; i < paths.length; i++) {
        statement.execute([id, paths[i], next + i]);
      }
    });
    statement.close();
  }

  @override
  Future<void> removeFromAlbum(int id, List<String> paths) async {
    final statement = _db.prepare(
      'DELETE FROM album_items WHERE album_id = ? AND path = ?',
    );
    _transaction(() {
      for (final path in paths) {
        statement.execute([id, path]);
      }
    });
    statement.close();
  }

  @override
  Future<void> close() async {
    _db.close();
  }

  // -------------------------------------------------------------------------

  void _transaction(void Function() body) {
    _db.execute('BEGIN');
    try {
      body();
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  (String, List<Object?>) _filters(LibraryQuery query) {
    final conditions = <String>[];
    final arguments = <Object?>[];
    if (!query.includeHidden) {
      conditions.add('hidden = 0');
      if (query.hiddenFolders.isNotEmpty) {
        conditions.add(
          'folder NOT IN (${List.filled(query.hiddenFolders.length, '?').join(', ')})',
        );
        arguments.addAll(query.hiddenFolders);
      }
    }
    if (query.starredOnly) {
      conditions.add('starred = 1');
    }
    if (query.folder != null) {
      conditions.add('folder = ?');
      arguments.add(query.folder);
    }
    if (query.albumId != null) {
      conditions.add(
        'path IN (SELECT path FROM album_items WHERE album_id = ?)',
      );
      arguments.add(query.albumId);
    }
    if (query.onlyWithLocation || query.bounds != null) {
      conditions.add('COALESCE(loc_lat, gps_lat) IS NOT NULL');
    }
    final bounds = query.bounds;
    if (bounds != null) {
      conditions.add(
        'COALESCE(loc_lat, gps_lat) BETWEEN ? AND ? '
        'AND COALESCE(loc_lon, gps_lon) BETWEEN ? AND ?',
      );
      arguments.addAll([bounds.south, bounds.north, bounds.west, bounds.east]);
    }
    for (final word in query.words) {
      conditions.add("search LIKE ? ESCAPE '\\'");
      arguments.add('%${_escapeLike(word)}%');
    }
    return (
      conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}',
      arguments,
    );
  }

  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  static String _searchText(CatalogImage image) {
    String date(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    return [
      image.name,
      image.folder,
      image.camera ?? '',
      image.info.caption,
      ...image.info.tags,
      date(image.date),
    ].join(' ').toLowerCase();
  }

  static GeoPoint? _point(Object? latitude, Object? longitude) {
    if (latitude is! num || longitude is! num) {
      return null;
    }
    return GeoPoint(latitude.toDouble(), longitude.toDouble());
  }

  static CatalogImage _fromRow(Row row) {
    final taken = row['taken'] as int?;
    List<String> tags;
    try {
      tags = (jsonDecode(row['tags'] as String) as List)
          .whereType<String>()
          .toList();
    } catch (_) {
      tags = const [];
    }
    ImageEdits edits;
    try {
      edits = ImageEdits.fromJson(jsonDecode(row['edits'] as String));
    } catch (_) {
      edits = ImageEdits.none;
    }
    return CatalogImage(
      path: row['path'] as String,
      folder: row['folder'] as String,
      name: row['name'] as String,
      stamp: FileStamp(row['size'] as int, row['modified'] as int),
      taken: taken == null ? null : DateTime.fromMillisecondsSinceEpoch(taken),
      camera: row['camera'] as String?,
      gps: _point(row['gps_lat'], row['gps_lon']),
      info: PhotoInfo(
        starred: row['starred'] == 1,
        caption: row['caption'] as String,
        tags: tags,
        hidden: row['hidden'] == 1,
        location: _point(row['loc_lat'], row['loc_lon']),
      ),
      edits: edits,
    );
  }
}

extension on LibraryQuery {
  /// Folder lists ignore the folder/album being looked at.
  LibraryQuery copyForFolders() => LibraryQuery(
    text: text,
    onlyWithLocation: onlyWithLocation,
    bounds: bounds,
    starredOnly: starredOnly,
    includeHidden: includeHidden,
    hiddenFolders: hiddenFolders,
  );
}
