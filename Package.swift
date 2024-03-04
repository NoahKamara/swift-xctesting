// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-xctesting",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "XCTesting",
            targets: ["XCTesting"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.5.1"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.2.2"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "XCTesting",
            dependencies: [
                "XCTestingMacros",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),

        .macro(
            name: "XCTestingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Integration Tests actively using the library
        .testTarget(
            name: "XCTestingTests",
            dependencies: [
                "XCTesting",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        
        // Macro Tests testing expansio
        .testTarget(
            name: "MacrosTests",
            dependencies: [
                "XCTestingMacros",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)

