export interface BatteryPolicy {
  /** Percent below which wake lock is refused. Default 15. */
  cutoffPercent: number;
  /** When true, only hold wake lock while AC power is connected. */
  onlyWhenPluggedIn: boolean;
  /** When true, refuse wake lock while macOS Low Power Mode is on. */
  respectLowPowerMode: boolean;
  /** Preference: turn display off while agents are working. */
  displayOffWhileWorking: boolean;
}

export interface BatterySnapshot {
  percent: number;
  isPluggedIn: boolean;
  lowPowerMode: boolean;
}

export const DEFAULT_BATTERY_POLICY: BatteryPolicy = {
  cutoffPercent: 15,
  onlyWhenPluggedIn: false,
  respectLowPowerMode: true,
  displayOffWhileWorking: false,
};

export type BatteryBlockReason =
  | "below-cutoff"
  | "not-plugged-in"
  | "low-power-mode";

export interface BatteryDecision {
  allowed: boolean;
  reason?: BatteryBlockReason;
}

/** Whether battery / power policy permits holding a wake lock. */
export function evaluateBattery(
  policy: BatteryPolicy,
  snapshot: BatterySnapshot,
): BatteryDecision {
  if (policy.onlyWhenPluggedIn && !snapshot.isPluggedIn) {
    return { allowed: false, reason: "not-plugged-in" };
  }
  if (policy.respectLowPowerMode && snapshot.lowPowerMode) {
    return { allowed: false, reason: "low-power-mode" };
  }
  if (snapshot.percent < policy.cutoffPercent) {
    return { allowed: false, reason: "below-cutoff" };
  }
  return { allowed: true };
}
