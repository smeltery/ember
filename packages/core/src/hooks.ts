export type SessionState = "Working" | "Idle";

export interface SessionSnapshot {
  state: SessionState;
  sessionId?: string;
  agentId?: string;
  updatedAt?: string;
}

const APP_SUPPORT_SEGMENT = "ember";
const SESSIONS_SEGMENT = "sessions";

/** Application Support directory for ember session state files. */
export function applicationSupportPath(homeDir: string): string {
  const trimmed = homeDir.replace(/\/+$/, "");
  return `${trimmed}/Library/Application Support/${APP_SUPPORT_SEGMENT}`;
}

/** Directory where per-session JSON state files live. */
export function sessionsDirectory(homeDir: string): string {
  return `${applicationSupportPath(homeDir)}/${SESSIONS_SEGMENT}`;
}

/** Path for a single session state file. */
export function sessionStatePath(homeDir: string, sessionId: string): string {
  const safe = sessionId.replace(/[^a-zA-Z0-9._-]/g, "_");
  return `${sessionsDirectory(homeDir)}/${safe}.json`;
}

/**
 * Parse a session state JSON payload.
 * Accepts `{ "state": "Working" | "Idle", ... }` (case-insensitive state).
 */
export function parseSessionState(raw: string): SessionSnapshot | null {
  let data: unknown;
  try {
    data = JSON.parse(raw);
  } catch {
    return null;
  }
  if (!data || typeof data !== "object") return null;

  const record = data as Record<string, unknown>;
  const stateRaw = record.state ?? record.Status ?? record.status;
  if (typeof stateRaw !== "string") return null;

  const normalized = stateRaw.trim().toLowerCase();
  let state: SessionState | null = null;
  if (normalized === "working") state = "Working";
  else if (normalized === "idle") state = "Idle";
  if (!state) return null;

  const snapshot: SessionSnapshot = { state };
  if (typeof record.sessionId === "string") snapshot.sessionId = record.sessionId;
  if (typeof record.agentId === "string") snapshot.agentId = record.agentId;
  if (typeof record.updatedAt === "string") snapshot.updatedAt = record.updatedAt;
  return snapshot;
}

export function isWorking(snapshot: SessionSnapshot): boolean {
  return snapshot.state === "Working";
}
