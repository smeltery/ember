import AppKit
import EmberCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private var controller: StatusItemController?

  func applicationDidFinishLaunching(_ notification: Notification) {
    controller = StatusItemController()
    controller?.start()
  }

  func applicationWillTerminate(_ notification: Notification) {
    controller?.stop()
  }
}
