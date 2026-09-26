#if os(macOS)
import AppKit
import EmberCore

@MainActor
final class StatusItemController: NSObject {
  private let statusItem: NSStatusItem
  private let wake = WakeController()
  private let caffeinate = CaffeinateController()
  private var timer: Timer?
  private var lastDecision: WakeDecision = WakeDecision(
    shouldHoldWake: false,
    mode: .idle,
    reason: .idle
  )
  private var lastBatteryNote = ""
  private var lastAgentSummary = "No agents"

  override init() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    super.init()
    if let button = statusItem.button {
      button.title = "ember"
      button.toolTip = "ember — keep awake for AI agents"
    }
  }

  func start() {
    rebuildMenu()
    tick()
    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.tick()
      }
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
    caffeinate.stop()
  }

  private func tick() {
    let sessions = SessionReader.loadSessions()
    let processWorking = ProcessScanner.anyProcessAgentWorking()
    let battery = BatteryReader.read()
    let decision = wake.decide(
      anyWorking: processWorking || sessions.contains(where: \.isWorking),
      battery: battery,
      policy: EmberSettings.policy
    )

    caffeinate.setHolding(decision.shouldHoldWake)
    lastDecision = decision
    lastBatteryNote = batteryNote(battery, decision: decision)
    lastAgentSummary = agentSummary(sessions: sessions)
    rebuildMenu()
    updateTitle(decision)
  }

  private func updateTitle(_ decision: WakeDecision) {
    guard let button = statusItem.button else { return }
    switch decision.mode {
    case .working where decision.shouldHoldWake:
      button.title = "ember ●"
    case .paused:
      button.title = "ember ❚❚"
    default:
      button.title = "ember"
    }
  }

  private func rebuildMenu() {
    let menu = NSMenu()
    menu.addItem(withTitle: "Status: \(statusLabel)", action: nil, keyEquivalent: "")
    menu.addItem(withTitle: lastBatteryNote, action: nil, keyEquivalent: "")
    menu.addItem(withTitle: "Agents: \(lastAgentSummary)", action: nil, keyEquivalent: "")
    menu.addItem(.separator())

    let pause30 = menu.addItem(
      withTitle: "Pause 30 min",
      action: #selector(pause30),
      keyEquivalent: ""
    )
    pause30.target = self

    let pause1h = menu.addItem(
      withTitle: "Pause 1 hour",
      action: #selector(pause1h),
      keyEquivalent: ""
    )
    pause1h.target = self

    let resume = menu.addItem(
      withTitle: "Resume",
      action: #selector(resumePause),
      keyEquivalent: ""
    )
    resume.target = self
    resume.isEnabled = lastDecision.mode == .paused

    menu.addItem(.separator())
    let quit = menu.addItem(
      withTitle: "Quit",
      action: #selector(quitApp),
      keyEquivalent: "q"
    )
    quit.target = self

    statusItem.menu = menu
  }

  private var statusLabel: String {
    switch lastDecision.mode {
    case .working where lastDecision.shouldHoldWake: "Awake"
    case .paused: "Paused"
    default: "Idle"
    }
  }

  private func batteryNote(_ battery: BatterySnapshot, decision: WakeDecision) -> String {
    let plug = battery.isPluggedIn ? "plugged in" : "on battery"
    var note = "Battery: \(battery.percent)% (\(plug))"
    if let reason = decision.reason, !decision.shouldHoldWake {
      switch reason {
      case .belowCutoff: note += " — below cutoff"
      case .notPluggedIn: note += " — plugged-in only"
      case .lowPowerMode: note += " — Low Power Mode"
      default: break
      }
    }
    return note
  }

  private func agentSummary(sessions: [SessionSnapshot]) -> String {
    var parts: [String] = []
    let working = sessions.filter(\.isWorking)
    for snap in working {
      parts.append(snap.agent ?? "session")
    }
    for name in ProcessScanner.matchedAgentNames() {
      if !parts.contains(name) { parts.append(name) }
    }
    if parts.isEmpty { return "none working" }
    return parts.joined(separator: ", ")
  }

  @objc private func pause30() {
    wake.pause(duration: pause30Minutes)
    tick()
  }

  @objc private func pause1h() {
    wake.pause(duration: pause1Hour)
    tick()
  }

  @objc private func resumePause() {
    wake.resume()
    tick()
  }

  @objc private func quitApp() {
    stop()
    NSApp.terminate(nil)
  }
}
#endif
