import 'package:oiv/editor/data/pipeline/edit_pipeline.dart';
import 'package:oiv/editor/domain/entities/edit_operation.dart';
import 'package:oiv/editor/domain/entities/export_options.dart';
import 'package:oiv/editor/domain/entities/image_edits.dart';
import 'package:oiv/editor/domain/entities/rgba_image.dart';
import 'package:oiv/editor/domain/repositories/image_edit_repository.dart';
import 'package:oiv/editor/domain/services/edit_render_service.dart';
import 'package:oiv/editor/domain/services/image_export_service.dart';
import 'package:oiv/editor/domain/services/image_pixel_source.dart';
import 'package:oiv/library/domain/entities/photo_info.dart';
import 'package:oiv/library/domain/repositories/photo_info_repository.dart';
import 'package:path/path.dart' as p;

/// Edits kept in memory, keyed by full path.
class InMemoryImageEditRepository implements ImageEditRepository {
  final Map<String, ImageEdits> stored = {};
  bool failSaves = false;
  int saveCount = 0;

  @override
  Future<Map<String, ImageEdits>> loadDirectory(String directory) async => {
    for (final entry in stored.entries)
      if (p.dirname(entry.key) == directory) entry.key: entry.value,
  };

  @override
  Future<ImageEdits> load(String imagePath) async =>
      stored[imagePath] ?? ImageEdits.none;

  @override
  Future<bool> save(String imagePath, ImageEdits edits) async {
    saveCount += 1;
    if (failSaves) {
      return false;
    }
    if (edits.isEmpty) {
      stored.remove(imagePath);
    } else {
      stored[imagePath] = edits;
    }
    return true;
  }

  @override
  Future<void> move(String from, String to) async {
    final edits = stored.remove(from);
    if (edits != null) {
      stored[to] = edits;
    }
  }

  @override
  Future<void> copy(String from, String to) async {
    final edits = stored[from];
    if (edits != null) {
      stored[to] = edits;
    }
  }
}

/// A [width]×[height] gradient: red grows left to right, green top to bottom.
RgbaImage gradientImage(int width, int height) {
  final image = RgbaImage.blank(width, height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.pixels.setAll((y * width + x) * 4, [
        60 + x * 120 ~/ width,
        60 + y * 120 ~/ height,
        90,
        255,
      ]);
    }
  }
  return image;
}

class FakePixelSource implements ImagePixelSource {
  FakePixelSource([RgbaImage? image]) : image = image ?? gradientImage(40, 20);

  RgbaImage? image;
  final List<(String, int?)> loads = [];

  @override
  bool canEdit(String path) => p.extension(path) != '.svg';

  @override
  Future<RgbaImage?> load(String path, {int? maxDimension}) async {
    loads.add((path, maxDimension));
    return image?.copy();
  }
}

/// Runs the real pipeline synchronously (no isolate) for fast, simple tests.
class SyncRenderService implements EditRenderService {
  int renders = 0;

  @override
  Future<RgbaImage> render(
    RgbaImage source,
    List<EditOperation> operations,
  ) async {
    renders += 1;
    return applyEdits(source, operations);
  }

  @override
  Future<LevelsEdit> autoFix(RgbaImage image, AutoFixKind kind) async =>
      measureAutoFix(image, kind);
}

class FakeExportService implements ImageExportService {
  final List<(String, ImageEdits, String)> calls = [];
  Set<String> failing = {};

  @override
  Future<String?> export(
    String imagePath,
    ImageEdits edits,
    ExportOptions options,
    String directory,
  ) async {
    calls.add((imagePath, edits, directory));
    if (failing.contains(imagePath)) {
      return null;
    }
    return p.join(directory, p.basename(imagePath));
  }
}

/// Photo info kept in memory, keyed by full path.
class InMemoryPhotoInfoRepository implements PhotoInfoRepository {
  final Map<String, PhotoInfo> stored = {};
  bool failSaves = false;

  @override
  Future<Map<String, PhotoInfo>> loadDirectory(String directory) async => {
    for (final entry in stored.entries)
      if (p.dirname(entry.key) == directory) entry.key: entry.value,
  };

  @override
  Future<PhotoInfo> load(String imagePath) async =>
      stored[imagePath] ?? PhotoInfo.none;

  @override
  Future<bool> save(String imagePath, PhotoInfo info) async {
    if (failSaves) {
      return false;
    }
    if (info.isEmpty) {
      stored.remove(imagePath);
    } else {
      stored[imagePath] = info;
    }
    return true;
  }

  @override
  Future<void> move(String from, String to) async {
    final info = stored.remove(from);
    if (info != null) {
      stored[to] = info;
    }
  }

  @override
  Future<void> copy(String from, String to) async {
    final info = stored[from];
    if (info != null) {
      stored[to] = info;
    }
  }
}
