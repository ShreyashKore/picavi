import Cocoa
import CoreServices
import ImageIO
import UniformTypeIdentifiers
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
