// swift-tools-version: 6.2
import PackageDescription

// RFC 4648: The Base16, Base32, and Base64 Data Encodings
let package = Package(
    name: "swift-rfc-4648",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
    ],
    products: [
        .library(name: "RFC 4648", targets: ["RFC 4648"]),
        .library(name: "RFC 4648 Foundation", targets: ["RFC 4648 Foundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.8.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: "RFC 4648",
            dependencies: [
                .product(name: "Standards", package: "swift-standards"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
            ]
        ),
        .target(
            name: "RFC 4648 Foundation",
            dependencies: [
                "RFC 4648",
                .product(name: "Standards", package: "swift-standards"),
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
