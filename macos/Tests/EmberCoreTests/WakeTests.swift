import Foundation
import XCTest
@testable import EmberCore

final class WakeTests: XCTestCase {
  let pluggedOk = BatterySnapshot(percent: 80, isPluggedIn: true, lowPowerMode: false)

  func testHoldsWhenWorking() {
    let d = decideWake(
      anyWorking: true,
      battery: pluggedOk,
      policy: .default,
      pauseUntil: nil
    )
    XCTAssertEqual(d, WakeDecision(shouldHoldWake: true, mode: .working))
  }

  func testReleasesWhenIdle() {
    let d = decideWake(
      anyWorking: false,
      battery: pluggedOk,
      policy: .default,
      pauseUntil: nil
    )
    XCTAssertEqual(d, WakeDecision(shouldHoldWake: false, mode: .idle, reason: .idle))
  }

  func testPauseBlocksWake() {
    let until = Date().addingTimeInterval(60)
    let d = decideWake(
      anyWorking: true,
      battery: pluggedOk,
      policy: .default,
      pauseUntil: until,
      now: Date()
    )
    XCTAssertFalse(d.shouldHoldWake)
    XCTAssertEqual(d.mode, .paused)
  }

  func testSessionsOrProcess() {
    let sessions = [SessionSnapshot(state: .working, agent: "claude-code")]
    let d = decideWake(
      sessions: sessions,
      processAgentsWorking: false,
      battery: pluggedOk,
      policy: .default,
      pauseUntil: nil
    )
    XCTAssertTrue(d.shouldHoldWake)
  }

  func testBatteryCutoffWins() {
    let low = BatterySnapshot(percent: 10, isPluggedIn: false, lowPowerMode: false)
    let d = decideWake(
      anyWorking: true,
      battery: low,
      policy: .default,
      pauseUntil: nil
    )
    XCTAssertFalse(d.shouldHoldWake)
    XCTAssertEqual(d.reason, .belowCutoff)
  }

  func testControllerPauseAndResume() {
    let now = Date(timeIntervalSince1970: 0)
    let wake = WakeController(now: { now })
    wake.pause(duration: pause30Minutes)
    XCTAssertEqual(
      wake.decide(anyWorking: true, battery: pluggedOk, policy: .default).mode,
      .paused
    )
    wake.resume()
    XCTAssertTrue(
      wake.decide(anyWorking: true, battery: pluggedOk, policy: .default).shouldHoldWake
    )
  }
}
