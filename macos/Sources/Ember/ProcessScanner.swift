#if os(macOS)
import Foundation
import EmberCore

enum ProcessScanner {
  /// True when Cursor/Cline (or other process agents) appear in `ps`.
  static func anyProcessAgentWorking() -> Bool {
    let output = run("/bin/ps", ["-axo", "comm="]) ?? ""
    for line in output.split(whereSeparator: \.isNewline) {
      let name = String(line)
      if detectAgent(fromProcessName: name) != nil {
        return true
      }
    }
    return false
  }

  static func matchedAgentNames() -> [String] {
    let output = run("/bin/ps", ["-axo", "comm="]) ?? ""
    var seen = Set<String>()
    var names: [String] = []
    for line in output.split(whereSeparator: \.isNewline) {
      if let agent = detectAgent(fromProcessName: String(line)),
         seen.insert(agent.rawValue).inserted
      {
        names.append(agent.displayName)
      }
    }
    return names
  }

  private static func run(_ launchPath: String, _ args: [String]) -> String? {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: launchPath)
    proc.arguments = args
    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = FileHandle.nullDevice
    do {
      try proc.run()
      proc.waitUntilExit()
    } catch {
      return nil
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
  }
}
#endif
