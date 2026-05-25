import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let fileOpenChannelName = "com.gyanoba.oiv/file_open"
  private var pendingFiles: [String] = []
  private var fileOpenChannel: FlutterMethodChannel?
  private var activeSecurityScopedURLs: [URL] = []

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    guard let flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: fileOpenChannelName,
      binaryMessenger: flutterViewController.engine.binaryMessenger
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

  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    filenames.forEach { self.startAccessingSecurityScope(for: URL(fileURLWithPath: $0)) }
    pendingFiles.append(contentsOf: filenames)
    fileOpenChannel?.invokeMethod("openFiles", arguments: filenames)
    sender.reply(toOpenOrPrint: .success)
  }

  override func applicationWillTerminate(_ notification: Notification) {
    activeSecurityScopedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
    activeSecurityScopedURLs.removeAll()
    super.applicationWillTerminate(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  private func presentImageOpenPanel(arguments: Any?, result: @escaping FlutterResult) {
    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false
    panel.allowedFileTypes = ["bmp", "gif", "ico", "jpeg", "jpg", "png", "webp"]
    panel.prompt = "Open viewer"
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
    panel.prompt = "Grant folder access"
    panel.message = "Allow Picavi to read sibling images in this folder."
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

  private func present(panel: NSOpenPanel, completion: @escaping (NSApplication.ModalResponse) -> Void) {
    if let window = mainFlutterWindow {
      panel.beginSheetModal(for: window, completionHandler: completion)
    } else {
      completion(panel.runModal())
    }
  }

  private func directoryURL(from arguments: Any?) -> URL? {
    guard let dictionary = arguments as? [String: Any],
          let path = dictionary["initialDirectory"] as? String,
          !path.isEmpty else {
      return nil
    }

    return URL(fileURLWithPath: path, isDirectory: true)
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
}
