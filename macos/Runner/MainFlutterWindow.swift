import Cocoa
import CoreServices
import ImageIO
import UniformTypeIdentifiers
import Vision
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let fileOpenChannelName = "com.gyanoba.oiv/file_open"
  // Keep in sync with lib/viewer/domain/constants/supported_image_extensions.dart.
  private let supportedImageExtensions = [
    "avif", "bmp", "gif", "heic", "heif", "ico", "jpeg", "jpg", "png", "svg", "tif", "tiff", "webp",
  ]
  /// Long-edge cap for full-size native decodes (fits 48 MP photos).
  private let maxDecodedPixelSize = 8192
  private var pendingFiles: [String] = []
  private var fileOpenChannel: FlutterMethodChannel?
  private var activeSecurityScopedURLs: [URL] = []

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.isOpaque = false
    self.hasShadow = true
    self.backgroundColor = .clear
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)
    self.collectionBehavior.insert(.fullScreenPrimary)

    flutterViewController.backgroundColor = .clear
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor
    self.contentView?.wantsLayer = true
    self.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

    RegisterGeneratedPlugins(registry: flutterViewController)
    configureFileOpenChannelIfNeeded(with: flutterViewController)

    super.awakeFromNib()
  }

  func configureFileOpenChannelIfNeeded(
    with flutterViewController: FlutterViewController? = nil
  ) {
    if fileOpenChannel != nil {
      return
    }

    let resolvedController = flutterViewController ?? resolveFlutterViewController()
    guard let resolvedController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: fileOpenChannelName,
      binaryMessenger: resolvedController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result([])
        return
      }

      switch call.method {
      case "consumePendingFiles":
        let files = self.pendingFiles
        self.pendingFiles.removeAll()
        result(files)
      case "getDefaultViewerStatus":
        self.resolveDefaultViewerStatus(result: result)
      case "setAsDefaultViewer":
        self.setAsDefaultViewer(result: result)
      case "pickImageFile":
        self.presentImageOpenPanel(arguments: call.arguments, result: result)
      case "authorizeDirectoryAccess":
        self.presentDirectoryAccessPanel(arguments: call.arguments, result: result)
      case "decodeImage":
        self.decodeImage(arguments: call.arguments, result: result)
      case "moveToTrash":
        self.moveToTrash(arguments: call.arguments, result: result)
      case "revealInFinder":
        self.revealInFinder(arguments: call.arguments, result: result)
      case "copyImageToClipboard":
        self.copyImageToClipboard(arguments: call.arguments, result: result)
      case "openWith":
        self.presentOpenWithPanel(arguments: call.arguments, result: result)
      case "recognizeText":
        self.recognizeText(arguments: call.arguments, result: result)
      case "shareFiles":
        self.shareFiles(arguments: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    fileOpenChannel = channel
  }

  func handleOpenFiles(_ filenames: [String]) {
    configureFileOpenChannelIfNeeded()
    filenames.forEach { startAccessingSecurityScope(for: URL(fileURLWithPath: $0)) }
    pendingFiles.append(contentsOf: filenames)
    fileOpenChannel?.invokeMethod("openFiles", arguments: filenames)
  }

  func cleanupSecurityScopes() {
    activeSecurityScopedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
    activeSecurityScopedURLs.removeAll()
  }

  private func presentImageOpenPanel(arguments: Any?, result: @escaping FlutterResult) {
    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false
    panel.allowedFileTypes = supportedImageExtensions
    panel.prompt = stringValue(forKey: "prompt", arguments: arguments) ?? "Open viewer"
    panel.directoryURL = directoryURL(from: arguments)

    present(panel: panel) { [weak self] response in
      guard response == .OK, let url = panel.url else {
        result(nil)
        return
      }

      self?.startAccessingSecurityScope(for: url)
      result(url.path)
    }
  }

  private func presentDirectoryAccessPanel(arguments: Any?, result: @escaping FlutterResult) {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.prompt = stringValue(forKey: "prompt", arguments: arguments) ?? "Grant folder access"
    panel.message = stringValue(forKey: "message", arguments: arguments) ?? "Allow Picavi to read sibling images in this folder."
    panel.directoryURL = directoryURL(from: arguments)

    present(panel: panel) { [weak self] response in
      guard response == .OK, let url = panel.url else {
        result(nil)
        return
      }

      self?.startAccessingSecurityScope(for: url)
      result(url.path)
    }
  }

  private func fileURL(from arguments: Any?) -> URL? {
    guard let path = stringValue(forKey: "path", arguments: arguments) else {
      return nil
    }

    return URL(fileURLWithPath: path)
  }

  /// Decodes formats Flutter can't (HEIC, AVIF, TIFF) with ImageIO, applying
  /// EXIF orientation, and returns JPEG bytes (PNG when there is alpha).
  private func decodeImage(arguments: Any?, result: @escaping FlutterResult) {
    guard let url = fileURL(from: arguments) else {
      result(nil)
      return
    }

    let requestedSize = (arguments as? [String: Any])?["maxPixelSize"] as? Int
    let maxDecodedPixelSize = self.maxDecodedPixelSize

    DispatchQueue.global(qos: .userInitiated).async {
      let encoded = Self.decodeWithImageIO(
        url: url,
        maxPixelSize: requestedSize,
        cap: maxDecodedPixelSize
      )
      DispatchQueue.main.async {
        result(encoded.map { FlutterStandardTypedData(bytes: $0) })
      }
    }
  }

  private static func decodeWithImageIO(url: URL, maxPixelSize: Int?, cap: Int) -> Data? {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
      return nil
    }

    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    var longEdge = maxPixelSize ?? cap
    if maxPixelSize == nil,
       let width = properties?[kCGImagePropertyPixelWidth] as? Int,
       let height = properties?[kCGImagePropertyPixelHeight] as? Int {
      longEdge = min(max(width, height), cap)
    }

    let thumbnailOptions = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceThumbnailMaxPixelSize: max(1, longEdge),
    ] as CFDictionary
    guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
      return nil
    }

    // Use the file's own flag. ImageIO sets HasAlpha only when the image
    // really has transparency, while the decoded thumbnail usually carries an
    // alpha channel even for opaque photos (PNG-encoding those would be slow
    // and huge).
    let hasAlpha = (properties?[kCGImagePropertyHasAlpha] as? Bool) ?? false

    let output = NSMutableData()
    let type = (hasAlpha ? UTType.png : UTType.jpeg).identifier as CFString
    guard let destination = CGImageDestinationCreateWithData(output, type, 1, nil) else {
      return nil
    }
    let destinationOptions = [kCGImageDestinationLossyCompressionQuality: 0.92] as CFDictionary
    CGImageDestinationAddImage(destination, image, hasAlpha ? nil : destinationOptions)
    guard CGImageDestinationFinalize(destination) else {
      return nil
    }
    return output as Data
  }

  /// Live Text: finds text with Vision and returns lines and words with
  /// normalized quads (top-left origin) matching the image as displayed.
  private func recognizeText(arguments: Any?, result: @escaping FlutterResult) {
    let dictionary = arguments as? [String: Any]
    let url = fileURL(from: arguments)
    let rgba = dictionary?["rgba"] as? FlutterStandardTypedData
    let width = dictionary?["width"] as? Int ?? 0
    let height = dictionary?["height"] as? Int ?? 0

    DispatchQueue.global(qos: .userInitiated).async {
      var image: CGImage?
      if let rgba {
        image = Self.cgImage(rgba: rgba.data, width: width, height: height)
      } else if let url {
        image = Self.cgImageForTextRecognition(url: url)
      }
      let lines = image.flatMap { LiveTextRecognizer.recognize(in: $0) }
      DispatchQueue.main.async {
        result(lines.map { ["lines": $0] })
      }
    }
  }

  private static func cgImageForTextRecognition(url: URL) -> CGImage? {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
      return nil
    }
    let options = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceThumbnailMaxPixelSize: 4096,
    ] as CFDictionary
    return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
  }

  private static func cgImage(rgba: Data, width: Int, height: Int) -> CGImage? {
    guard width > 0, height > 0, rgba.count >= width * height * 4,
          let provider = CGDataProvider(data: rgba as CFData) else {
      return nil
    }
    return CGImage(
      width: width,
      height: height,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: width * 4,
      space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  }

  /// Shows the system share menu for `paths`, pointing at the rectangle
  /// (Flutter logical coordinates, top-left origin) of the button that asked.
  private func shareFiles(arguments: Any?, result: FlutterResult) {
    guard let arguments = arguments as? [String: Any],
          let paths = arguments["paths"] as? [String],
          let view = contentViewController?.view else {
      result(false)
      return
    }
    let urls = paths
      .map { URL(fileURLWithPath: $0) }
      .filter { FileManager.default.fileExists(atPath: $0.path) }
    guard !urls.isEmpty else {
      result(false)
      return
    }

    func number(_ key: String) -> CGFloat {
      CGFloat((arguments[key] as? NSNumber)?.doubleValue ?? 0)
    }
    let width = max(number("width"), 1)
    let height = max(number("height"), 1)
    let top = number("top")
    let y = view.isFlipped ? top : view.bounds.height - top - height
    let anchor = NSRect(x: number("left"), y: y, width: width, height: height)

    let picker = NSSharingServicePicker(items: urls)
    picker.show(relativeTo: anchor, of: view, preferredEdge: .minY)
    result(true)
  }

  private func moveToTrash(arguments: Any?, result: FlutterResult) {
    guard let url = fileURL(from: arguments) else {
      result(false)
      return
    }

    do {
      try FileManager.default.trashItem(at: url, resultingItemURL: nil)
      result(true)
    } catch {
      result(false)
    }
  }

  private func revealInFinder(arguments: Any?, result: FlutterResult) {
    guard let url = fileURL(from: arguments),
          FileManager.default.fileExists(atPath: url.path) else {
      result(false)
      return
    }

    NSWorkspace.shared.activateFileViewerSelecting([url])
    result(true)
  }

  private func copyImageToClipboard(arguments: Any?, result: FlutterResult) {
    guard let url = fileURL(from: arguments),
          let image = NSImage(contentsOf: url) else {
      result(false)
      return
    }

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    result(pasteboard.writeObjects([image]))
  }

  private func presentOpenWithPanel(arguments: Any?, result: @escaping FlutterResult) {
    guard let fileURL = fileURL(from: arguments) else {
      result(false)
      return
    }

    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false
    panel.treatsFilePackagesAsDirectories = false
    panel.allowedContentTypes = [.application]
    panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
    panel.prompt = stringValue(forKey: "prompt", arguments: arguments) ?? "Open"

    present(panel: panel) { response in
      guard response == .OK, let applicationURL = panel.url else {
        result(false)
        return
      }

      NSWorkspace.shared.open(
        [fileURL],
        withApplicationAt: applicationURL,
        configuration: NSWorkspace.OpenConfiguration()
      ) { _, error in
        DispatchQueue.main.async {
          result(error == nil)
        }
      }
    }
  }

  private func present(
    panel: NSOpenPanel,
    completion: @escaping (NSApplication.ModalResponse) -> Void
  ) {
    panel.beginSheetModal(for: self, completionHandler: completion)
  }

  private func resolveDefaultViewerStatus(result: FlutterResult) {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
      result(["isDefault": false, "isSupported": false])
      return
    }

    let contentTypes = resolvedImageContentTypes()
    guard !contentTypes.isEmpty else {
      result(["isDefault": false, "isSupported": false])
      return
    }

    let isDefault = contentTypes.allSatisfy { contentType in
      guard let handler = LSCopyDefaultRoleHandlerForContentType(
        contentType as CFString,
        .viewer
      )?.takeRetainedValue() as String? else {
        return false
      }

      return handler == bundleIdentifier
    }

    result(["isDefault": isDefault, "isSupported": true])
  }

  private func setAsDefaultViewer(result: FlutterResult) {
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
      result(false)
      return
    }

    let contentTypes = resolvedImageContentTypes()
    guard !contentTypes.isEmpty else {
      result(false)
      return
    }

    let statuses = contentTypes.map {
      LSSetDefaultRoleHandlerForContentType(
        $0 as CFString,
        .viewer,
        bundleIdentifier as CFString
      )
    }
    result(statuses.allSatisfy { $0 == noErr })
  }

  private func resolveFlutterViewController() -> FlutterViewController? {
    return contentViewController as? FlutterViewController
  }

  private func directoryURL(from arguments: Any?) -> URL? {
    guard let dictionary = arguments as? [String: Any],
          let path = dictionary["initialDirectory"] as? String,
          !path.isEmpty else {
      return nil
    }

    return URL(fileURLWithPath: path, isDirectory: true)
  }

  private func stringValue(forKey key: String, arguments: Any?) -> String? {
    guard let dictionary = arguments as? [String: Any],
          let value = dictionary[key] as? String,
          !value.isEmpty else {
      return nil
    }

    return value
  }

  private func startAccessingSecurityScope(for url: URL) {
    if url.startAccessingSecurityScopedResource() {
      activeSecurityScopedURLs.append(url)
    }

    let parentDirectoryURL = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
    if parentDirectoryURL != url, parentDirectoryURL.startAccessingSecurityScopedResource() {
      activeSecurityScopedURLs.append(parentDirectoryURL)
    }
  }

  private func resolvedImageContentTypes() -> [String] {
    var contentTypes: [String] = []

    for pathExtension in supportedImageExtensions {
      guard let unmanagedContentType = UTTypeCreatePreferredIdentifierForTag(
        kUTTagClassFilenameExtension,
        pathExtension as CFString,
        nil
      ) else {
        continue
      }

      let contentType = unmanagedContentType.takeRetainedValue() as String
      if !contentTypes.contains(contentType) {
        contentTypes.append(contentType)
      }
    }

    return contentTypes
  }
}

/// On-device text recognition for Live Text. Quads are flat
/// `[tlx, tly, trx, try, brx, bry, blx, bly]`, normalized to the image with a
/// top-left origin. Word ranges are UTF-16 offsets into the line text (what
/// Dart strings index by).
enum LiveTextRecognizer {
  static func recognize(in image: CGImage) -> [[String: Any]]? {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    if #available(macOS 13.0, *) {
      request.automaticallyDetectsLanguage = true
    }

    let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
    do {
      try handler.perform([request])
    } catch {
      NSLog("Picavi: text recognition failed: \(error)")
      return nil
    }

    return (request.results ?? []).compactMap { observation in
      guard let candidate = observation.topCandidates(1).first else {
        return nil
      }
      let text = candidate.string
      guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return nil
      }

      let lineQuad = quad(of: observation)
      let ranges = wordRanges(in: text)
      let totalLength = max(1, text.utf16.count)
      let words: [[String: Any]] = ranges.map { range in
        let start = text.utf16.distance(from: text.startIndex, to: range.lowerBound)
        let end = text.utf16.distance(from: text.startIndex, to: range.upperBound)
        var wordQuad: [Double]?
        if let box = try? candidate.boundingBox(for: range) {
          let measured = quad(of: box)
          // Accurate recognition sometimes reports the whole line for every
          // range; spread the line across its characters instead.
          if ranges.count == 1 || !isSameQuad(measured, lineQuad) {
            wordQuad = measured
          }
        }
        return [
          "start": start,
          "end": end,
          "quad": wordQuad ?? interpolate(
            lineQuad,
            from: Double(start) / Double(totalLength),
            to: Double(end) / Double(totalLength)
          ),
        ]
      }

      return ["text": text, "quad": lineQuad, "words": words]
    }
  }

  private static func quad(of observation: VNRectangleObservation) -> [Double] {
    let corners: [CGPoint] = [
      observation.topLeft, observation.topRight, observation.bottomRight, observation.bottomLeft,
    ]
    var values: [Double] = []
    for corner in corners {
      values.append(Double(corner.x))
      values.append(1 - Double(corner.y))
    }
    return values
  }

  /// Runs of non-whitespace characters, so punctuation stays with its word.
  private static func wordRanges(in text: String) -> [Range<String.Index>] {
    var ranges: [Range<String.Index>] = []
    var wordStart: String.Index?
    var index = text.startIndex
    while index < text.endIndex {
      let isSpace = text[index].isWhitespace
      if isSpace, let start = wordStart {
        ranges.append(start..<index)
        wordStart = nil
      } else if !isSpace, wordStart == nil {
        wordStart = index
      }
      index = text.index(after: index)
    }
    if let start = wordStart {
      ranges.append(start..<text.endIndex)
    }
    return ranges
  }

  private static func isSameQuad(_ a: [Double], _ b: [Double]) -> Bool {
    zip(a, b).allSatisfy { abs($0 - $1) < 0.002 }
  }

  private static func interpolate(_ line: [Double], from t0: Double, to t1: Double) -> [Double] {
    func lerp(_ a: Int, _ b: Int, _ t: Double) -> [Double] {
      [line[a] + (line[b] - line[a]) * t, line[a + 1] + (line[b + 1] - line[a + 1]) * t]
    }
    // Top edge runs TL(0) → TR(2), bottom edge BL(6) → BR(4).
    return lerp(0, 2, t0) + lerp(0, 2, t1) + lerp(6, 4, t1) + lerp(6, 4, t0)
  }
}
