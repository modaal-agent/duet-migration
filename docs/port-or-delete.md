# Port or delete

What each legacy CombineRIBs shape becomes on the Duet side. "Port" means the
type survives the migration; "delete" means its job moves into a Duet
construct and the type goes.

| legacy shape | Duet equivalent | port or delete |
| --- | --- | --- |
| `<X>Dependency` protocol | `<X>Dependency` protocol | **port unchanged** |
| `<X>Component` | `<X>Component` | **port**; add the environment factory as a Component member, and check the one-Component-per-mount obligation (both in the framework's `docs/composition.md`) |
| `<X>Builder` / `<X>Buildable` | `<X>Builder` / `<X>Buildable` | **port**; strip dependency resolution — a Duet Builder constructs the Component once per mount and resolves nothing — keep the mount job |
| `<X>Router` | the shell's state-driven child mounting | **delete** |
| `<X>Interactor` | `<X>ViewShell` + the store | **port the logic, delete the type** |
| RIBs `Worker` | `DuetShells.Working` + `host.adopt` | **port**, via this package's `InteractorScope.adopt` while Routers still stand |

The Dependency/Component/Builder triad is the migration's *destination*, not
its residue: Duet's composition shape is the same pair at every level —
`docs/composition.md` in the `duet` repo states the rule, the scope-ownership
contract, and the factory placement the ported Component must satisfy.
