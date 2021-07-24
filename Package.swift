// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VIPER",
    platforms: [
        .macOS(.v10_10), .iOS(.v10), .tvOS(.v10),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "viper-tools",
            targets: ["VIPERCommandLine"]),
        .library(
            name: "VIPER",
            targets: ["VIPER"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.5")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VIPER",
            dependencies: []),
        .target(
            name: "VIPERCommandLine",
            dependencies: ["ArgumentParser"]),
        .testTarget(
            name: "VIPERTests",
            dependencies: ["VIPER"]),
    ]
)
