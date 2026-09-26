import Foundation
import EmberCore

enum BatteryReader {
  static func read(lowPowerMode: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled)
    -> BatterySnapshot
  {
    let output = run("/usr/bin/pmset", ["-g", "batt"]) ?? ""
    if let snap = parsePmsetBattery(output, lowPowerMode: lowPowerMode) {
      return snap
    }
    return BatterySnapshot(percent: 100, isPluggedIn: true, lowPowerMode: lowPowerMode)
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
