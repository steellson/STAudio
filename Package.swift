// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STAudio",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "STAudio",
            targets: [
                "STAudio"
            ]
        )
    ],
    dependencies: [
//        .package(
//            name: "SUtils",
//            path: "/Users/steellson/Desktop/dev/swift/SUtils"
//        )
    ],
    targets: [
        .target(
            name: "STAudio",
            dependencies: [
//                .byName(name: "SUtils")
            ]
        ),
    ]
)
