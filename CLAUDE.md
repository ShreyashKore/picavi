# CLAUDE.md

Guidance for AI agents (Claude Code and others) working in this repository.
See [AGENTS.md](AGENTS.md) for the cross-tool copy of this file — keep the two in sync.

## What this is

**oiv** ("Open Image Viewer", branded **Picavi**) is a Flutter **desktop** image
viewer (macOS, Linux, Windows — no mobile/web). You open one image and it loads
every supported sibling in the same folder into a Picasa-style gallery with a
bottom thumbnail rail, zoom/pan, keyboard navigation, and slideshow.

- Entry point: [lib/main.dart](lib/main.dart) → [lib/app.dart](lib/app.dart) → `ViewerScreen`.
- Package name (Dart imports): `package:oiv/...`.
- App bundle id / method-channel namespace: `com.gyanoba.oiv`.
- Dart SDK: `^3.11.5`. Lints: `package:flutter_lints` (see [analysis_options.yaml](analysis_options.yaml)).

## Commands

```bash
flutter pub get                       # install deps
flutter run -d macos                  # run (also -d linux / -d windows)
flutter run -d macos --dart-entrypoint-args=/path/img.jpg  # run with an image path argument
flutter analyze                       # static analysis — must pass clean
flutter test                          # run all tests
flutter test test/viewer_controller_test.dart   # single test file
flutter gen-l10n                      # regenerate localizations after editing .arb
```

Always run `flutter analyze` and `flutter test` before considering a change done.

## Architecture

The code follows a feature-first, layered (Clean-Architecture-lite) layout under
[lib/](lib/). Respect the dependency direction: **presentation → domain ← data**.
Domain never imports presentation or data.

```
lib/
  main.dart            window setup (window_manager + screen_retriever), arg/startup-path resolution
  app.dart             MaterialApp, theme, localization delegates
  core/                cross-feature building blocks
    services/          AppPreferencesService (shared_preferences), DefaultViewerService
    theme/             AppTheme, AppColors, AppColorSchemes (dark theme only)
    widgets/           AppImage (raster + SVG + system-decoded image widget)
    images/            SystemDecodedImage (ImageProvider backed by macOS ImageIO)
    l10n/              BuildContext.l10n extension
  l10n/                .arb source files + generated/ AppLocalizations (do not hand-edit generated/)
  viewer/              viewer feature module
    domain/            entities (GalleryImage, ImageMetadata, ImageSortOrder, SlideshowSettings),
                       repository/service interfaces (ImageRepository, ImagePickerService,
                       FileOperationsService, ImageTransformService), constants
                       (supported/systemDecoded image extensions). Pure Dart, no Flutter UI.
    data/              implementations: FileSystemImageRepository, DesktopImagePickerService,
                       DesktopFileOperationsService, RasterImageTransformService,
                       SlideshowSettingsStore, NativeFileChannelService (platform MethodChannel),
                       platformImageExtensions
    presentation/      controllers/ (ViewerController: ChangeNotifier), models/ (ViewerState,
                       ViewerNotice), screens/ (ViewerScreen, SettingsScreen), widgets/
  editor/              non-destructive editor feature module
    domain/            EditOperation (sealed: crop, rotate, straighten, levels, tune, effect,
                       red-eye), ImageEdits, RgbaImage, ExportOptions; interfaces
                       ImageEditRepository, ImagePixelSource, EditRenderService,
                       ImageExportService, QuickFixService
    data/              pipeline/edit_pipeline.dart (pure-Dart pixel ops, shared by preview and
                       export), SidecarImageEditRepository (.picavi.json), FlutterImagePixelSource,
                       IsolateEditRenderService, EditedImageProvider, RasterImageExportService,
                       RenderingQuickFixService
    presentation/      EditorController + EditorState, EditorScreen, crop overlay, side panel,
                       export options dialog
  library/             photo library feature module (opt-in watched folders)
    domain/            PhotoInfo (star/caption/tags/hidden), CatalogImage, LibraryQuery, Album;
                       CatalogRepository, PhotoInfoRepository, LibrarySettingsRepository,
                       LibraryIndexer, DuplicateFinder
    data/              SqliteCatalogRepository (sqlite3), FileSystemLibraryIndexer (isolates),
                       ThumbnailCache + CachedThumbnailImage, HashingDuplicateFinder,
                       SidecarPhotoInfoRepository, LibraryServices (opens it all)
    presentation/      LibraryController + LibraryState, LibraryScreen, DuplicatesScreen,
                       sidebar, grid, folder tree
  collage/             collage + contact sheet maker: CollageOptions/CollageService (domain),
                       collage_renderer.dart (pure-Dart layouts) + RasterCollageService (data),
                       options dialog (presentation)
  print_photos/        printing: PrintLayout, print_pdf.dart (PDF via package:pdf), print_flow.dart
                       (layout dialog → system print dialog via package:printing)
```

### State management
Plain `ChangeNotifier` + immutable state, no external state package.
[ViewerController](lib/viewer/presentation/controllers/viewer_controller.dart) holds a
single immutable [ViewerState](lib/viewer/presentation/models/viewer_state.dart) and
calls `notifyListeners()` via its private `_setState`. Update state only through
`ViewerState.copyWith` — never mutate fields in place. `ViewerScreen` owns the
controller and wires it to the UI.

### Dependency injection
Manual constructor injection. `ViewerController` takes `ImageRepository`,
`ImagePickerService`, `FileOperationsService`, `ImageTransformService` and
`NativeFileChannelService`, plus optional editor services (`ImageEditRepository`,
`QuickFixService`, `ImageExportService`) and an `evictImage` callback; concrete `data/`
implementations are constructed in `ViewerScreen`. Tests pass fakes — keep new
dependencies behind a `domain/` interface so they stay swappable.

## Key conventions

- **Immutability:** state/entities are immutable; evolve via `copyWith`.
- **Graceful degradation:** I/O and platform calls are wrapped in try/catch and
  fail soft (return null/empty, `debugPrint`), so the app stays usable. Mirror
  this — never let a missing file or denied permission crash the viewer. See the
  permission-denied recovery flow in `ViewerController._loadImagesFromDirectory`.
- **Platform guards:** native features check `Platform.isMacOS` etc. and catch
  `MissingPluginException`/`PlatformException`. Only macOS currently implements
  the native channel methods.
- **No hardcoded user-facing strings.** All UI text comes from localizations.
- **Supported formats** live in one place:
  [supported_image_extensions.dart](lib/viewer/domain/constants/supported_image_extensions.dart).
  `supportedImageExtensions` (`.bmp .gif .ico .jpeg .jpg .png .svg .webp`) are
  decoded by Flutter everywhere; `systemDecodedImageExtensions`
  (`.avif .heic .heif .tif .tiff`) only where the OS decodes them (macOS ImageIO).
  Use `platformImageExtensions` for "what can this platform open". Keep the
  README, `macos/Runner/Info.plist` and the Swift `supportedImageExtensions` in sync.
- **Never delete permanently.** File removal goes through the system Trash /
  Recycle Bin (`FileOperationsService.moveToTrash`); copy/move never overwrite.
- **Writing image files** (`RasterImageTransformService`) goes through a temp
  file + rename, and JPEG rotation only edits the EXIF orientation value.
- **Edits are non-destructive.** The editor never writes to the original: edits
  are an ordered list of `EditOperation`s stored per folder in a hidden
  `.picavi.json` sidecar (`SidecarImageEditRepository`, written via temp file +
  rename). Coordinates in operations are normalised (0–1) to the image as it is
  at that step. Rename/move/copy in the viewer carry edits along. Edited copies
  are produced only by Export, which never overwrites.
- **Sidecar = source of truth, catalog = cache.** `PicaviSidecarStore`
  (`lib/core/sidecar/`) owns `.picavi.json`; each feature owns its own fields of
  an image's entry (`edits`; `starred`/`caption`/`tags`/`hidden`/`location`/`people`) and must keep
  unknown fields. The SQLite catalog can always be rebuilt by re-indexing —
  except albums, which live only in the catalog.
- **One pixel pipeline.** Preview, viewer display (`EditedImageProvider`) and
  export all run `applyEdits` from `editor/data/pipeline/edit_pipeline.dart`
  (in an isolate). Add a new operation there plus its JSON in `EditOperation`.

## Localization (i18n)

Uses Flutter `gen-l10n`. Config in [l10n.yaml](l10n.yaml).
- Source of truth: ARB files in [lib/l10n/](lib/l10n/), template `app_en.arb`.
  Supported locales: en, es, hi, zh, mr, ar.
- To add/change a string: edit `app_en.arb` (with an `@key` metadata entry), add
  translations to the other `app_*.arb`, then run `flutter gen-l10n`.
- **Never** hand-edit `lib/l10n/generated/` — it is regenerated.
- In widgets, read strings via `context.l10n.<key>` (the `L10nBuildContextX`
  extension). Strings needed in non-widget layers (e.g. `ViewerController`) are
  passed in as small text DTOs like `DirectoryAccessTexts` / `ImagePickerTexts`.

## Native / platform integration

The macOS app forwards Finder "Open With" events into Flutter over a
`MethodChannel('com.gyanoba.oiv/file_open')`. Dart side:
[NativeFileChannelService](lib/viewer/data/services/native_file_channel_service.dart);
native side: [macos/Runner/AppDelegate.swift](macos/Runner/AppDelegate.swift) and
`MainFlutterWindow.swift`. Channel methods: `consumePendingFiles`, `openFiles`,
`pickImageFile`, `authorizeDirectoryAccess`, `getDefaultViewerStatus`,
`setAsDefaultViewer`, `moveToTrash`, `revealInFinder`, `copyImageToClipboard`,
`openWith`, `decodeImage` (used by `SystemDecodedImage`), `recognizeText` (Live Text),
`shareFiles` (share menu), `detectFaces` (People). macOS uses
security-scoped bookmarks for folder access. On Windows/Linux, file actions use
system tools from `DesktopFileOperationsService` (paths passed via env/args).

Per-platform "open with" registration: macOS declares image document types in
`Info.plist`; Linux ships `linux/oiv.desktop.in`; Windows registers an "Open with"
target. Window chrome (hidden title bar, transparent background, sizing) is set up
in `main.dart` via `window_manager` + `screen_retriever`.

If you change channel method names or payloads, update **both** the Dart service
and the Swift side together.

## Testing

Tests live in [test/](test/) using `flutter_test`. The codebase favors testing the
controller/services against fake interface implementations (see
`viewer_controller_test.dart`, `app_preferences_service_test.dart`,
`interactive_image_viewer_test.dart`). When adding behavior to `ViewerController`
or a service, add or extend a fake and assert on the resulting `ViewerState`.

## Gotchas

- `lib/l10n/generated/` and other generated Flutter files are not hand-editable.
- Zoom/pan is the custom [InteractiveImageViewer](lib/viewer/presentation/widgets/interactive_image_viewer.dart)
  (there is no `photo_view` dependency).
- Viewer keyboard shortcuts live in `ViewerScreen._shortcutActionFor`; keep the
  list in [keyboard_shortcuts_dialog.dart](lib/viewer/presentation/widgets/keyboard_shortcuts_dialog.dart) in sync.
- Only the dark theme exists — there is no light theme.
- `AppImage` handles both raster images and SVGs; use it instead of raw `Image`.
