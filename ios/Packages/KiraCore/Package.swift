// swift-tools-version:5.9
import PackageDescription

// Kira's logic with no UI: parsing what people say, categories, totals and screenshot reading.
// iOS only for now. It only depends on Foundation; the tests run on the iOS Simulator.
let package = Package(
    name: "KiraCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "KiraCore", targets: ["KiraCore"]),
    ],
    targets: [
        .target(name: "KiraCore"),
        .testTarget(name: "KiraCoreTests", dependencies: ["KiraCore"]),
    ]
)
