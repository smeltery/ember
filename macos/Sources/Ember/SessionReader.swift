import Foundation
import EmberCore

enum SessionReader {
  static func loadSessions(homeDir: String = NSHomeDirectory()) -> [SessionSnapshot] {
    let root = EmberPaths.sessions(homeDir: homeDir)
    let fm = FileManager.default
    guard let enumerator = fm.enumerator(
      at: root,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles]
    ) else { return [] }

    var sessions: [SessionSnapshot] = []
    for case let url as URL in enumerator {
      guard url.pathExtension == "json",
            let data = try? Data(contentsOf: url),
            let text = String(data: data, encoding: .utf8),
            let snap = parseSessionJSON(text)
      else { continue }
      sessions.append(snap)
    }
    return sessions
  }
}
