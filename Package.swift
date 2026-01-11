// swift-tools-version: 6.2
import PackageDescription

// RFC 4648: The Base16, Base32, and Base64 Data Encodings
let package = Package(
    name: "swift-rfc-4648",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "RFC 4648", targets: ["RFC 4648"]),
        .library(name: "RFC 4648 Foundation", targets: ["RFC 4648 Foundation"]),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
        .package(path: "../swift-incits-4-1986"),
    ],
    targets: [
        .target(
            name: "RFC 4648",
            dependencies: [
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("Lifetimes"),
            ]
        ),
        .target(
            name: "RFC 4648 Foundation",
            dependencies: [
                "RFC 4648",
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
            ]
        ),
        .testTarget(
            name: "RFC 4648 Tests",
            dependencies: ["RFC 4648"]
        ),
        .testTarget(
            name: "RFC 4648 Foundation Tests",
            dependencies: ["RFC 4648 Foundation"]
        ),
    ]
)
