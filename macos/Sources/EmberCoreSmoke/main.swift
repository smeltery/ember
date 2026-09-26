import Foundation
import EmberCore

/// Lightweight assertions so EmberCore can be verified without Xcode/XCTest.
@main
enum EmberCoreSmoke {
  static func main() {
    var failures = 0

    func check(_ name: String, _ ok: Bool) {
      if ok {
        print("ok   \(name)")
      } else {
        print("FAIL \(name)")
        failures += 1
      }
    }

    let plugged = BatterySnapshot(percent: 80, isPluggedIn: true, lowPowerMode: false)
    check(
      "battery allows",
      evaluateBattery(policy: .default, snapshot: plugged).allowed
    )
    check(
      "battery cutoff",
      evaluateBattery(
        policy: .default,
        snapshot: BatterySnapshot(percent: 10, isPluggedIn: true, lowPowerMode: false)
      ).reason == .belowCutoff
    )

    let working = decideWake(
      anyWorking: true,
      battery: plugged,
      policy: .default,
      pauseUntil: nil
    )
    check("wake holds", working.shouldHoldWake && working.mode == .working)

    let idle = decideWake(
      anyWorking: false,
      battery: plugged,
      policy: .default,
      pauseUntil: nil
    )
    check("wake idle", !idle.shouldHoldWake && idle.mode == .idle)

    let snap = parseSessionJSON(
      #"{"state":"working","agent":"claude-code","updatedAt":"2026-01-01T00:00:00Z"}"#
    )
    check("session parse", snap?.isWorking == true && snap?.agent == "claude-code")

    check("agent cursor", detectAgent(fromProcessName: "cursor-agent") == .cursor)
    check("hook agent count", AgentKind.hookAgents.count == 7)

    let pmset = parsePmsetBattery(
      "Now drawing from 'AC Power'\n-InternalBattery-0 95%; charged;"
    )
    check("pmset parse", pmset?.percent == 95 && pmset?.isPluggedIn == true)

    if failures > 0 {
      print("\(failures) failure(s)")
      exit(1)
    }
    print("all smoke checks passed")
  }
}
