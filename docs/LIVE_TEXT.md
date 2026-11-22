# Live Text (select text in images)

Goal: hover over text in a photo and get an I-beam cursor, drag to select it,
Cmd+C to copy. This is what Preview and Photos do on macOS.

## Options considered

| Approach | Verdict |
|---|---|
| **VisionKit `ImageAnalysisOverlayView`** (the real Preview overlay, macOS 13+) hosted with Flutter's `AppKitView` platform view | Rejected. The overlay is an `NSView` that must track our Flutter-drawn image through zoom, pan, view-only rotation and the image cross-fade. Its frame would have to be synced over a channel every frame, which lags. macOS platform views have limited gesture forwarding, and Flutter warns they are expensive. It also clashes with the transparent window and with Flutter widgets drawn above it (control bar, thumbnail rail). The text accessors (`text`, `selectedText`) need macOS 14. |
| **VisionKit `ImageAnalyzer` only** | Rejected. It gives a transcript but no public line or word geometry, so we can't draw our own selection. |
| **Vision `VNRecognizeTextRequest`, with the selection UI drawn in Flutter** | **Chosen.** This is the same on-device engine Live Text uses, and it works on our macOS 12 minimum. It returns lines as quads (rotated text works) plus per-range boxes. We draw the overlay *inside* `InteractiveImageViewer`'s transform, so zoom, pan, rotation and animations line up for free. The UI is ours: it matches the theme, it is testable with fakes, and Windows (`Windows.Media.Ocr`) and Linux (Tesseract) can plug in behind the same interface later. |

Trade-offs of the chosen approach: we don't get VisionKit's extras (Look Up,
Translate, data detectors) for free, and selection snaps to words rather than
characters. Hindi and Marathi (Devanagari) aren't among Vision's recognition
languages; English, Spanish, Chinese and Arabic are.

## Design

- **Native** (`MainFlutterWindow.swift`, channel method `recognizeText`).
  Input is either `{path}` (decoded with ImageIO, EXIF orientation applied, so
  coordinates match what the viewer shows) or `{rgba, width, height}` (an
  edited image rendered by the edit pipeline). Runs `VNRecognizeTextRequest`
  (accurate, language correction, automatic language detection on 13+) off
  the main thread. Returns lines with normalized quads (top-left origin,
  TL/TR/BR/BL) and whitespace-delimited words with UTF-16 ranges and quads.
  When Vision returns the whole line's box for a word, the word box is
  interpolated along the line quad instead.
- **Domain** `viewer/domain`: `RecognizedText` → `RecognizedTextLine` →
  `RecognizedWord` (pure Dart), `TextRecognitionSource` (file or pixels),
  `TextRecognitionService` interface.
- **Data** `viewer/data/services/vision_text_recognition_service.dart`: channel
  call plus a parser. Unsupported platforms and errors return `null` (fail
  soft).
- **Presentation**
  - `LiveTextController` (ChangeNotifier): runs recognition for the current
    image (keyed by path, revision and edits), caches a few results, drops
    stale responses, and holds the word selection (`selectedText`,
    `selectAll`, `clearSelection`).
  - `LiveTextOverlay`: sized to the fitted image. It is hit-testable only
    over words, so panning elsewhere still works. Over text it shows an I-beam
    cursor and wins the gesture arena: drag selects, double-click selects a
    word, triple-click a line, a click clears. It paints the highlights.
  - `InteractiveImageViewer.overlayBuilder(context, fittedSize)`: drawn
    inside the transform, outside the image cross-fade.

## Integration steps

1. ✅ Native `recognizeText`, domain/data, controller, overlay, viewer hook, tests.
2. Wire into `ViewerScreen`: own a `LiveTextController`, trigger analysis
   when the current image changes and settles (debounced), pass
   `overlayBuilder`, clear the selection on navigation, Escape and slideshow.
   Disable it during slideshow.
3. Cmd+C copies the selected text when there is a selection, otherwise the
   image. Add a right-click menu (Copy Text, Select All Text). Update
   `keyboard_shortcuts_dialog.dart`.
4. Settings toggle "Select text in images" (default on, macOS only) in
   `AppPreferencesService` + `SettingsScreen`; strings in all ARB files.
5. Optional: a subtle "text found" indicator in the control bar, and Cmd+A
   selects all text while text is selected.
6. Later: Windows `Windows.Media.Ocr`, Linux Tesseract, and VisionKit
   extras (Look Up, data detectors) via a native menu.
