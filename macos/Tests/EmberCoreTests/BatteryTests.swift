import XCTest
@testable import EmberCore

final class BatteryTests: XCTestCase {
  let pluggedOk = BatterySnapshot(percent: 80, isPluggedIn: true, lowPowerMode: false)

  func testAllowsAboveCutoff() {
    XCTAssertEqual(
      evaluateBattery(policy: .default, snapshot: pluggedOk),
      BatteryDecision(allowed: true)
    )
  }

  func testBlocksBelowCutoff() {
    let snap = BatterySnapshot(percent: 14, isPluggedIn: true, lowPowerMode: false)
    XCTAssertEqual(
      evaluateBattery(policy: .default, snapshot: snap),
      BatteryDecision(allowed: false, reason: .belowCutoff)
    )
  }

  func testAllowsAtCutoff() {
    let snap = BatterySnapshot(percent: 15, isPluggedIn: true, lowPowerMode: false)
    XCTAssertTrue(evaluateBattery(policy: .default, snapshot: snap).allowed)
  }

  func testOnlyWhenPluggedIn() {
    let policy = BatteryPolicy(onlyWhenPluggedIn: true)
    let snap = BatterySnapshot(percent: 80, isPluggedIn: false, lowPowerMode: false)
    XCTAssertEqual(
      evaluateBattery(policy: policy, snapshot: snap),
      BatteryDecision(allowed: false, reason: .notPluggedIn)
    )
  }

  func testLowPowerMode() {
    let snap = BatterySnapshot(percent: 80, isPluggedIn: true, lowPowerMode: true)
    XCTAssertEqual(
      evaluateBattery(policy: .default, snapshot: snap),
      BatteryDecision(allowed: false, reason: .lowPowerMode)
    )
  }

  func testParsePmset() {
    let sample = """
      Now drawing from 'Battery Power'
       -InternalBattery-0 (id=123)  42%; discharging; 2:15 remaining present: true
      """
    let snap = parsePmsetBattery(sample)
    XCTAssertEqual(snap?.percent, 42)
    XCTAssertEqual(snap?.isPluggedIn, false)
  }

  func testParsePmsetAC() {
    let sample = "Now drawing from 'AC Power'\n-InternalBattery-0\t95%; charged; 0:00"
    let snap = parsePmsetBattery(sample)
    XCTAssertEqual(snap?.percent, 95)
    XCTAssertEqual(snap?.isPluggedIn, true)
  }
}
