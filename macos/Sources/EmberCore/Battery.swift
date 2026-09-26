/// Live power state from `pmset` / system APIs.
public struct BatterySnapshot: Sendable, Equatable {
  public var percent: Int
  public var isPluggedIn: Bool
  public var lowPowerMode: Bool

  public init(percent: Int, isPluggedIn: Bool, lowPowerMode: Bool) {
    self.percent = percent
    self.isPluggedIn = isPluggedIn
    self.lowPowerMode = lowPowerMode
  }
}

/// User-configurable guardrails before holding wake.
public struct BatteryPolicy: Sendable, Equatable {
  /// Percent below which wake is refused. Default 15.
  public var cutoffPercent: Int
  /// When true, only hold wake while AC is connected.
  public var onlyWhenPluggedIn: Bool
  /// When true, refuse wake while Low Power Mode is on.
  public var respectLowPowerMode: Bool
  /// Preference: allow display sleep while agents work.
  public var displayOffWhileWorking: Bool

  public init(
    cutoffPercent: Int = 15,
    onlyWhenPluggedIn: Bool = false,
    respectLowPowerMode: Bool = true,
    displayOffWhileWorking: Bool = false
  ) {
    self.cutoffPercent = cutoffPercent
    self.onlyWhenPluggedIn = onlyWhenPluggedIn
    self.respectLowPowerMode = respectLowPowerMode
    self.displayOffWhileWorking = displayOffWhileWorking
  }

  public static let `default` = BatteryPolicy()
}

public enum BatteryBlockReason: String, Sendable, Equatable {
  case belowCutoff = "below-cutoff"
  case notPluggedIn = "not-plugged-in"
  case lowPowerMode = "low-power-mode"
}

public struct BatteryDecision: Sendable, Equatable {
  public var allowed: Bool
  public var reason: BatteryBlockReason?

  public init(allowed: Bool, reason: BatteryBlockReason? = nil) {
    self.allowed = allowed
    self.reason = reason
  }
}

/// Whether battery / power policy permits holding a wake lock.
public func evaluateBattery(
  policy: BatteryPolicy,
  snapshot: BatterySnapshot
) -> BatteryDecision {
  if policy.onlyWhenPluggedIn && !snapshot.isPluggedIn {
    return BatteryDecision(allowed: false, reason: .notPluggedIn)
  }
  if policy.respectLowPowerMode && snapshot.lowPowerMode {
    return BatteryDecision(allowed: false, reason: .lowPowerMode)
  }
  if snapshot.percent < policy.cutoffPercent {
    return BatteryDecision(allowed: false, reason: .belowCutoff)
  }
  return BatteryDecision(allowed: true)
}

/// Parse `pmset -g batt` text into a snapshot (lowPowerMode left to caller).
public func parsePmsetBattery(_ output: String, lowPowerMode: Bool = false) -> BatterySnapshot? {
  let lower = output.lowercased()
  let plugged: Bool
  if lower.contains("ac power") {
    plugged = true
  } else if lower.contains("battery power") {
    plugged = false
  } else {
    // Avoid matching the substring inside "discharging".
    plugged = lower.contains(" charged")
      || lower.contains("; charged")
      || (lower.contains("charging") && !lower.contains("discharging"))
  }

  // Match "80%" style.
  guard let percentRange = output.range(of: #"(\d+)\s*%"#, options: .regularExpression)
  else { return nil }
  let token = String(output[percentRange]).filter(\.isNumber)
  guard let percent = Int(token) else { return nil }

  return BatterySnapshot(
    percent: percent,
    isPluggedIn: plugged,
    lowPowerMode: lowPowerMode
  )
}
