// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DefaultsKit",
    platforms: [.macOS(.v15)],
    products: [
        .defaultsKit
    ],
    dependencies: [
        .asynchrone,
        .concurrencyExtras
    ],
    targets: [
        .defaultsKit,
        .defaultsKitTests
    ]
)

private enum Names {
    static let defaultsKit = "DefaultsKit"
}

private extension Product {
    static func library(name: String) -> Product {
        .library(name: name, targets: [name])
    }
    
    static var defaultsKit: Product {
        library(name: Names.defaultsKit)
    }
}

private extension Target {
    static var defaultsKit: Target {
        .target(name: Names.defaultsKit, dependencies: [.asynchrone, .concurrencyExtras])
    }
}

private enum TestNames {
    static let defaultsKitTests = "DefaultsKitTests"
}

private extension Target {
    static var defaultsKitTests: Target {
        .testTarget(name: TestNames.defaultsKitTests, dependencies: [.defaults])
    }
}

private extension Target.Dependency {
    static var defaults: Target.Dependency { "DefaultsKit" }
}

private extension Target.Dependency {
    static var asynchrone: Target.Dependency {
        .product(name: "Asynchrone", package: "Asynchrone")
    }
    
    static var concurrencyExtras: Target.Dependency {
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras")
    }
}

private extension Package.Dependency {
    static var asynchrone: Package.Dependency {
        .package(url: "https://github.com/reddavis/Asynchrone", exact: "0.21.0")
    }
    
    static var concurrencyExtras: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras.git", exact: "1.3.2")
    }
}
