// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EnrollCapacitor",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "EnrollCapacitor",
            targets: ["EnrollPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "EnrollPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/EnrollPlugin"),
        .testTarget(
            name: "EnrollPluginTests",
            dependencies: ["EnrollPlugin"],
            path: "ios/Tests/EnrollPluginTests")
    ]
)