// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "ExtensibleEnumKit",
  platforms: [.macOS(.v13), .iOS(.v13)],
  products: [
    // This is what users actually 'import'
    .library(name: "ExtensibleEnumKit", targets: ["ExtensibleEnumKit"])
  ],
  dependencies: [
    // Macros require swift-syntax
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
  ],
  targets: [
    // 1. The Macro Implementation (The logic)
    .macro(
      name: "ExtensibleEnumMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),

    // 2. The Public Library (The protocol, base class, and macro declaration)
    .target(
      name: "ExtensibleEnumKit",
      dependencies: ["ExtensibleEnumMacros"]
    ),

    // 3. Tests
    .testTarget(
      name: "ExtensibleEnumKitTests",
      dependencies: [
        "ExtensibleEnumKit",
        "ExtensibleEnumMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
