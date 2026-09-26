import XCTest
@testable import EmberCore

final class SessionTests: XCTestCase {
  func testParseWorking() {
    let json = #"{"state":"working","agent":"claude-code","updatedAt":"2026-01-01T00:00:00Z"}"#
    let snap = parseSessionJSON(json)
    XCTAssertEqual(snap?.state, .working)
    XCTAssertEqual(snap?.agent, "claude-code")
    XCTAssertEqual(snap?.isWorking, true)
  }

  func testParseIdleCaseInsensitive() {
    XCTAssertEqual(parseSessionJSON(#"{"state":"Idle"}"#)?.state, .idle)
  }

  func testParseAgentIdAlias() {
    let snap = parseSessionJSON(#"{"state":"Working","agentId":"opencode"}"#)
    XCTAssertEqual(snap?.agent, "opencode")
  }

  func testRejectsBadJSON() {
    XCTAssertNil(parseSessionJSON("not-json"))
    XCTAssertNil(parseSessionJSON("{}"))
    XCTAssertNil(parseSessionJSON(#"{"state":"busy"}"#))
  }

  func testPathsNestedByAgent() {
    let url = EmberPaths.sessionFile(
      homeDir: "/Users/ada",
      agentId: "claude-code",
      sessionId: "abc/../x"
    )
    XCTAssertEqual(
      url.path,
      "/Users/ada/Library/Application Support/ember/sessions/claude-code/abc_.._x.json"
    )
  }
}
