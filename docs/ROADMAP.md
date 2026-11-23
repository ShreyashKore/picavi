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
| Watched folders + indexer | ✅ Done in Phase 3 (rescans on open; no live watching yet) |
| Folder tree sidebar | ✅ |
| Grid / lightbox view | ✅ With size slider |
| Timeline | ✅ Grouped by month; year/day zoom levels still to do |
| Search | ✅ Name, folder, date, camera, caption, tag |
| Star / favourite, tags, captions | ✅ In the `.picavi.json` sidecar; XMP write-back still to do |
| Albums | ✅ |
| Hide folders / images | ✅ |
| Duplicate finder | ✅ Exact (byte-identical); similar-looking (perceptual hash) still to do |
| Disk thumbnail cache | ✅ |

### 5. Advanced (Picasa's "wow" features)
| Gap | Notes |
|---|---|
| Places | ✅ Done in Phase 4 (GPS map + setting locations by hand) |
| People | ✅ macOS: Vision face detection, look-alike grouping, naming with suggestions |
| Collage maker | ✅ Mosaic / grid / contact sheet |
| Movie maker | Slideshow → video export |
| Print & contact sheets | ✅ 1/2/4/9 per page; contact sheets via the collage maker |
| Import | ✅ From camera / SD card into date-based folders |
| Share / email | ✅ macOS share menu |

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

### Phase 3 — Library (v2.0) — ✅ done
- ✅ New feature module `lib/library/`, opt-in: Picavi stays a plain viewer
  until you add a folder to the library.
- ✅ Catalog in SQLite via the `sqlite3` package (decision 2: plain SQL, no
  codegen; SQLite is bundled by its build hook on every platform). The catalog
  is a rebuildable cache in the app support folder; only albums live solely
  there.
- ✅ Stars, captions, tags and the hidden flag live in the per-folder
  `.picavi.json` next to the edits (one `PicaviSidecarStore` owns the file), so
  they travel with the photos like Picasa's `.picasa.ini`. Viewer: `S` to star,
  Caption and tags…, Hide from library.
- ✅ Indexer in background isolates: skips hidden folders and links, reads
  EXIF date and camera only for new/changed files and only the first 256 KB.
- ✅ Disk thumbnail cache (360 px JPEG, keyed by path + size + mtime + edits).
- ✅ Library screen (`L`): All photos by month, Starred, albums, folder tree,
  search, size slider, selection bar (star, album, hide), show hidden,
  rescan; double-click opens the photo in the viewer with its folder.
- ✅ Albums (create, rename, delete, add/remove) and an exact duplicate finder
  that only ever moves extra copies to the Trash.
- Deferred / not done:
  - Not tried by hand in the running app yet — covered by unit and widget tests.
  - No live folder watching for the library: it rescans when opened or on
    Rescan. Changes made in the viewer reach the library on the next scan.
  - XMP write-back of stars/captions/tags; similar-looking duplicates
    (perceptual hash); timeline year/day levels; library multi-select file
    actions (copy/move/trash/export) — use the viewer for those for now.
  - Album entries for photos moved or renamed outside Picavi are dropped.
  - The thumbnail cache is never pruned (Settings has no "clear" yet).
  - HEIC/AVIF/TIFF dates come from the file date unless their EXIF sits in
    the first 256 KB.
  - Catalog queries run on the UI isolate (fast for tens of thousands of
    photos; move to a worker isolate if libraries get much bigger).

### Phase 4 — Advanced (v2.x) — in progress
- ✅ Share sheet: Share… in the viewer menu and library selection bar opens
  the macOS share menu (`shareFiles` channel method). Hidden on Windows/Linux.
- ✅ Import: Library → Import photos finds cameras/cards (volumes with a DCIM
  folder) or any folder, pre-selects new photos, copies them into
  `<destination>/<year>/<year-month-day>` by date taken, skips ones already
  there, never overwrites and never touches the card. The destination
  (default ~/Pictures) is remembered and added to the library.
- ✅ Collage maker (`lib/collage/`): mosaic (justified rows), grid, and A4
  contact sheets with file names; edits applied; new JPEGs, never overwritten.
- ✅ Places: EXIF GPS indexed (catalog schema v2, upgraded in place); a
  location set by hand lives in the sidecar (`location`) and wins over GPS;
  Library → Places clusters photos on an OpenStreetMap map (`flutter_map`).
  Tiles load only while the map or the location picker is open.
- ✅ Print (`lib/print_photos/`): 1/2/4/9 photos per page with edits applied,
  through the system print dialog (`printing` package).
- ✅ People (macOS): native `detectFaces` (Vision) returns face boxes, a
  160 px crop and a feature print per face. Catalog schema v3 stores faces;
  names live in the sidecar (`people: [{name, box}]`) and are matched back to
  rescanned faces by overlap, so they survive a rebuilt catalog. Library →
  People scans in the background, groups unnamed faces by likeness, names
  groups or picked faces, ignores faces, renames/merges/forgets people, and
  offers "Is this …?" suggestions. Names are searchable and shown in the
  viewer's info panel. Vision's feature print is a general image fingerprint,
  not face identity, so groups and suggestions are guesses for the user to
  confirm; the thresholds (`face_grouping.dart`) are strict and untuned.
- Not started — each needs a decision first:
  - **Video playback.** `video_player` is solid on macOS only;
    `media_kit` covers all three platforms but bundles libmpv (large).
  - **Movie maker.** Slideshow → MP4 via AVAssetWriter (macOS) or ffmpeg.
- Deferred in the finished items: People on Windows/Linux, re-checking
  rejected suggestions after a restart (rejections last one session), and
  tuning the face thresholds on real photos; share on Windows/Linux; import doesn't
  read EXIF of HEIC beyond the first 256 KB (uses the file date); map tiles
  aren't cached offline; Places has no "set location" in the viewer yet;
  contact-sheet captions use a built-in font with ASCII only, so other scripts
  show as gaps.
- Not tried by hand in the running app yet — covered by unit and widget tests.

## Decisions
1. ~~**Sidecar format**~~ — decided: JSON (`.picavi.json`); XMP later if needed.
2. ~~**Catalog DB**~~ — decided: `sqlite3` package, plain SQL.
3. **Platform priority** — macOS-first native features, or parity on all three each release?
   (Phases 3–4 are mostly Dart and work everywhere; share is macOS-only so far.)
4. ~~**Scope of "library"**~~ — decided: opt-in watched folders.
