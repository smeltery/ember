/// How ember learns that an agent is active.
public enum DetectionMode: String, Sendable, Codable, CaseIterable {
  case hooks
  case process
}

/// Catalog of agents ember can watch.
public enum AgentKind: String, Sendable, Codable, CaseIterable {
  case claudeCode = "claude-code"
  case chatgptCodex = "chatgpt-codex"
  case opencode
  case gemini
  case pi
  case copilotCli = "copilot-cli"
  case hermes
  case cursor
  case cline
  case warp
  case aider
  case windsurf
  case continueApp = "continue"
  case amp
  case goose

  public var displayName: String {
    switch self {
    case .claudeCode: "Claude Code"
    case .chatgptCodex: "ChatGPT / Codex"
    case .opencode: "OpenCode"
    case .gemini: "Gemini CLI"
    case .pi: "Pi"
    case .copilotCli: "Copilot CLI"
    case .hermes: "Hermes"
    case .cursor: "Cursor"
    case .cline: "Cline"
    case .warp: "Warp"
    case .aider: "Aider"
    case .windsurf: "Windsurf"
    case .continueApp: "Continue"
    case .amp: "Amp"
    case .goose: "Goose"
    }
  }

  public var detection: DetectionMode {
    switch self {
    case .claudeCode, .chatgptCodex, .opencode, .gemini, .pi, .copilotCli, .hermes:
      .hooks
    case .cursor, .cline, .warp, .aider, .windsurf, .continueApp, .amp, .goose:
      .process
    }
  }

  /// Substrings matched against `ps` command names (process detection only).
  public var processNames: [String] {
    switch self {
    case .cursor: ["Cursor", "cursor-agent", "Cursor Helper"]
    case .cline: ["cline", "Cline"]
    case .warp: ["Warp", "Warp.app"]
    case .aider: ["aider"]
    case .windsurf: ["Windsurf", "windsurf"]
    case .continueApp: ["Continue", "continue-dev"]
    case .amp: ["Amp.app", "amp-cli", "bin/amp"]
    case .goose: ["goose"]
    default: []
    }
  }

  public static var hookAgents: [AgentKind] {
    allCases.filter { $0.detection == .hooks }
  }

  public static var processAgents: [AgentKind] {
    allCases.filter { $0.detection == .process }
  }
}

/// Case-insensitive substring match for process names.
public func matchesProcessName(_ processName: String, needles: [String]) -> Bool {
  let haystack = processName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  guard !haystack.isEmpty else { return false }
  return needles.contains { needle in
    let n = needle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return !n.isEmpty && haystack.contains(n)
  }
}

/// First process-detection agent whose needles match `processName`.
public func detectAgent(fromProcessName processName: String) -> AgentKind? {
  for agent in AgentKind.processAgents {
    if matchesProcessName(processName, needles: agent.processNames) {
      return agent
    }
  }
  return nil
}
