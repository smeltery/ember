import XCTest
@testable import EmberCore

final class AgentTests: XCTestCase {
  func testCatalogSplitsDetection() {
    XCTAssertEqual(AgentKind.hookAgents.count, 7)
    XCTAssertEqual(
      AgentKind.processAgents.map(\.rawValue).sorted(),
      ["aider", "amp", "cline", "continue", "cursor", "goose", "warp", "windsurf"]
    )
  }

  func testProcessMatch() {
    XCTAssertEqual(detectAgent(fromProcessName: "cursor-agent"), .cursor)
    XCTAssertEqual(detectAgent(fromProcessName: "/Apps/Cline"), .cline)
    XCTAssertEqual(detectAgent(fromProcessName: "Warp"), .warp)
    XCTAssertEqual(detectAgent(fromProcessName: "aider"), .aider)
    XCTAssertEqual(detectAgent(fromProcessName: "Windsurf"), .windsurf)
    XCTAssertNil(detectAgent(fromProcessName: "Safari"))
    XCTAssertNil(detectAgent(fromProcessName: "sample"))
  }

  func testDisplayNames() {
    for agent in AgentKind.allCases {
      XCTAssertFalse(agent.displayName.isEmpty)
    }
  }
}
