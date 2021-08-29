// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkImage",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "NetworkImage", targets: ["NetworkImage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.5.2"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.1"),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        ),
    ],
    targets: [
        .target(
            name: "NetworkImage",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ]
        ),
        .testTarget(
            name: "NetworkImageTests",
            dependencies: [
                "NetworkImage",
                "SnapshotTesting",
            ],
            exclude: [
                "__Snapshots__",
                "__Fixtures__",
            ]
        ),
    ]
)
