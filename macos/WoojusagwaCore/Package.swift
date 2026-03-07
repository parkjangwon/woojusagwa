// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WoojusagwaCore",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "WoojusagwaCore",
            targets: ["WoojusagwaCore"]
        ),
    ],
    targets: [
        .target(
            name: "WoojusagwaCore"
        ),
        .testTarget(
            name: "WoojusagwaCoreTests",
            dependencies: ["WoojusagwaCore"]
        ),
    ]
)
