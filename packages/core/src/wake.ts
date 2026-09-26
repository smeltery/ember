import {
  evaluateBattery,
  type BatteryPolicy,
  type BatterySnapshot,
  type BatteryBlockReason,
} from "./battery.ts";

export type WakeMode = "idle" | "working" | "paused";

export const PAUSE_30M_MS = 30 * 60 * 1000;
export const PAUSE_1H_MS = 60 * 60 * 1000;

export type PauseDurationMs = typeof PAUSE_30M_MS | typeof PAUSE_1H_MS;

export interface AgentActivity {
  /** True when at least one watched agent session/process is working. */
  anyWorking: boolean;
}

export interface WakeState {
  mode: WakeMode;
  /** Epoch ms when pause ends; set only while mode === "paused". */
  pauseUntil?: number;
}

export type WakeBlockReason = BatteryBlockReason | "paused" | "idle";

export interface WakeDecision {
  holdWakeLock: boolean;
  mode: WakeMode;
  reason?: WakeBlockReason;
}

export interface WakeControllerOptions {
  now?: () => number;
}

/**
 * Pure wake-lock state machine.
 * Decisions combine agent activity, pause timers, and battery policy.
 */
export class WakeController {
  private state: WakeState = { mode: "idle" };
  private readonly now: () => number;

  constructor(options: WakeControllerOptions = {}) {
    this.now = options.now ?? Date.now;
  }

  getState(): WakeState {
    this.expirePauseIfNeeded();
    return { ...this.state };
  }

  /** Enter a timed pause (30m or 1h). Wake lock is released while paused. */
  pause(durationMs: PauseDurationMs | number = PAUSE_30M_MS): WakeState {
    const ms = durationMs === PAUSE_1H_MS ? PAUSE_1H_MS : PAUSE_30M_MS;
    this.state = { mode: "paused", pauseUntil: this.now() + ms };
    return this.getState();
  }

  /** Clear an active pause immediately. */
  resume(): WakeState {
    if (this.state.mode === "paused") {
      this.state = { mode: "idle" };
    }
    return this.getState();
  }

  /**
   * Recompute mode and whether the wake lock should be held.
   * Call whenever agent activity or battery snapshot changes.
   */
  decide(
    activity: AgentActivity,
    battery: BatterySnapshot,
    policy: BatteryPolicy,
  ): WakeDecision {
    this.expirePauseIfNeeded();

    if (this.state.mode === "paused") {
      return { holdWakeLock: false, mode: "paused", reason: "paused" };
    }

    const batteryDecision = evaluateBattery(policy, battery);
    if (!batteryDecision.allowed) {
      this.state = { mode: activity.anyWorking ? "working" : "idle" };
      return {
        holdWakeLock: false,
        mode: this.state.mode,
        reason: batteryDecision.reason,
      };
    }

    if (!activity.anyWorking) {
      this.state = { mode: "idle" };
      return { holdWakeLock: false, mode: "idle", reason: "idle" };
    }

    this.state = { mode: "working" };
    return { holdWakeLock: true, mode: "working" };
  }

  private expirePauseIfNeeded(): void {
    if (this.state.mode !== "paused") return;
    const until = this.state.pauseUntil ?? 0;
    if (this.now() >= until) {
      this.state = { mode: "idle" };
    }
  }
}
