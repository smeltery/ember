import AppKit
import EmberCore
import SwiftUI

@MainActor
enum EmberSettings {
  private static let cutoffKey = "batteryCutoff"
  private static let pluggedKey = "onlyWhenPluggedIn"

  static var batteryCutoff: Int {
    get {
      let v = UserDefaults.standard.object(forKey: cutoffKey) as? Int
      return v ?? BatteryPolicy.default.cutoffPercent
    }
    set { UserDefaults.standard.set(newValue, forKey: cutoffKey) }
  }

  static var onlyWhenPluggedIn: Bool {
    get { UserDefaults.standard.bool(forKey: pluggedKey) }
    set { UserDefaults.standard.set(newValue, forKey: pluggedKey) }
  }

  static var policy: BatteryPolicy {
    BatteryPolicy(
      cutoffPercent: batteryCutoff,
      onlyWhenPluggedIn: onlyWhenPluggedIn,
      respectLowPowerMode: true,
      displayOffWhileWorking: false
    )
  }

  static func makeWindow() -> NSWindow {
    let root = SettingsView(
      cutoff: Binding(
        get: { batteryCutoff },
        set: { batteryCutoff = $0 }
      ),
      onlyPlugged: Binding(
        get: { onlyWhenPluggedIn },
        set: { onlyWhenPluggedIn = $0 }
      )
    )
    let hosting = NSHostingController(rootView: root)
    let window = NSWindow(contentViewController: hosting)
    window.title = "ember Settings"
    window.styleMask = [.titled, .closable]
    window.setContentSize(NSSize(width: 360, height: 160))
    window.center()
    return window
  }
}

private struct SettingsView: View {
  @Binding var cutoff: Int
  @Binding var onlyPlugged: Bool

  var body: some View {
    Form {
      Stepper("Stop below \(cutoff)%", value: $cutoff, in: 5...50, step: 5)
      Toggle("Only when plugged in", isOn: $onlyPlugged)
    }
    .padding(20)
    .frame(width: 340)
  }
}
