// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyCode",
    platforms: [.iOS(.v14)],
    products: [.library(name: "EasyCode", targets: ["EasyCode"])],
    targets: [.target(name: "EasyCode", path: "EasyCode/Source")],
    swiftLanguageVersions: [.v5]
)
