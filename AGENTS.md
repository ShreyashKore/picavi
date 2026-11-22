# AGENTS.md

Cross-tool agent guidance for this repository (the open `AGENTS.md` standard).
Claude Code reads [CLAUDE.md](CLAUDE.md), which mirrors this file — **keep both in sync.**

## What this is

**oiv** ("Open Image Viewer", branded **Picavi**) is a Flutter **desktop** image
viewer (macOS, Linux, Windows — no mobile/web). Opening one image loads every
supported sibling in the same folder into a Picasa-style gallery with a bottom
thumbnail rail, zoom/pan, keyboard navigation, and slideshow.

- Entry point: `lib/main.dart` → `lib/app.dart` → `ViewerScreen`.
- Dart import package: `package:oiv/...`. Bundle id / channel namespace: `com.gyanoba.oiv`.
- Dart SDK `^3.11.5`; lints via `package:flutter_lints` (`analysis_options.yaml`).

## Commands

```bash
flutter pub get                       # install deps
flutter run -d macos                  # run (also -d linux / -d windows)
flutter run -d macos -- /path/img.jpg # run with an image path argument
flutter analyze                       # static analysis — must pass clean
flutter test                          # run all tests
flutter test test/viewer_controller_test.dart   # single test file
flutter gen-l10n                      # regenerate localizations after editing .arb
```

Run `flutter analyze` and `flutter test` before considering a change done.

## Architecture

Feature-first, layered (Clean-Architecture-lite). Dependency direction:
**presentation → domain ← data**. Domain is pure Dart and imports neither.

```
lib/
  main.dart          window setup (window_manager + screen_retriever), arg/startup-path resolution
  app.dart           MaterialApp, dark theme, localization delegates
  core/              cross-feature: services/ (AppPreferencesService, DefaultViewerService),
                     theme/, widgets/ (AppImage), images/ (SystemDecodedImage),
                     l10n/ (context.l10n extension)
  l10n/              .arb sources + generated/ (do NOT hand-edit generated/)
  viewer/            the single feature module
    domain/          entities, repository/service interfaces (ImageRepository, ImagePickerService,
                     FileOperationsService, ImageTransformService), image extension constants
    data/            FileSystemImageRepository, DesktopImagePickerService, DesktopFileOperationsService,
                     RasterImageTransformService, SlideshowSettingsStore, NativeFileChannelService
    presentation/    controllers/ (ViewerController), models/ (ViewerState, ViewerNotice),
                     screens/, widgets/
```

- **State:** plain `ChangeNotifier` + immutable `ViewerState`; no state-management
  package. Mutate only via `ViewerState.copyWith` + `notifyListeners()`.
- **DI:** manual constructor injection of `domain/` interfaces; concrete `data/`
  impls are built in `ViewerScreen`; tests inject fakes. Put new dependencies
  behind a `domain/` interface.

## Conventions

- Immutable state/entities; evolve via `copyWith`.
- Fail soft: wrap I/O and platform calls in try/catch, return null/empty and
  `debugPrint` rather than crash (see `ViewerController._loadImagesFromDirectory`'s
  permission-recovery flow).
- Guard native features with `Platform.isMacOS` etc. and catch
  `MissingPluginException` / `PlatformException`. Only macOS implements the native channel today.
- No hardcoded user-facing strings — everything goes through localizations.
- Supported formats live only in
  `lib/viewer/domain/constants/supported_image_extensions.dart`:
  `supportedImageExtensions` (Flutter-decoded, all platforms) and
  `systemDecodedImageExtensions` (`.avif .heic .heif .tif .tiff`, macOS ImageIO only).
  Use `platformImageExtensions`; keep README, `Info.plist` and Swift lists in sync.
- Never delete permanently: removal goes to the system Trash / Recycle Bin;
  copy/move never overwrite. Image rewrites use temp file + rename.

## Localization

Flutter `gen-l10n`, config in `l10n.yaml`. ARB sources in `lib/l10n/`, template
`app_en.arb`, locales: en, es, hi, zh, mr, ar. To change a string: edit
`app_en.arb` (+ `@key` metadata), translate in the other `app_*.arb`, run
`flutter gen-l10n`. Read in widgets via `context.l10n.<key>`; pass strings into
non-widget layers as DTOs (`DirectoryAccessTexts`, `ImagePickerTexts`). Never edit
`lib/l10n/generated/`.

## Native integration

macOS forwards Finder "Open With" events into Flutter via
`MethodChannel('com.gyanoba.oiv/file_open')`. Dart: `NativeFileChannelService`;
Swift: `macos/Runner/AppDelegate.swift` + `MainFlutterWindow.swift`. Methods:
`consumePendingFiles`, `openFiles`, `pickImageFile`, `authorizeDirectoryAccess`,
`getDefaultViewerStatus`, `setAsDefaultViewer`, `moveToTrash`, `revealInFinder`,
`copyImageToClipboard`, `openWith`, `decodeImage` (folder access uses security-scoped
bookmarks). Per-platform "open with" registration: macOS `Info.plist`, Linux
`linux/oiv.desktop.in`, Windows registry. **Change channel names/payloads on the
Dart and Swift sides together.**

## Testing

`flutter_test` in `test/`. Prefer testing `ViewerController`/services against fake
interface implementations and asserting on the resulting `ViewerState` (see
`viewer_controller_test.dart`, `app_preferences_service_test.dart`).

## Gotchas

- Generated files (`lib/l10n/generated/`, Flutter plugin registrants) are not hand-editable.
- Zoom/pan is the custom `InteractiveImageViewer` (no `photo_view` dependency).
- Viewer keyboard shortcuts live in `ViewerScreen._shortcutActionFor`; keep the
  list in `keyboard_shortcuts_dialog.dart` in sync.
- Dark theme only — no light theme.
- Use `AppImage` (handles raster + SVG), not raw `Image`.
