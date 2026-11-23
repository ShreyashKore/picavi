import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/services/app_preferences_service.dart';
import '../../editor/data/services/flutter_image_pixel_source.dart';
import '../../editor/domain/services/image_pixel_source.dart';
import '../../viewer/domain/services/file_operations_service.dart';
import '../domain/repositories/catalog_repository.dart';
import '../domain/repositories/library_settings_repository.dart';
import '../domain/repositories/photo_info_repository.dart';
import '../domain/services/duplicate_finder.dart';
import '../domain/services/import_service.dart';
import '../domain/services/library_indexer.dart';
import 'repositories/preferences_library_settings_repository.dart';
import 'repositories/sidecar_photo_info_repository.dart';
import 'repositories/sqlite_catalog_repository.dart';
import 'services/file_system_import_service.dart';
import 'services/file_system_library_indexer.dart';
import 'services/hashing_duplicate_finder.dart';
import 'services/thumbnail_cache.dart';

/// Everything the library needs, opened once and kept for the session.
class LibraryServices {
  LibraryServices({
    required this.catalog,
    required this.thumbnails,
    required this.settings,
    required this.photoInfo,
    required this.fileOperations,
    LibraryIndexer? indexer,
    DuplicateFinder? duplicateFinder,
    ImportService? importService,
    String? defaultImportDestination,
    this.pixelSource = const FlutterImagePixelSource(),
  }) : indexer = indexer ?? FileSystemLibraryIndexer(catalog),
       duplicateFinder = duplicateFinder ?? HashingDuplicateFinder(catalog),
       importService = importService ?? FileSystemImportService(),
       defaultImportDestination =
           defaultImportDestination ??
           FileSystemImportService.defaultDestination();

  /// Opens the catalog and thumbnail cache in the app's support folder.
  static Future<LibraryServices> open({
    required AppPreferencesService preferences,
    required FileOperationsService fileOperations,
  }) async {
    final support = (await getApplicationSupportDirectory()).path;
    return LibraryServices(
      catalog: SqliteCatalogRepository.open(
        p.join(support, 'library', 'catalog.sqlite'),
      ),
      thumbnails: ThumbnailCache(p.join(support, 'library', 'thumbnails')),
      settings: PreferencesLibrarySettingsRepository(preferences),
      photoInfo: const SidecarPhotoInfoRepository(),
      fileOperations: fileOperations,
    );
  }

  final CatalogRepository catalog;
  final ThumbnailCache thumbnails;
  final LibrarySettingsRepository settings;
  final PhotoInfoRepository photoInfo;
  final FileOperationsService fileOperations;
  final LibraryIndexer indexer;
  final DuplicateFinder duplicateFinder;
  final ImportService importService;

  /// Decodes photos for collages and similar.
  final ImagePixelSource pixelSource;

  /// Where imports go until the user picks another folder.
  final String defaultImportDestination;

  Future<void> close() => catalog.close();
}
