# Picavi

An open image viewer for the desktop (code name `oiv`).

## What it does

- Opens a selected image and automatically loads every supported sibling image in the same folder.
- Shows the active image centered with a dense bottom thumbnail strip.
- Smooth zoom, pan and rotate, fit / fill window, full screen, and an EXIF info panel.
- Saves rotations back to the file — losslessly for JPEG (only the EXIF orientation changes), PNG and BMP.
- Slideshow with adjustable timing, shuffle, loop and optional full screen.
- File actions: rename, copy or move to a folder, move to Trash / Recycle Bin, copy image, show in Finder / Explorer, open with another app.
- Select several images (⌘/Ctrl-click, Shift-click, ⌘/Ctrl+A) to copy, move or trash them together.
- Drop images or folders onto the window to open them.
- Picasa-style editor (`E`): crop with print-size presets, straighten, red-eye, I'm Feeling Lucky, auto contrast and colour, tuning sliders (fill light, highlights, shadows, colour temperature) and effects (B&W, sepia, warmify, saturation, sharpen, soft focus, glow, film grain, vignette), with undo / redo / revert.
- Edits never touch your originals: they are kept in a hidden `.picavi.json` file in the folder (like Picasa's `.picasa.ini`) and follow images you rename, move or copy in Picavi.
- Star photos (`S`), add captions and tags, and hide photos from the library — saved in the same `.picavi.json`, so they travel with the folder.
- Library (`L`): add the folders where you keep photos and browse everything by month, folder, album or star; search names, captions, tags, cameras and dates; make albums; find exact duplicates and move extra copies to the Trash. The catalog and thumbnails are kept in the app's support folder; your files stay where they are.
- People (macOS): faces are found on your Mac, grouped by likeness and named by you; names are saved next to the photos and are searchable.
- Places: photos with GPS (or a location you set) on a map — map tiles come from OpenStreetMap and load only while the map is open.
- Import photos from a camera or memory card into dated folders; already-imported photos are skipped and nothing on the card is changed.
- Make collages (mosaic or grid) and contact sheets, print photos 1–9 per page, and share through the macOS share menu.
- Export edited copies as JPEG or PNG at a chosen size and quality; apply quick fixes or export a whole selection at once.
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
| `E` | Edit image |
| `S` | Star / remove star |
| `L` | Open the library |
| `F2` | Rename |
| `Delete` / `⌫` | Move to Trash / Recycle Bin |
| `⌘C` / `Ctrl+C` | Copy image |
| `⌘A` / `Ctrl+A` | Select all |
| `⌘`/`Ctrl`-click, `Shift`-click | Add to / extend selection |
| `?` | Show keyboard shortcuts |
| `Esc` | Clear selection, stop slideshow, leave full screen, or close |

### In the library

| Keys | Action |
|---|---|
| Click, `⌘`/`Ctrl`-click, `Shift`-click | Select photos |
| Double-click, `Enter` | Open in the viewer |
| `⌘A` / `Ctrl+A` | Select all |
| `Esc` | Clear selection, or go back |

### In the editor

| Keys | Action |
|---|---|
| `⌘Z` / `Ctrl+Z` | Undo |
| `⇧⌘Z` / `Ctrl+Shift+Z`, `Ctrl+Y` | Redo |
| `Enter` | Apply the open tool |
| `Esc` | Cancel the open tool, or close the editor |

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
flutter run -d macos --dart-entrypoint-args=/absolute/path/to/image.jpg
```

## Quality checks

```bash
flutter analyze
flutter test
```
