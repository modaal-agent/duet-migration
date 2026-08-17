# duet-migration

CombineRIBs coexistence helpers for [Duet](https://github.com/modaal-agent/duet)
adopters — the migration kit a legacy RIBs app adds **for the duration of its
migration and deletes at the end**.

## Why a separate repo

SwiftPM resolves package-level dependencies for every consumer regardless of
which products they link. If these helpers lived inside the core Duet package,
every Duet consumer — greenfield apps included — would fetch and pin the frozen
CombineRIBs fork forever. Keeping them here keeps the core package's dependency
graph RIBs-free, and makes the migration itself visible as a single dependency
edge: add this package to start, delete the dependency to finish.

(SwiftPM also resolves one URL package per repository root, so this could never
ride along inside the `duet` repo anyway.)

## What's inside

- **`DuetCombineRIBsMigration`** — `InteractorScope.adopt(_ worker:)`: runs a
  Duet `Working` inside a CombineRIBs Interactor's active bracket (activation
  starts `run()`, deactivation cancels it), so workers convert one at a time
  while Routers still stand. ~20 LOC; receipt-tested against a real
  `Interactor` (iOS simulator lane — CombineRIBs is UIKit-bound).

  Note the deliberate deviation from the Duet-native bracket: RIBs re-fires
  the bracket per activate cycle, so re-activation re-enters `run()` on the
  same instance; `StoreHost.adopt` is one-instance-per-mount instead.

The dual-import discipline travels with the shim: CombineRIBs exports
`Working`/`Worker` too, so a file that imports CombineRIBs must never utter the
bare `Working` identifier — this module is the single sanctioned exception and
module-qualifies both sides.

## Migration recipes

Recipes live in [docs/](docs/), one page per recipe:

- **[docs/port-or-delete.md](docs/port-or-delete.md)** — what each legacy
  RIBs shape becomes on the Duet side: the Dependency/Component/Builder triad
  ports (it is the migration's destination), the Router deletes, the
  Interactor's logic moves into a `ViewShell`, and the RIBs `Worker` ports
  through this package's shim.

## Consuming

```swift
dependencies: [
  .package(url: "https://github.com/modaal-agent/duet-migration.git",
           .upToNextMinor(from: "0.1.0")),
],
targets: [
  .target(name: "App", dependencies: [
    .product(name: "DuetCombineRIBsMigration", package: "duet-migration"),
  ]),
]
```

This package resolves `duet` by URL at an exact tag. Pre-1.0 minors are
breaking by family convention, so moving to a newer framework tag is a
deliberate re-pin commit here.

## License

MIT — see [LICENSE](LICENSE).
