// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "document_camera_frame",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "document_camera_frame", targets: ["document_camera_frame"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "document_camera_frame",
            dependencies: [],
            path: "Classes",
            resources: []
        )
    ]
)
