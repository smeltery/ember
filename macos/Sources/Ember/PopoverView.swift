import AppKit
import SwiftUI

struct AgentRowModel: Identifiable, Equatable {
  let id: String
  let name: String
  let detail: String
  let isWorking: Bool
}

@MainActor
final class PopoverModel: ObservableObject {
  @Published var enabled = true
  @Published var subtitle = "Idle"
  @Published var batteryPercent = 100
  @Published var cutoffPercent = 15
  @Published var workingCount = 0
  @Published var agents: [AgentRowModel] = []
  @Published var isPaused = false

  var onToggleEnabled: ((Bool) -> Void)?
  var onPause30: (() -> Void)?
  var onPause1h: (() -> Void)?
  var onResume: (() -> Void)?
  var onSettings: (() -> Void)?
  var onQuit: (() -> Void)?
}

struct PopoverView: View {
  @ObservedObject var model: PopoverModel

  private let muted = Color.white.opacity(0.55)
  private let hairline = Color.white.opacity(0.1)
  private let pillFill = Color(white: 0.47).opacity(0.28)
  private let green = Color(red: 0.19, green: 0.82, blue: 0.35)

  var body: some View {
    VStack(spacing: 0) {
      header
      divider
      battery
      divider
      agents
      divider
      pause
      divider
      footer
    }
    .frame(width: 288)
    .background(panelBackground)
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
    )
  }

  private var panelBackground: some View {
    RoundedRectangle(cornerRadius: 14, style: .continuous)
      .fill(.ultraThinMaterial)
      .environment(\.colorScheme, .dark)
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(Color(red: 0.14, green: 0.14, blue: 0.15).opacity(0.72))
      )
  }

  private var header: some View {
    HStack(alignment: .center, spacing: 10) {
      VStack(alignment: .leading, spacing: 2) {
        Text("ember")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(.white)
        Text(model.subtitle)
          .font(.system(size: 11.5))
          .foregroundStyle(muted)
          .monospacedDigit()
      }
      Spacer(minLength: 0)
      Toggle("", isOn: Binding(
        get: { model.enabled },
        set: { model.onToggleEnabled?($0) }
      ))
      .toggleStyle(.switch)
      .labelsHidden()
      .tint(Color(red: 0.04, green: 0.52, blue: 1.0))
      .controlSize(.small)
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 11)
  }

  private var battery: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Battery")
        .font(.system(size: 12.5, weight: .semibold))
        .foregroundStyle(.white)
      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule().fill(Color(white: 0.47).opacity(0.32))
          Capsule()
            .fill(green)
            .frame(width: geo.size.width * CGFloat(min(max(model.batteryPercent, 0), 100)) / 100)
        }
      }
      .frame(height: 6)
      HStack {
        Text("\(model.batteryPercent)% left")
          .font(.system(size: 11.5))
          .foregroundStyle(.white)
        Spacer()
        Text("stops below \(model.cutoffPercent)%")
          .font(.system(size: 11.5))
          .foregroundStyle(muted)
      }
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 10)
  }

  private var agents: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text("Agents")
          .font(.system(size: 12.5, weight: .semibold))
          .foregroundStyle(.white)
        Spacer()
        Text("\(model.workingCount) working")
          .font(.system(size: 11.5))
          .foregroundStyle(muted)
      }
      if model.agents.isEmpty {
        Text("No agents yet")
          .font(.system(size: 12.5))
          .foregroundStyle(muted)
      } else {
        ForEach(model.agents) { agent in
          agentRow(agent)
        }
      }
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 10)
  }

  private func agentRow(_ agent: AgentRowModel) -> some View {
    HStack(spacing: 8) {
      RoundedRectangle(cornerRadius: 3, style: .continuous)
        .fill(Color.white.opacity(agent.isWorking ? 0.22 : 0.1))
        .frame(width: 16, height: 16)
      Text(agent.name)
        .font(.system(size: 12.5, weight: .medium))
        .foregroundStyle(agent.isWorking ? Color.white : muted.opacity(0.82))
        .lineLimit(1)
      Spacer(minLength: 0)
      HStack(spacing: 6) {
        Text(agent.detail)
          .font(.system(size: 11.5))
          .foregroundStyle(muted)
        if agent.isWorking {
          Circle()
            .fill(green)
            .frame(width: 6, height: 6)
            .shadow(color: green.opacity(0.45), radius: 2)
        }
      }
    }
    .frame(minHeight: 22)
  }

  private var pause: some View {
    HStack {
      Text("Pause")
        .font(.system(size: 12.5, weight: .semibold))
        .foregroundStyle(.white)
      Spacer()
      HStack(spacing: 6) {
        if model.isPaused {
          pill("Resume") { model.onResume?() }
        } else {
          pill("30 min") { model.onPause30?() }
          pill("1 hour") { model.onPause1h?() }
        }
      }
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 10)
  }

  private func pill(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 11.5, weight: .medium))
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(
          RoundedRectangle(cornerRadius: 7, style: .continuous).fill(pillFill)
        )
    }
    .buttonStyle(.plain)
  }

  private var footer: some View {
    VStack(spacing: 4) {
      footerRow("Settings…", shortcut: "⌘,") { model.onSettings?() }
      footerRow("Quit ember", shortcut: "⌘Q") { model.onQuit?() }
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 10)
  }

  private func footerRow(_ title: String, shortcut: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack {
        Text(title)
          .font(.system(size: 12.5, weight: .medium))
          .foregroundStyle(.white)
        Spacer()
        Text(shortcut)
          .font(.system(size: 12.5))
          .foregroundStyle(Color.white.opacity(0.4))
      }
      .frame(minHeight: 22)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  private var divider: some View {
    Rectangle().fill(hairline).frame(height: 0.5)
  }
}
