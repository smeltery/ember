import Foundation

/// Working = hold wake eligible; Idle = agent finished or waiting.
public enum SessionState: String, Sendable, Codable, Equatable {
  case working
  case idle

  public init?(rawValueIgnoreCase value: String) {
    switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "working": self = .working
    case "idle": self = .idle
    default: return nil
    }
  }
}

/// One agent session as written by hooks under Application Support.
public struct SessionSnapshot: Sendable, Equatable {
  public var state: SessionState
  public var agent: String?
  public var sessionId: String?
  public var updatedAt: String?

  public init(
    state: SessionState,
    agent: String? = nil,
    sessionId: String? = nil,
    updatedAt: String? = nil
  ) {
    self.state = state
    self.agent = agent
    self.sessionId = sessionId
    self.updatedAt = updatedAt
  }

  public var isWorking: Bool { state == .working }
}

/// Paths under `~/Library/Application Support/ember`.
public enum EmberPaths {
  public static let appSupportName = "ember"
  public static let sessionsName = "sessions"

  public static func applicationSupport(homeDir: String) -> URL {
    var home = homeDir
    while home.hasSuffix("/") { home.removeLast() }
    return URL(fileURLWithPath: home, isDirectory: true)
      .appendingPathComponent("Library/Application Support/\(appSupportName)", isDirectory: true)
  }

  public static func sessions(homeDir: String) -> URL {
    applicationSupport(homeDir: homeDir)
      .appendingPathComponent(sessionsName, isDirectory: true)
  }

  public static func sessionFile(homeDir: String, agentId: String, sessionId: String) -> URL {
    let safeAgent = sanitize(agentId)
    let safeSession = sanitize(sessionId)
    return sessions(homeDir: homeDir)
      .appendingPathComponent(safeAgent, isDirectory: true)
      .appendingPathComponent("\(safeSession).json", isDirectory: false)
  }

  public static func sanitize(_ value: String) -> String {
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
    return String(value.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" })
  }
}

/// Parse session JSON: `{ "state": "working"|"idle", "agent": "...", "updatedAt": "..." }`.
public func parseSessionJSON(_ raw: String) -> SessionSnapshot? {
  guard let data = raw.data(using: .utf8),
        let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  else { return nil }

  let stateRaw = (obj["state"] ?? obj["Status"] ?? obj["status"]) as? String
  guard let stateRaw, let state = SessionState(rawValueIgnoreCase: stateRaw) else {
    return nil
  }

  let agent = (obj["agent"] as? String) ?? (obj["agentId"] as? String)
  let sessionId = obj["sessionId"] as? String
  let updatedAt = obj["updatedAt"] as? String
  return SessionSnapshot(
    state: state,
    agent: agent,
    sessionId: sessionId,
    updatedAt: updatedAt
  )
}
