import { describe, expect, test } from "bun:test";
import {
  applicationSupportPath,
  isWorking,
  parseSessionState,
  sessionStatePath,
  sessionsDirectory,
} from "../src/hooks.ts";

describe("hooks paths", () => {
  test("builds Application Support path", () => {
    expect(applicationSupportPath("/Users/ada")).toBe(
      "/Users/ada/Library/Application Support/ember",
    );
  });

  test("trims trailing slash on home", () => {
    expect(sessionsDirectory("/Users/ada/")).toBe(
      "/Users/ada/Library/Application Support/ember/sessions",
    );
  });

  test("sanitizes session id in file path", () => {
    expect(sessionStatePath("/Users/ada", "sess/../evil id")).toBe(
      "/Users/ada/Library/Application Support/ember/sessions/sess_.._evil_id.json",
    );
  });
});

describe("parseSessionState", () => {
  test("parses Working JSON", () => {
    const snap = parseSessionState(
      JSON.stringify({
        state: "Working",
        sessionId: "abc",
        agentId: "claude-code",
        updatedAt: "2026-01-01T00:00:00Z",
      }),
    );
    expect(snap).toEqual({
      state: "Working",
      sessionId: "abc",
      agentId: "claude-code",
      updatedAt: "2026-01-01T00:00:00Z",
    });
    expect(isWorking(snap!)).toBe(true);
  });

  test("parses Idle case-insensitively", () => {
    expect(parseSessionState('{"state":"idle"}')).toEqual({ state: "Idle" });
  });

  test("accepts Status alias", () => {
    expect(parseSessionState('{"Status":"Working"}')).toEqual({
      state: "Working",
    });
  });

  test("returns null for invalid payloads", () => {
    expect(parseSessionState("not-json")).toBeNull();
    expect(parseSessionState("{}")).toBeNull();
    expect(parseSessionState('{"state":"Busy"}')).toBeNull();
    expect(parseSessionState("null")).toBeNull();
  });
});
