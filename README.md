# oiv

Open Image Viewer / Picavi desktop viewer.

## What it does

- Opens a selected image and automatically loads every supported sibling image in the same folder.
- Shows the active image centered with a dense bottom thumbnail strip.
- Supports desktop-friendly zoom and pan via `photo_view` gestures, plus keyboard navigation with `←`, `→`, `Home`, and `End`.
- Enters fullscreen viewer mode when an image is opened.
- Uses a dark semi-transparent shell with a blurred backdrop for a Picasa-style browsing feel.

## Supported image extensions

`bmp`, `gif`, `ico`, `jpeg`, `jpg`, `png`, `webp`

## Native desktop opening support

- **macOS:** declares common image document types in `Info.plist` and forwards Finder open-file events into Flutter.
- **Linux:** installs a desktop entry advertising common image MIME types for desktop integration.
- **Windows:** registers the executable as an **Open with** target for common image extensions at user level.

## Run locally

```bash
flutter pub get
flutter run -d macos
```

You can also pass a file path directly:

```bash
flutter run -d macos -- /absolute/path/to/image.jpg
```

## Quality checks

```bash
flutter analyze
flutter test
```
