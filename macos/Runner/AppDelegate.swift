import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var pendingOpenFiles: [String] = []

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    DispatchQueue.main.async { [weak self] in
      self?.configureMainWindowIfNeeded()
    }
  }

  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    queueOrOpenFiles(filenames)
    sender.reply(toOpenOrPrint: .success)
  }

  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    application(sender, openFiles: [filename])
    return true
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    queueOrOpenFiles(urls.map(\.path))
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

  private func configureMainWindowIfNeeded() {
    guard let window = mainFlutterWindow as? MainFlutterWindow else {
      return
    }

    window.configureFileOpenChannelIfNeeded()
    flushPendingOpenFilesIfNeeded(to: window)
  }

  private func queueOrOpenFiles(_ filenames: [String]) {
    let normalizedFiles = filenames.filter { !$0.isEmpty }
    guard !normalizedFiles.isEmpty else {
      return
    }

    if let window = mainFlutterWindow as? MainFlutterWindow {
      window.handleOpenFiles(normalizedFiles)
      return
    }

    pendingOpenFiles.append(contentsOf: normalizedFiles)

    DispatchQueue.main.async { [weak self] in
      self?.configureMainWindowIfNeeded()
    }
  }

  private func flushPendingOpenFilesIfNeeded(to window: MainFlutterWindow) {
    guard !pendingOpenFiles.isEmpty else {
      return
    }

    let filenames = pendingOpenFiles
    pendingOpenFiles.removeAll()
    window.handleOpenFiles(filenames)
  }
}
