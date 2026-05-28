import Cocoa
import CoreServices
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let fileOpenChannelName = "com.gyanoba.oiv/file_open"
  private let supportedImageExtensions = ["bmp", "gif", "ico", "jpeg", "jpg", "png", "svg", "webp"]
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
    panel.allowedFileTypes = ["bmp", "gif", "ico", "jpeg", "jpg", "png", "svg", "webp"]
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
