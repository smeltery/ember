#if os(macOS)
import Foundation

/// Holds PreventUserIdleSystemSleep / system sleep via `caffeinate -is`.
final class CaffeinateController {
  private var process: Process?

  var isRunning: Bool { process?.isRunning == true }

  func setHolding(_ hold: Bool) {
    if hold {
      startIfNeeded()
    } else {
      stop()
    }
  }

  private func startIfNeeded() {
    if process?.isRunning == true { return }
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
    // -i idle sleep, -s system sleep (AC); together ≈ PreventUserIdleSystemSleep + system.
    proc.arguments = ["-is"]
    proc.standardOutput = FileHandle.nullDevice
    proc.standardError = FileHandle.nullDevice
    do {
      try proc.run()
      process = proc
    } catch {
      process = nil
    }
  }

  func stop() {
    guard let proc = process else { return }
    proc.terminate()
    process = nil
  }

  deinit {
    process?.terminate()
  }
}
#endif
