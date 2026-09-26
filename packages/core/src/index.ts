export {
  AGENTS,
  agentById,
  agentsByDetection,
  type AgentDefinition,
  type AgentId,
  type DetectionMode,
} from "./agents.ts";

export {
  applicationSupportPath,
  sessionsDirectory,
  sessionStatePath,
  parseSessionState,
  isWorking,
  type SessionSnapshot,
  type SessionState,
} from "./hooks.ts";

export {
  DEFAULT_BATTERY_POLICY,
  evaluateBattery,
  type BatteryPolicy,
  type BatterySnapshot,
  type BatteryDecision,
  type BatteryBlockReason,
} from "./battery.ts";

export {
  WakeController,
  PAUSE_30M_MS,
  PAUSE_1H_MS,
  type WakeMode,
  type WakeState,
  type WakeDecision,
  type WakeBlockReason,
  type AgentActivity,
  type PauseDurationMs,
  type WakeControllerOptions,
} from "./wake.ts";

export {
  normalizeProcessName,
  matchesProcessName,
  processNeedlesFor,
  isAgentProcess,
  detectAgentFromProcess,
} from "./process.ts";
