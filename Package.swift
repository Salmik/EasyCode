// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyCode",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "EasyCode",
            targets: ["EasyCode"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "EasyCode",
            dependencies: [],
            path: "EasyCode/Source"
        ),
        .testTarget(
            name: "EasyCodeTests",
            dependencies: ["EasyCode"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
