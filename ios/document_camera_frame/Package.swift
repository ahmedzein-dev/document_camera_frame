// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "document_camera_frame",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // The library (product) name must be hyphen-separated: Swift Package Manager
        // uses it as the CFBundleIdentifier when linked dynamically, and that cannot
        // contain underscores. Flutter generates its dependency on this product as
        // `plugin.name.replaceAll('_', '-')`, so it must match exactly.
        // The package name and target name stay underscore-separated.
        .library(name: "document-camera-frame", targets: ["document_camera_frame"])
    ],
    targets: [
        .target(
            name: "document_camera_frame",
            path: "Sources/document_camera_frame"
        )
    ]
)
