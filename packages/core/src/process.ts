import { AGENTS, type AgentId } from "./agents.ts";

/** Normalize a process name for case-insensitive matching. */
export function normalizeProcessName(name: string): string {
  return name.trim().toLowerCase();
}

/**
 * True when `processName` matches any of the configured substrings
 * (case-insensitive). Empty needles never match.
 */
export function matchesProcessName(
  processName: string,
  needles: readonly string[],
): boolean {
  const haystack = normalizeProcessName(processName);
  if (!haystack) return false;
  return needles.some((needle) => {
    const n = normalizeProcessName(needle);
    return n.length > 0 && haystack.includes(n);
  });
}

/** Resolve process name needles for a process-detection agent. */
export function processNeedlesFor(agentId: AgentId): readonly string[] {
  const agent = AGENTS.find((a) => a.id === agentId);
  if (!agent || agent.detection !== "process") return [];
  return agent.processNames ?? [];
}

/** Whether a running process name indicates the given agent is active. */
export function isAgentProcess(agentId: AgentId, processName: string): boolean {
  return matchesProcessName(processName, processNeedlesFor(agentId));
}

/** First process-detection agent whose needles match `processName`. */
export function detectAgentFromProcess(
  processName: string,
): AgentId | undefined {
  for (const agent of AGENTS) {
    if (agent.detection !== "process") continue;
    if (matchesProcessName(processName, agent.processNames ?? [])) {
      return agent.id;
    }
  }
  return undefined;
}
