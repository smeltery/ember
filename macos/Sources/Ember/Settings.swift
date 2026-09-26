#if os(macOS)
import Foundation
import EmberCore

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
}
#endif
