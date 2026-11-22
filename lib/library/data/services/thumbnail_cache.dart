import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../../editor/data/pipeline/edit_pipeline.dart';
import '../../../editor/data/services/flutter_image_pixel_source.dart';
import '../../../editor/domain/entities/edit_operation.dart';
import '../../../editor/domain/entities/image_edits.dart';
import '../../../editor/domain/entities/rgba_image.dart';
import '../../../editor/domain/services/image_pixel_source.dart';
import '../../domain/entities/catalog_image.dart';

/// Small JPEG thumbnails on disk, so a big library scrolls quickly after
/// the first visit. A thumbnail is keyed by the photo's path, size,
/// modification time and edits: changing any of them makes a new one.
class ThumbnailCache {
  ThumbnailCache(
    this.directory, {
    this.pixelSource = const FlutterImagePixelSource(),
    int maxConcurrent = 3,
  }) : _slots = maxConcurrent;

  /// Long edge of cached thumbnails, in pixels.
  static const int size = 360;
  static const int _formatVersion = 1;

  final String directory;
  final ImagePixelSource pixelSource;

  int _slots;
  final Queue<Completer<void>> _waiting = Queue();
  final Map<String, Future<Uint8List?>> _inFlight = {};

  String keyFor(String path, FileStamp stamp, ImageEdits edits) {
    final source = [
      _formatVersion,
      size,
      path,
      stamp.size,
      stamp.modifiedMs,
      jsonEncode(edits.toJson()),
    ].join('|');
    return sha1.convert(utf8.encode(source)).toString();
  }

  String fileFor(String key) =>
      p.join(directory, key.substring(0, 2), '$key.jpg');

  /// JPEG bytes of the thumbnail, made (and stored) on first request; null
  /// if the photo can't be decoded.
  Future<Uint8List?> thumbnail(String path, FileStamp stamp, ImageEdits edits) {
    final key = keyFor(path, stamp, edits);
    // A block body on purpose: returning the removed future from
    // whenComplete would make the future wait for itself.
    return _inFlight[key] ??= _load(key, path, edits).whenComplete(() {
      _inFlight.remove(key);
    });
  }

  Future<Uint8List?> _load(String key, String path, ImageEdits edits) async {
    final file = File(fileFor(key));
    try {
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (_) {}

    await _acquire();
    try {
      final source = await pixelSource.load(path, maxDimension: size);
      if (source == null) {
        return null;
      }
      final operations = edits.operations;
      final bytes = await Isolate.run(
        () => encodeThumbnail(source, operations),
      );
      await _store(file, bytes);
      return bytes;
    } catch (error) {
      debugPrint('Unable to make a thumbnail for $path: $error');
      return null;
    } finally {
      _release();
    }
  }

  static Future<void> _store(File file, Uint8List bytes) async {
    try {
      await file.parent.create(recursive: true);
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(file.path);
    } catch (error) {
      // Still usable for this session, just not cached.
      debugPrint('Unable to cache thumbnail ${file.path}: $error');
    }
  }

  /// Deletes every cached thumbnail.
  Future<void> clear() async {
    try {
      final dir = Directory(directory);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (error) {
      debugPrint('Unable to clear thumbnails: $error');
    }
  }

  Future<void> _acquire() async {
    if (_slots > 0) {
      _slots -= 1;
      return;
    }
    final waiter = Completer<void>();
    _waiting.add(waiter);
    await waiter.future;
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
    } else {
      _slots += 1;
    }
  }
}

/// Applies [operations] and encodes a JPEG, flattening transparency onto a
/// dark grey that matches the app. Runs in an isolate.
@visibleForTesting
Uint8List encodeThumbnail(RgbaImage source, List<EditOperation> operations) {
  final rendered = applyEdits(source, operations);
  final image = img.Image.fromBytes(
    width: rendered.width,
    height: rendered.height,
    bytes: rendered.pixels.buffer,
    bytesOffset: rendered.pixels.offsetInBytes,
    numChannels: 4,
  );
  final flat = img.Image(width: image.width, height: image.height);
  img.fill(flat, color: img.ColorRgb8(32, 32, 40));
  img.compositeImage(flat, image);
  return img.encodeJpg(flat, quality: 82);
}

/// An [ImageProvider] for a library thumbnail.
@immutable
class CachedThumbnailImage extends ImageProvider<CachedThumbnailImage> {
  const CachedThumbnailImage(this.cache, this.image);

  final ThumbnailCache cache;
  final CatalogImage image;

  @override
  Future<CachedThumbnailImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    CachedThumbnailImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: 1,
      debugLabel: image.path,
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await cache.thumbnail(image.path, image.stamp, image.edits);
    if (bytes == null) {
      throw StateError('No thumbnail for ${image.path}');
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is CachedThumbnailImage &&
      other.image.path == image.path &&
      other.image.stamp == image.stamp &&
      other.image.edits == image.edits;

  @override
  int get hashCode => Object.hash(image.path, image.stamp, image.edits);
}
