import { describe, expect, test } from "bun:test";
import {
  detectAgentFromProcess,
  isAgentProcess,
  matchesProcessName,
  normalizeProcessName,
  processNeedlesFor,
} from "../src/process.ts";

describe("process matching", () => {
  test("normalizeProcessName lowercases and trims", () => {
    expect(normalizeProcessName("  Cursor Helper  ")).toBe("cursor helper");
  });

  test("matchesProcessName is case-insensitive substring", () => {
    expect(matchesProcessName("Cursor Helper (GPU)", ["cursor"])).toBe(true);
    expect(matchesProcessName("Safari", ["cursor"])).toBe(false);
    expect(matchesProcessName("Cursor", [""])).toBe(false);
  });

  test("cursor needles match Cursor processes", () => {
    expect(isAgentProcess("cursor", "Cursor")).toBe(true);
    expect(isAgentProcess("cursor", "cursor-agent")).toBe(true);
    expect(isAgentProcess("cursor", "Cursor Helper")).toBe(true);
    expect(isAgentProcess("cursor", "Google Chrome")).toBe(false);
  });

  test("cline needles match Cline processes", () => {
    expect(isAgentProcess("cline", "cline")).toBe(true);
    expect(isAgentProcess("cline", "Cline Extension Host")).toBe(true);
    expect(isAgentProcess("cline", "node")).toBe(false);
  });

  test("processNeedlesFor returns empty for hook agents", () => {
    expect(processNeedlesFor("claude-code")).toEqual([]);
  });

  test("detectAgentFromProcess picks cursor then cline", () => {
    expect(detectAgentFromProcess("Cursor Helper")).toBe("cursor");
    expect(detectAgentFromProcess("cline")).toBe("cline");
    expect(detectAgentFromProcess("zsh")).toBeUndefined();
  });
});
