import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let fileOpenChannelName = "com.gyanoba.oiv/file_open"
  private var pendingFiles: [String] = []
  private var fileOpenChannel: FlutterMethodChannel?

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
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    fileOpenChannel = channel
  }

  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    pendingFiles.append(contentsOf: filenames)
    fileOpenChannel?.invokeMethod("openFiles", arguments: filenames)
    sender.reply(toOpenOrPrint: .success)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
