import { describe, expect, test } from "bun:test";
import {
  DEFAULT_BATTERY_POLICY,
  evaluateBattery,
  type BatteryPolicy,
} from "../src/battery.ts";
import {
  WakeController,
  PAUSE_30M_MS,
  PAUSE_1H_MS,
} from "../src/wake.ts";

const pluggedOk = {
  percent: 80,
  isPluggedIn: true,
  lowPowerMode: false,
};

describe("evaluateBattery", () => {
  test("allows when above default cutoff", () => {
    expect(evaluateBattery(DEFAULT_BATTERY_POLICY, pluggedOk)).toEqual({
      allowed: true,
    });
  });

  test("blocks below cutoff threshold (default 15)", () => {
    const decision = evaluateBattery(DEFAULT_BATTERY_POLICY, {
      ...pluggedOk,
      percent: 14,
    });
    expect(decision).toEqual({ allowed: false, reason: "below-cutoff" });
  });

  test("allows exactly at cutoff", () => {
    expect(
      evaluateBattery(DEFAULT_BATTERY_POLICY, { ...pluggedOk, percent: 15 }),
    ).toEqual({ allowed: true });
  });

  test("onlyWhenPluggedIn blocks on battery", () => {
    const policy: BatteryPolicy = {
      ...DEFAULT_BATTERY_POLICY,
      onlyWhenPluggedIn: true,
    };
    expect(
      evaluateBattery(policy, { ...pluggedOk, isPluggedIn: false }),
    ).toEqual({ allowed: false, reason: "not-plugged-in" });
  });

  test("respectLowPowerMode blocks when LPM is on", () => {
    expect(
      evaluateBattery(DEFAULT_BATTERY_POLICY, {
        ...pluggedOk,
        lowPowerMode: true,
      }),
    ).toEqual({ allowed: false, reason: "low-power-mode" });
  });

  test("can ignore low power mode when policy says so", () => {
    const policy: BatteryPolicy = {
      ...DEFAULT_BATTERY_POLICY,
      respectLowPowerMode: false,
    };
    expect(
      evaluateBattery(policy, { ...pluggedOk, lowPowerMode: true }),
    ).toEqual({ allowed: true });
  });
});

describe("WakeController", () => {
  test("holds wake lock when agent working and battery ok", () => {
    const wake = new WakeController({ now: () => 1_000 });
    const d = wake.decide({ anyWorking: true }, pluggedOk, DEFAULT_BATTERY_POLICY);
    expect(d).toEqual({ holdWakeLock: true, mode: "working" });
  });

  test("releases when agents go idle", () => {
    const wake = new WakeController({ now: () => 1_000 });
    wake.decide({ anyWorking: true }, pluggedOk, DEFAULT_BATTERY_POLICY);
    const d = wake.decide({ anyWorking: false }, pluggedOk, DEFAULT_BATTERY_POLICY);
    expect(d).toEqual({ holdWakeLock: false, mode: "idle", reason: "idle" });
  });

  test("pause 30m releases wake lock until expiry", () => {
    let now = 0;
    const wake = new WakeController({ now: () => now });
    wake.pause(PAUSE_30M_MS);
    const paused = wake.decide(
      { anyWorking: true },
      pluggedOk,
      DEFAULT_BATTERY_POLICY,
    );
    expect(paused.holdWakeLock).toBe(false);
    expect(paused.mode).toBe("paused");

    now = PAUSE_30M_MS - 1;
    expect(wake.decide({ anyWorking: true }, pluggedOk, DEFAULT_BATTERY_POLICY).mode).toBe(
      "paused",
    );

    now = PAUSE_30M_MS;
    const after = wake.decide(
      { anyWorking: true },
      pluggedOk,
      DEFAULT_BATTERY_POLICY,
    );
    expect(after).toEqual({ holdWakeLock: true, mode: "working" });
  });

  test("pause 1h lasts longer than 30m", () => {
    let now = 0;
    const wake = new WakeController({ now: () => now });
    wake.pause(PAUSE_1H_MS);
    now = PAUSE_30M_MS + 1;
    expect(
      wake.decide({ anyWorking: true }, pluggedOk, DEFAULT_BATTERY_POLICY).mode,
    ).toBe("paused");
    now = PAUSE_1H_MS;
    expect(
      wake.decide({ anyWorking: true }, pluggedOk, DEFAULT_BATTERY_POLICY).holdWakeLock,
    ).toBe(true);
  });

  test("resume clears pause early", () => {
    const wake = new WakeController({ now: () => 0 });
    wake.pause(PAUSE_1H_MS);
    wake.resume();
    expect(
      wake.decide({ anyWorking: true }, pluggedOk, DEFAULT_BATTERY_POLICY),
    ).toEqual({ holdWakeLock: true, mode: "working" });
  });

  test("battery cutoff wins over working agents", () => {
    const wake = new WakeController({ now: () => 0 });
    const d = wake.decide(
      { anyWorking: true },
      { percent: 10, isPluggedIn: false, lowPowerMode: false },
      DEFAULT_BATTERY_POLICY,
    );
    expect(d.holdWakeLock).toBe(false);
    expect(d.reason).toBe("below-cutoff");
  });
});
