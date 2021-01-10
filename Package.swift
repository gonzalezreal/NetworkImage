// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkImage",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v3),
    ],
    products: [
        .library(name: "NetworkImage", targets: ["NetworkImage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.1.2"),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.8.2"
        ),
    ],
    targets: [
        .target(
            name: "NetworkImage",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
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
