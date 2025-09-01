// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PasskeysBackend",
    platforms: [
       .macOS(.v12),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-server/swift-webauthn.git", from: "1.0.0-alpha.2")
    ],
    targets: [
        .executableTarget(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "WebAuthn", package: "swift-webauthn"),
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "VaporTesting", package: "vapor"),
        ])
    ]
)
