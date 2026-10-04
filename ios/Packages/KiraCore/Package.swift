// swift-tools-version:5.9
import PackageDescription

// Platform-independent logic: parsing what people say, categories, totals and screenshot reading.
// It only depends on Foundation, so `swift test` runs it without a simulator.
let package = Package(
    name: "KiraCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "KiraCore", targets: ["KiraCore"]),
    ],
    targets: [
        .target(name: "KiraCore"),
        .testTarget(name: "KiraCoreTests", dependencies: ["KiraCore"]),
    ]
)
