# oiv

Open Image Viewer / Picavi desktop viewer.

## What it does

- Opens a selected image and automatically loads every supported sibling image in the same folder.
- Shows the active image centered with a dense bottom thumbnail strip.
- Smooth zoom, pan and rotate, an EXIF info panel, and a slideshow.
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
| `0` | Fit to window |
| `R` / `Shift+R` | Rotate right / left |
| `I` | Show / hide image info |
| `?` | Show keyboard shortcuts |
| `Esc` | Close Picavi |

## Supported image extensions

`bmp`, `gif`, `ico`, `jpeg`, `jpg`, `png`, `svg`, `webp`

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
