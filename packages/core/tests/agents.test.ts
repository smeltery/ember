import { describe, expect, test } from "bun:test";
import { AGENTS, agentById, agentsByDetection } from "../src/agents.ts";

describe("agent catalog", () => {
  test("lists hook and process agents", () => {
    const hooks = agentsByDetection("hooks").map((a) => a.id);
    const procs = agentsByDetection("process").map((a) => a.id);
    expect(hooks).toEqual([
      "claude-code",
      "chatgpt-codex",
      "opencode",
      "gemini",
      "pi",
      "copilot-cli",
      "hermes",
    ]);
    expect(procs).toEqual(["cursor", "cline"]);
  });

  test("every agent has a display name", () => {
    for (const agent of AGENTS) {
      expect(agent.displayName.length).toBeGreaterThan(0);
      expect(agentById(agent.id)?.id).toBe(agent.id);
    }
  });

  test("process agents declare processNames", () => {
    for (const agent of agentsByDetection("process")) {
      expect(agent.processNames?.length).toBeGreaterThan(0);
    }
  });
});
