import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    DispatchQueue.main.async { [weak self] in
      (self?.mainFlutterWindow as? MainFlutterWindow)?
        .configureFileOpenChannelIfNeeded()
    }
  }

  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    if let window = mainFlutterWindow as? MainFlutterWindow {
      window.handleOpenFiles(filenames)
    } else {
      DispatchQueue.main.async { [weak self] in
        (self?.mainFlutterWindow as? MainFlutterWindow)?.handleOpenFiles(filenames)
      }
    }
    sender.reply(toOpenOrPrint: .success)
  }

  override func applicationWillTerminate(_ notification: Notification) {
    (mainFlutterWindow as? MainFlutterWindow)?.cleanupSecurityScopes()
    super.applicationWillTerminate(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
