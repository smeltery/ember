export type DetectionMode = "hooks" | "process";

export type AgentId =
  | "claude-code"
  | "chatgpt-codex"
  | "opencode"
  | "gemini"
  | "pi"
  | "copilot-cli"
  | "hermes"
  | "cursor"
  | "cline"
  | "warp"
  | "aider"
  | "windsurf"
  | "continue"
  | "amp"
  | "goose";

export interface AgentDefinition {
  id: AgentId;
  displayName: string;
  detection: DetectionMode;
  /** Process name substrings used when detection === "process". */
  processNames?: readonly string[];
}

export const AGENTS: readonly AgentDefinition[] = [
  { id: "claude-code", displayName: "Claude Code", detection: "hooks" },
  { id: "chatgpt-codex", displayName: "ChatGPT / Codex", detection: "hooks" },
  { id: "opencode", displayName: "OpenCode", detection: "hooks" },
  { id: "gemini", displayName: "Gemini CLI", detection: "hooks" },
  { id: "pi", displayName: "Pi", detection: "hooks" },
  { id: "copilot-cli", displayName: "Copilot CLI", detection: "hooks" },
  { id: "hermes", displayName: "Hermes", detection: "hooks" },
  {
    id: "cursor",
    displayName: "Cursor",
    detection: "process",
    processNames: ["Cursor", "cursor-agent", "Cursor Helper"],
  },
  {
    id: "cline",
    displayName: "Cline",
    detection: "process",
    processNames: ["cline", "Cline"],
  },
  {
    id: "warp",
    displayName: "Warp",
    detection: "process",
    processNames: ["Warp", "Warp.app"],
  },
  {
    id: "aider",
    displayName: "Aider",
    detection: "process",
    processNames: ["aider"],
  },
  {
    id: "windsurf",
    displayName: "Windsurf",
    detection: "process",
    processNames: ["Windsurf", "windsurf"],
  },
  {
    id: "continue",
    displayName: "Continue",
    detection: "process",
    processNames: ["Continue", "continue-dev"],
  },
  {
    id: "amp",
    displayName: "Amp",
    detection: "process",
    processNames: ["Amp.app", "amp-cli", "bin/amp"],
  },
  {
    id: "goose",
    displayName: "Goose",
    detection: "process",
    processNames: ["goose"],
  },
] as const;

export function agentById(id: AgentId): AgentDefinition | undefined {
  return AGENTS.find((a) => a.id === id);
}

export function agentsByDetection(mode: DetectionMode): AgentDefinition[] {
  return AGENTS.filter((a) => a.detection === mode);
}
