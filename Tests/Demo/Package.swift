// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Demo",
    products: [
        .library(name: "demo", type: .dynamic, targets: ["Demo"]),
    ],
    dependencies: [
        .package(path: "../../"),
    ],
    targets: [
        .target(name: "Trampoline",
                    dependencies: [.product(name: "NapiC", package: "swift-napi")],
                    linkerSettings: [.unsafeFlags(["-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup"])]),
        .target(name: "Demo",
                    dependencies: [.product(name: "Napi", package: "swift-napi"), "Trampoline"],
                    linkerSettings: [.unsafeFlags(["-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup"])]),
    ]
)
