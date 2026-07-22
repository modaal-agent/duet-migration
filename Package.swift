// swift-tools-version:6.0

// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import PackageDescription

// Duet's CombineRIBs migration kit — deliberately a SEPARATE package/repo:
// SwiftPM resolves package-level dependencies for every consumer regardless of
// which products they link, so these helpers must never live inside the core
// Duet package or every Duet consumer (greenfield apps included) would fetch
// and pin the frozen CombineRIBs fork forever. Adopting apps add this package
// FOR THE MIGRATION and delete the dependency at the end — the strangler
// discipline expressed as a dependency edge.
let package = Package(
  name: "DuetMigration",
  platforms: [
    // CombineRIBs is UIKit-bound — iOS only (the receipts run on a simulator
    // lane, not the host `swift test` lane).
    .iOS(.v16)
  ],
  products: [
    .library(name: "DuetCombineRIBsMigration", targets: ["DuetCombineRIBsMigration"])
  ],
  dependencies: [
    // Local path while Duet is unpublished — flip to
    // .package(url: "https://github.com/modaal-agent/duet.git", from: …)
    // at the public release.
    .package(path: "../modaal-agent-duet"),
    .package(url: "https://github.com/modaal-agent/CombineRIBs.git", from: "2.1.0"),
  ],
  targets: [
    .target(
      name: "DuetCombineRIBsMigration",
      dependencies: [
        .product(name: "DuetShells", package: "modaal-agent-duet"),
        .product(name: "CombineRIBs", package: "CombineRIBs"),
      ]
    ),
    .testTarget(
      name: "DuetCombineRIBsMigrationTests",
      dependencies: [
        .target(name: "DuetCombineRIBsMigration")
      ]
    ),
  ]
)
