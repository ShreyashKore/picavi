# Picavi roadmap — closing the gap with Picasa

_Drafted 2026-11-22 from a review of the codebase at v1.0.3+3._

## Where Picavi is today

Picavi is a polished **single-folder viewer**: open an image, siblings load into
a thumbnail rail, zoom/pan, rotate (view-only), EXIF info overlay, 3-second
slideshow, recent folders, restore-last-image, default-viewer setup, 6 locales.

Picasa was a **photo organiser + light editor + viewer**. Almost everything below
falls into one of those three buckets.

## What Picavi lacks

### 1. Viewer essentials (small, high value)
| Gap | Notes |
|---|---|
| File operations | ✅ Done in Phase 1 (set as wallpaper still to do) |
| Persisted rotation | ✅ Done in Phase 1 (JPEG/PNG/BMP) |
| Slideshow options | ✅ Interval, shuffle, loop, full screen done; transition choices still to do |
| Fit modes | ✅ Fit / fill / 1:1 and full screen done |
| Compare view | Picasa's 2-up side-by-side compare |
| Drag & drop | ✅ Drop in done; dragging out still to do |
| Folder watching | ✅ Done in Phase 0 |
| Sort options | ✅ Name, modified, size, type done; date taken still to do |
| Histogram | Picasa showed a live histogram in the info pane |
| Shortcut help | ✅ `?` overlay added; still missing file shortcuts like `Del` (Phase 1) |
| Multi-select ("Picture Tray") | ✅ Done in Phase 1 |

### 2. Formats
| Gap | Notes |
|---|---|
| HEIC/HEIF, AVIF, TIFF | ✅ macOS done; Windows/Linux still to do |
| RAW (CR2/NEF/ARW/DNG) | At least show the embedded JPEG preview |
| Video | Picasa listed and played videos alongside photos |

### 3. Editing (Picasa's "Basic Fixes / Tuning / Effects")
| Gap | Notes |
|---|---|
| Crop & straighten | ✅ Done in Phase 2 (free, original, square, 4×6, 5×7, 8×10, 16:9) |
| One-click fixes | ✅ I'm Feeling Lucky, auto contrast, auto colour, red-eye |
| Tuning sliders | ✅ Fill light, highlights, shadows, colour temperature (no neutral-colour picker yet) |
| Effects | ✅ B&W, sepia, warmify, saturation, sharpen, soft focus, glow, film grain, vignette; tint, focal B&W, graduated tint still to do |
| Text / retouch | Caption text overlay, spot-heal |
| Non-destructive edits + Revert | ✅ `.picavi.json` sidecar, undo/redo/revert |
| Export | ✅ JPEG/PNG, size, quality; batch export of a selection |
| Batch edit | ✅ Quick fixes and Remove edits on a selection |

### 4. Library / organiser (the biggest gap)
| Gap | Notes |
|---|---|
| Watched folders + indexer | Scan chosen roots in the background into a local catalog |
| Folder tree sidebar | Browse all indexed folders without the open dialog |
| Grid / lightbox view | Full thumbnail grid with size slider, not just a rail |
| Timeline | Group by date taken (year → month → day) |
| Search | By filename, folder, date, camera, caption, tag |
| Star / favourite, tags, captions | Ideally written to XMP so other apps see them |
| Albums | Virtual collections across folders |
| Hide folders / images | Exclude from library |
| Duplicate finder | Hash + perceptual-hash matching |
| Disk thumbnail cache | Needed once libraries get big |

### 5. Advanced (Picasa's "wow" features)
| Gap | Notes |
|---|---|
| Places | Map view from GPS EXIF; manual geotagging |
| People | On-device face detection + clustering (Apple Vision on macOS) |
| Collage maker | Grid / mosaic / contact sheet |
| Movie maker | Slideshow → video export |
| Print & contact sheets | |
| Import | From camera / SD card with date-based folders |
| Share / email | OS share sheet |

### 6. Housekeeping found during the review
- ~~Control-bar tooltips and info-panel labels were hardcoded English~~ → localized.
- ~~README format list and `photo_view` mention were stale~~ → fixed.
- No light theme (Picasa was light-on-dark too, so this is optional).
- ~~App icon was the default asset set~~ → replaced with the photo-stack icon
  (source + master in `assets/branding/`).

## Roadmap

Each phase ships as a usable release. Later phases depend on earlier
architecture choices, so the decisions are called out up front.

### Phase 0 — Cleanup (v1.0.x) — ✅ done
- ✅ Localize hardcoded tooltips and info-panel labels; fix README.
- ✅ New app icon on macOS / Windows / Linux.
- ✅ Keyboard shortcut overlay (`?`) plus Space / + / − / 1 / 0 / R / I shortcuts.
- ✅ Sort by name (natural), date modified, size, type; persisted.
- ✅ Folder watching — the rail refreshes when files are added/removed.
- ✅ Fixed the 3 `unawaited_return_in_try_block` analyzer warnings.
- Deferred: sort by *date taken* (needs EXIF for every file — do it with the
  Phase 3 metadata cache); reloading an image whose file was edited in place.

### Phase 1 — Viewer essentials (v1.1) — ✅ done
- ✅ `FileOperationsService`: move to Trash / Recycle Bin, rename, copy/move to
  folder, show in Finder/Explorer, copy image, Open with… (macOS via native
  channel; Windows/Linux via system tools).
- ✅ Save rotation: lossless for JPEG (EXIF orientation edited in place), PNG/BMP
  re-encoded losslessly; atomic temp-file + rename.
- ✅ Slideshow settings: time per image, shuffle, loop, full screen while playing.
- ✅ Fit / fill toggle, full screen toggle, drop files/folders to open.
- ✅ Multi-select in the rail (⌘/Ctrl-click, Shift-click, select all).
- ✅ HEIC/HEIF, AVIF, TIFF on macOS via ImageIO.
- Deferred / not done:
  - **Drag images out** of Picavi into other apps (needs a native drag source;
    `super_drag_and_drop` pulls in a Rust toolchain — decide before adding).
  - Saving rotation for WebP/GIF/HEIC/TIFF (no lossless writer yet), and JPEGs
    whose EXIF lacks an orientation tag (left untouched to avoid metadata loss).
  - HEIC/AVIF/TIFF on **Windows/Linux** (needs WIC / libheif, or `image` for TIFF).
  - Windows/Linux file actions are written but **untested on those platforms**.
  - Slideshow fade transition is the existing image cross-fade; no transition
    choices.

### Phase 2 — Editor (v1.2) — ✅ done
- ✅ New feature module `lib/editor/` (domain/data/presentation).
- ✅ Edit model = ordered list of operations in a per-folder `.picavi.json`
  sidecar (decision 1: **JSON**, Picasa-style; XMP can be added later as an
  export of the same model). Originals are never written.
- ✅ One pure-Dart pixel pipeline in a background isolate, used for the editor
  preview (2048 px), the viewer and thumbnails, and full-size export — so what
  you see is what you export. (Chosen over GPU shaders: one implementation,
  fully unit-tested, same on every platform.)
- ✅ Editor: crop with presets, straighten with grid, red-eye, rotate, I'm
  Feeling Lucky / auto contrast / auto colour, tuning, nine effects,
  undo/redo/revert, Esc/Enter/⌘Z shortcuts.
- ✅ Viewer shows edited images (badge on thumbnails); rename/move/copy carry
  edits; saving a rotation of an edited image becomes a rotate edit.
- ✅ Export (JPEG/PNG, size, quality, camera EXIF kept, never overwrites) for
  one image or a selection; quick fixes and Remove edits on a selection.
- Deferred / not done:
  - Not tried by hand in the running app yet — covered by unit and widget tests.
  - Edited images are shown at up to 2560 px in the viewer, so 1:1 zoom on an
    edited photo is slightly soft; export is full size.
  - Film grain and blur-based effects scale with resolution, so they look a
    little different between preview and full-size export.
  - Tint, focal B&W, graduated tint, neutral-colour picker, text overlay,
    retouch/spot-heal, slider for re-editing an applied tuning step.
  - Edits of images moved to the Trash stay in the sidecar (harmless; restored
    images get them back). Renames done outside Picavi orphan their edits.
  - Export options are remembered only until Picavi quits.

### Phase 3 — Library (v2.0, ~8–10 weeks) — architecture shift
- New feature module `lib/library/`.
- Local catalog DB (SQLite via `drift` or `sqflite_common_ffi`) + background
  indexer isolate + disk thumbnail cache.
- Watched-folder settings, folder tree sidebar, grid view, timeline.
- Stars, tags, captions (XMP write-back optional), albums, hide, search.
- Duplicate finder.
- The current viewer becomes the "open one image" mode *and* the detail view of the library.

### Phase 4 — Advanced (v2.x)
- Places (map + GPS), People (faces, macOS first), collage, print,
  import from device, share sheet, video playback, movie export.

## Decisions needed before Phase 2/3
1. ~~**Sidecar format**~~ — decided: JSON (`.picavi.json`); XMP later if needed.
2. **Catalog DB** — `drift` (typed, codegen) vs. raw `sqflite_common_ffi`.
3. **Platform priority** — macOS-first native features, or parity on all three each release?
4. **Scope of "library"** — opt-in watched folders, or keep Picavi a pure viewer and stop at Phase 2?
