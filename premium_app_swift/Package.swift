// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SantVaani",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SantVaani", targets: ["SantVaani"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SantVaani",
            dependencies: [],
            path: "Sources/SantVaani"
        )
    ]
)
