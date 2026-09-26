import XCTest
@testable import EmberCore

final class AgentTests: XCTestCase {
  func testCatalogSplitsDetection() {
    XCTAssertEqual(AgentKind.hookAgents.count, 7)
    XCTAssertEqual(
      AgentKind.processAgents.map(\.rawValue).sorted(),
      ["cline", "cursor"]
    )
  }

  func testProcessMatch() {
    XCTAssertEqual(detectAgent(fromProcessName: "cursor-agent"), .cursor)
    XCTAssertEqual(detectAgent(fromProcessName: "/Apps/Cline"), .cline)
    XCTAssertNil(detectAgent(fromProcessName: "Safari"))
  }

  func testDisplayNames() {
    for agent in AgentKind.allCases {
      XCTAssertFalse(agent.displayName.isEmpty)
    }
  }
}
