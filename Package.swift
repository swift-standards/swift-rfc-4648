// swift-tools-version: 6.0
import PackageDescription

// RFC 4648: The Base16, Base32, and Base64 Data Encodings
let package = Package(
    name: "swift-rfc-4648",
    products: [
        .library(name: "RFC_4648", targets: ["RFC_4648"])
    ],
    dependencies: [
        .package(path: "../swift-standards")
    ],
    targets: [
        .target(
            name: "RFC_4648",
            dependencies: [
                .product(name: "Standards", package: "swift-standards")
            ]
        ),
        .testTarget(
            name: "RFC_4648_Tests",
            dependencies: ["RFC_4648"]
        )
    ]
)
