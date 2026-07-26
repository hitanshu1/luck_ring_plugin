// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "luck_ring_plugin",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "luck-ring-plugin", targets: ["luck_ring_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        // The vendored Luck Ring SDK. SwiftPM only accepts XCFrameworks as binary
        // targets, so BluetoothLibrary.framework is wrapped in an XCFramework that
        // the CocoaPods podspec vendors as well.
        .binaryTarget(
            name: "BluetoothLibrary",
            path: "Frameworks/BluetoothLibrary.xcframework"
        ),
        .target(
            name: "luck_ring_plugin",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "BluetoothLibrary",
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                .linkedFramework("CoreBluetooth")
            ]
        ),
    ]
)
