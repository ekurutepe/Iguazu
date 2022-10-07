// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Iguazu",
    platforms: [
        .iOS(.v12),
        .watchOS(.v9),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Iguazu",
            targets: ["Iguazu"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Iguazu",
            dependencies: []),
        .testTarget(
            name: "IguazuTests",
            dependencies: ["Iguazu"]),
    ]
)
