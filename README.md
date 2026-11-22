# oiv

Open Image Viewer / Picavi desktop viewer.

## What it does

- Opens a selected image and automatically loads every supported sibling image in the same folder.
- Shows the active image centered with a dense bottom thumbnail strip.
- Smooth zoom, pan and rotate, fit / fill window, full screen, and an EXIF info panel.
- Saves rotations back to the file — losslessly for JPEG (only the EXIF orientation changes), PNG and BMP.
- Slideshow with adjustable timing, shuffle, loop and optional full screen.
- File actions: rename, copy or move to a folder, move to Trash / Recycle Bin, copy image, show in Finder / Explorer, open with another app.
- Select several images (⌘/Ctrl-click, Shift-click, ⌘/Ctrl+A) to copy, move or trash them together.
- Drop images or folders onto the window to open them.
- Sorts the folder by name (natural order, so `IMG_2` comes before `IMG_10`), date modified, file size or type — ascending or descending, remembered between launches.
- Refreshes the thumbnail strip automatically when images are added to or removed from the folder.
- Remembers recent folders and can reopen the last image on launch.
- Uses a dark semi-transparent shell with a blurred backdrop for a Picasa-style browsing feel.
- Available in English, Spanish, Hindi, Chinese, Marathi and Arabic.

See [docs/ROADMAP.md](docs/ROADMAP.md) for what's planned next.

## Keyboard shortcuts

Press `?` in the viewer to see these in the app.

| Keys | Action |
|---|---|
| `→` / `←` | Next / previous image |
| `Home` / `End` | First / last image |
| `Space` | Play / pause slideshow |
| `+` / `−` | Zoom in / out |
| `1` | Actual size (1:1) |
| `0` | Fit / fill window |
| `F` / `F11` | Full screen on / off |
| `R` / `Shift+R` | Rotate right / left |
| `⌘S` / `Ctrl+S` | Save rotation to the file |
| `I` | Show / hide image info |
| `F2` | Rename |
| `Delete` / `⌫` | Move to Trash / Recycle Bin |
| `⌘C` / `Ctrl+C` | Copy image |
| `⌘A` / `Ctrl+A` | Select all |
| `⌘`/`Ctrl`-click, `Shift`-click | Add to / extend selection |
| `?` | Show keyboard shortcuts |
| `Esc` | Clear selection, stop slideshow, leave full screen, or close |

## Supported image extensions

`bmp`, `gif`, `ico`, `jpeg`, `jpg`, `png`, `svg`, `webp` on every platform, plus
`heic`, `heif`, `avif`, `tif`, `tiff` on macOS (decoded by the system's ImageIO).

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
