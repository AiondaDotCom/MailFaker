// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "MailFaker",
    products: [
        .library(
            name: "MailFaker",
            targets: ["MailFaker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MailFaker",
            dependencies: []),
        .testTarget(
            name: "MailFakerTests",
            dependencies: ["MailFaker"]),
    ]
)
