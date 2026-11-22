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
| File operations | Delete (to Trash), rename, copy/move to folder, reveal in Finder/Explorer, copy image to clipboard, "Open with…" external editor, set as wallpaper |
| Persisted rotation | Rotate is view-only; Picasa saved it (lossless JPEG rotate / EXIF orientation) |
| Slideshow options | Fixed 3 s, no interval setting, shuffle, loop, transitions, or hide-UI mode |
| Fit modes | Fit / fill / actual size toggle, zoom-to-fit-width; fullscreen toggle (`F`) |
| Compare view | Picasa's 2-up side-by-side compare |
| Drag & drop | Drop a file/folder onto the window to open; drag an image out to other apps |
| Folder watching | ✅ Done in Phase 0 |
| Sort options | ✅ Name, modified, size, type done; date taken still to do |
| Histogram | Picasa showed a live histogram in the info pane |
| Shortcut help | ✅ `?` overlay added; still missing file shortcuts like `Del` (Phase 1) |
| Multi-select ("Picture Tray") | Can't select several images to act on them together |

### 2. Formats
| Gap | Notes |
|---|---|
| HEIC/HEIF, AVIF, TIFF | Very common today (iPhone photos); need native decode (macOS ImageIO) or a plugin |
| RAW (CR2/NEF/ARW/DNG) | At least show the embedded JPEG preview |
| Video | Picasa listed and played videos alongside photos |

### 3. Editing (Picasa's "Basic Fixes / Tuning / Effects")
| Gap | Notes |
|---|---|
| Crop & straighten | With aspect presets (4×6, 5×7, 16:9, square) |
| One-click fixes | "I'm Feeling Lucky", auto-contrast, auto-colour, red-eye |
| Tuning sliders | Fill light, highlights, shadows, colour temperature |
| Effects | B&W, sepia, sharpen, warmify, film grain, tint, saturation, soft focus, glow, focal B&W, graduated tint |
| Text / retouch | Caption text overlay, spot-heal |
| Non-destructive edits + Revert | Picasa stored edits in `.picasa.ini` and never touched the original until "Save" |
| Export | Save-as with resize, quality, format; batch export |
| Batch edit | Apply rotate/fix/effect to a selection |

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

### Phase 1 — Viewer essentials (v1.1, ~3–4 weeks)
- `FileOperationsService` interface in `domain/`, impl in `data/`:
  trash, rename, copy/move, reveal, clipboard, open-with (macOS native channel first).
- Persist rotation (EXIF orientation write / lossless JPEG transform).
- Slideshow settings (interval, shuffle, loop, fade transition) in Settings.
- Fit modes, fullscreen toggle, drag-and-drop in/out.
- Multi-select in the rail ("tray") — prerequisite for batch actions later.
- HEIC/TIFF/AVIF via macOS ImageIO over the existing method channel.

### Phase 2 — Editor (v1.2, ~6 weeks)
- New feature module `lib/editor/` (domain/data/presentation).
- Edit model = ordered list of operations, serialised to a sidecar
  (`.picavi.json` per folder, analogous to `.picasa.ini`) → non-destructive + Revert.
- Preview via `ColorFilter`/shaders on the GPU; final render in an isolate
  (`package:image`).
- Order: crop/straighten → auto-fix → tuning sliders → effects → red-eye → export/batch.

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
1. **Sidecar format** — Picavi-only JSON vs. XMP (interoperable, more work).
2. **Catalog DB** — `drift` (typed, codegen) vs. raw `sqflite_common_ffi`.
3. **Platform priority** — macOS-first native features, or parity on all three each release?
4. **Scope of "library"** — opt-in watched folders, or keep Picavi a pure viewer and stop at Phase 2?
