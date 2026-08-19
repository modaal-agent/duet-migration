# Contributing

- **Recipes live in `docs/`, one page per recipe.** The README stays an
  index — a bullet per page with a one-sentence hook; content goes in the
  page.
- **Docs state the present rule, not the transition.** Write forward-looking,
  actionable instructions: what the migrator does, in what order, gated how.
  Legacy CombineRIBs shapes are this repo's subject — name them freely — but
  do not narrate the framework's own history ("X replaces Y", "previously",
  "no longer"); state what Duet does and what the migrator must do.
- **Tests run on an iOS simulator destination** — CombineRIBs is UIKit-bound,
  so there is no host (macOS) test lane here.
- **Test doubles never live in a product's `Sources/`, `#if DEBUG`
  included.** A DEBUG gate keeps a double out of release binaries, not out of
  the module's API surface or its compile graph. A double one test target
  uses lives in that test target; a double shared across targets or with
  consumers ships in a dedicated test-support library product that only test
  targets link.
- **Licensing**: MIT, inbound = outbound; submitting a PR means your
  contribution is licensed under the [MIT License](LICENSE).
