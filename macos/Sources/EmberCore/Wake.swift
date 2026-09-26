import Foundation

public enum WakeMode: String, Sendable, Equatable {
  case idle
  case working
  case paused
}

public enum WakeBlockReason: String, Sendable, Equatable {
  case paused
  case idle
  case belowCutoff = "below-cutoff"
  case notPluggedIn = "not-plugged-in"
  case lowPowerMode = "low-power-mode"

  public init(battery: BatteryBlockReason) {
    switch battery {
    case .belowCutoff: self = .belowCutoff
    case .notPluggedIn: self = .notPluggedIn
    case .lowPowerMode: self = .lowPowerMode
    }
  }
}

/// Result of combining sessions, battery policy, and optional pause.
public struct WakeDecision: Sendable, Equatable {
  public var shouldHoldWake: Bool
  public var mode: WakeMode
  public var reason: WakeBlockReason?

  public init(shouldHoldWake: Bool, mode: WakeMode, reason: WakeBlockReason? = nil) {
    self.shouldHoldWake = shouldHoldWake
    self.mode = mode
    self.reason = reason
  }
}

public let pause30Minutes: TimeInterval = 30 * 60
public let pause1Hour: TimeInterval = 60 * 60

/// Pure wake decision: sessions + battery + optional pause-until → shouldHoldWake.
public func decideWake(
  anyWorking: Bool,
  battery: BatterySnapshot,
  policy: BatteryPolicy,
  pauseUntil: Date?,
  now: Date = Date()
) -> WakeDecision {
  if let pauseUntil, now < pauseUntil {
    return WakeDecision(shouldHoldWake: false, mode: .paused, reason: .paused)
  }

  let batteryDecision = evaluateBattery(policy: policy, snapshot: battery)
  if !batteryDecision.allowed {
    let mode: WakeMode = anyWorking ? .working : .idle
    let reason = batteryDecision.reason.map { WakeBlockReason(battery: $0) }
    return WakeDecision(shouldHoldWake: false, mode: mode, reason: reason)
  }

  if !anyWorking {
    return WakeDecision(shouldHoldWake: false, mode: .idle, reason: .idle)
  }

  return WakeDecision(shouldHoldWake: true, mode: .working)
}

/// Convenience over session snapshots + process activity.
public func decideWake(
  sessions: [SessionSnapshot],
  processAgentsWorking: Bool,
  battery: BatterySnapshot,
  policy: BatteryPolicy,
  pauseUntil: Date?,
  now: Date = Date()
) -> WakeDecision {
  let anyWorking = processAgentsWorking || sessions.contains(where: \.isWorking)
  return decideWake(
    anyWorking: anyWorking,
    battery: battery,
    policy: policy,
    pauseUntil: pauseUntil,
    now: now
  )
}

/// Mutable pause helper for the menu-bar app.
public final class WakeController: @unchecked Sendable {
  private var pauseUntil: Date?
  private let clock: () -> Date

  public init(now: @escaping () -> Date = { Date() }) {
    self.clock = now
  }

  public var currentPauseUntil: Date? {
    expireIfNeeded()
    return pauseUntil
  }

  public func pause(duration: TimeInterval) {
    pauseUntil = clock().addingTimeInterval(duration)
  }

  public func resume() {
    pauseUntil = nil
  }

  public func decide(
    anyWorking: Bool,
    battery: BatterySnapshot,
    policy: BatteryPolicy
  ) -> WakeDecision {
    expireIfNeeded()
    return decideWake(
      anyWorking: anyWorking,
      battery: battery,
      policy: policy,
      pauseUntil: pauseUntil,
      now: clock()
    )
  }

  private func expireIfNeeded() {
    guard let until = pauseUntil, clock() >= until else { return }
    pauseUntil = nil
  }
}
