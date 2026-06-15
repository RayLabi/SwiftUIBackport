// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUI-backport",
    platforms: [
      .iOS(.v16),
    ],
    products: [
        .library(
            name: "SwiftUIBackport",
            targets: ["SwiftUIBackport"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftUIBackport"
        ),
    ]
)


for target in package.targets where target.type != .system {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(contentsOf: [
    .enableExperimentalFeature("StrictConcurrency"),
  ])
}
