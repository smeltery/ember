// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "ember",
  platforms: [.macOS(.v14)],
  products: [
    .library(name: "EmberCore", targets: ["EmberCore"]),
    .executable(name: "Ember", targets: ["Ember"]),
    .executable(name: "EmberCoreSmoke", targets: ["EmberCoreSmoke"]),
  ],
  targets: [
    .target(
      name: "EmberCore",
      path: "Sources/EmberCore"
    ),
    .executableTarget(
      name: "Ember",
      dependencies: ["EmberCore"],
      path: "Sources/Ember"
    ),
    // CLT-friendly checks when Xcode/XCTest is unavailable.
    .executableTarget(
      name: "EmberCoreSmoke",
      dependencies: ["EmberCore"],
      path: "Sources/EmberCoreSmoke"
    ),
    .testTarget(
      name: "EmberCoreTests",
      dependencies: ["EmberCore"],
      path: "Tests/EmberCoreTests"
    ),
  ]
)
