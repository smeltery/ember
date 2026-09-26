import AppKit
import EmberCore
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
  private let statusItem: NSStatusItem
  private let wake = WakeController()
  private let caffeinate = CaffeinateController()
  private let model = PopoverModel()
  private var panel: NSPanel?
  private var timer: Timer?
  private var eventMonitor: Any?
  private var holdingStartedAt: Date?
  private var settingsWindow: NSWindow?
  private static let enabledKey = "holdingEnabled"

  override init() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    super.init()
    model.enabled = UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true
    wireActions()
    if let button = statusItem.button {
      button.title = "ember"
      button.toolTip = "ember — keep awake for AI agents"
      button.target = self
      button.action = #selector(togglePanel)
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
  }

  func start() {
    tick()
    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
      Task { @MainActor in self?.tick() }
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
    hidePanel()
    caffeinate.stop()
  }

  private func wireActions() {
    model.onToggleEnabled = { [weak self] on in self?.setEnabled(on) }
    model.onPause30 = { [weak self] in self?.wake.pause(duration: pause30Minutes); self?.tick() }
    model.onPause1h = { [weak self] in self?.wake.pause(duration: pause1Hour); self?.tick() }
    model.onResume = { [weak self] in self?.wake.resume(); self?.tick() }
    model.onSettings = { [weak self] in self?.openSettings() }
    model.onQuit = { [weak self] in self?.quitApp() }
  }

  private func tick() {
    let sessions = SessionReader.loadSessions()
    let processWorking = ProcessScanner.anyProcessAgentWorking()
    let battery = BatteryReader.read()
    var decision = wake.decide(
      anyWorking: processWorking || sessions.contains(where: \.isWorking),
      battery: battery,
      policy: EmberSettings.policy
    )
    if !model.enabled {
      decision = WakeDecision(shouldHoldWake: false, mode: decision.mode, reason: decision.reason)
    }
    caffeinate.setHolding(decision.shouldHoldWake)
    updateHoldClock(decision.shouldHoldWake)
    applyModel(decision: decision, battery: battery, sessions: sessions)
    updateTitle(decision)
  }

  private func applyModel(
    decision: WakeDecision,
    battery: BatterySnapshot,
    sessions: [SessionSnapshot]
  ) {
    model.subtitle = subtitle(for: decision)
    model.batteryPercent = battery.percent
    model.cutoffPercent = EmberSettings.batteryCutoff
    model.isPaused = decision.mode == .paused
    let rows = agentRows(sessions: sessions)
    model.agents = rows
    model.workingCount = rows.filter(\.isWorking).count
  }

  private func subtitle(for decision: WakeDecision) -> String {
    if !model.enabled { return "Off" }
    switch decision.mode {
    case .paused:
      guard let until = wake.currentPauseUntil else { return "Paused" }
      return "Paused — \(formatDuration(until.timeIntervalSinceNow)) left"
    case .working where decision.shouldHoldWake:
      let elapsed = holdingStartedAt.map { Date().timeIntervalSince($0) } ?? 0
      return "Awake — lid-proof · \(formatDuration(elapsed))"
    case .working:
      switch decision.reason {
      case .belowCutoff: return "Blocked — below cutoff"
      case .notPluggedIn: return "Blocked — plugged-in only"
      case .lowPowerMode: return "Blocked — Low Power Mode"
      default: return "Working"
      }
    case .idle: return "Idle"
    }
  }

  private func agentRows(sessions: [SessionSnapshot]) -> [AgentRowModel] {
    var counts: [String: (working: Int, idle: Int)] = [:]
    for snap in sessions {
      let name = displayName(for: snap.agent)
      var entry = counts[name] ?? (0, 0)
      if snap.isWorking { entry.working += 1 } else { entry.idle += 1 }
      counts[name] = entry
    }
    for name in ProcessScanner.matchedAgentNames() {
      var entry = counts[name] ?? (0, 0)
      if entry.working == 0 { entry.working = 1 }
      counts[name] = entry
    }
    return counts.keys.sorted().map { name in
      let c = counts[name]!
      let working = c.working > 0
      let detail = working
        ? (c.working == 1 ? "1 session" : "\(c.working) sessions")
        : "idle"
      return AgentRowModel(id: name, name: name, detail: detail, isWorking: working)
    }
    .sorted {
      $0.isWorking != $1.isWorking ? $0.isWorking && !$1.isWorking : $0.name < $1.name
    }
  }

  private func displayName(for agentId: String?) -> String {
    guard let agentId else { return "Agent" }
    return AgentKind(rawValue: agentId)?.displayName ?? agentId
  }

  private func updateHoldClock(_ holding: Bool) {
    if holding { if holdingStartedAt == nil { holdingStartedAt = Date() } }
    else { holdingStartedAt = nil }
  }

  private func formatDuration(_ interval: TimeInterval) -> String {
    let total = max(0, Int(interval.rounded()))
    return "\(total / 3600)h \((total % 3600) / 60)m"
  }

  private func updateTitle(_ decision: WakeDecision) {
    guard let button = statusItem.button else { return }
    switch decision.mode {
    case .working where decision.shouldHoldWake: button.title = "ember ●"
    case .paused: button.title = "ember ❚❚"
    default: button.title = "ember"
    }
  }

  private func setEnabled(_ on: Bool) {
    model.enabled = on
    UserDefaults.standard.set(on, forKey: Self.enabledKey)
    tick()
  }

  @objc private func togglePanel() {
    panel?.isVisible == true ? hidePanel() : showPanel()
  }

  private func showPanel() {
    tick()
    let panel = ensurePanel()
    position(panel)
    panel.orderFrontRegardless()
    NSApp.activate(ignoringOtherApps: true)
    startEventMonitor()
  }

  private func hidePanel() {
    panel?.orderOut(nil)
    stopEventMonitor()
  }

  private func ensurePanel() -> NSPanel {
    if let panel { return panel }
    let hosting = NSHostingView(rootView: PopoverView(model: model))
    hosting.frame = NSRect(x: 0, y: 0, width: 320, height: 420)
    hosting.sizingOptions = [.intrinsicContentSize]
    let panel = NSPanel(
      contentRect: NSRect(x: 0, y: 0, width: 320, height: 420),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = true
    panel.level = .statusBar
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
    panel.hidesOnDeactivate = false
    panel.contentView = hosting
    panel.isFloatingPanel = true
    panel.becomesKeyOnlyIfNeeded = true
    self.panel = panel
    return panel
  }

  private func position(_ panel: NSPanel) {
    guard let button = statusItem.button, let buttonWindow = button.window else { return }
    panel.contentView?.layoutSubtreeIfNeeded()
    let size = panel.contentView?.fittingSize ?? NSSize(width: 320, height: 420)
    panel.setContentSize(size)
    let buttonRect = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
    panel.setFrameOrigin(NSPoint(
      x: buttonRect.midX - size.width / 2,
      y: buttonRect.minY - size.height - 6
    ))
  }

  private func startEventMonitor() {
    stopEventMonitor()
    eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) {
      [weak self] _ in
      Task { @MainActor in self?.dismissIfOutsideClick() }
    }
  }

  private func dismissIfOutsideClick() {
    guard let panel, panel.isVisible else { return }
    let pt = NSEvent.mouseLocation
    if panel.frame.contains(pt) { return }
    if let button = statusItem.button, let win = button.window {
      let buttonScreen = win.convertToScreen(button.convert(button.bounds, to: nil))
      if buttonScreen.contains(pt) { return }
    }
    hidePanel()
  }

  private func stopEventMonitor() {
    if let eventMonitor { NSEvent.removeMonitor(eventMonitor) }
    eventMonitor = nil
  }

  private func openSettings() {
    hidePanel()
    if settingsWindow == nil { settingsWindow = EmberSettings.makeWindow() }
    settingsWindow?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc private func quitApp() {
    stop()
    NSApp.terminate(nil)
  }
}
