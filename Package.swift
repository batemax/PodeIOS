// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PodeIOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "PodeIOS", targets: ["PodeIOS"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PodeIOS",
            dependencies: [],
            path: "Sources/PodeIOS"
        ),
        .testTarget(
            name: "PodeIOSTests",
            dependencies: ["PodeIOS"],
            path: "Tests/PodeIOSTests"
        ),
    ]
)
