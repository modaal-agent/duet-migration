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
- **Licensing**: MIT, inbound = outbound; submitting a PR means your
  contribution is licensed under the [MIT License](LICENSE).
