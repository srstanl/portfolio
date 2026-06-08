# Repository Rulesets

This repo stores reusable GitHub repository ruleset payloads and a helper script so branch protection can be applied consistently without relying on manual UI setup.

## Files

- `scripts/github/rulesets/protect-main.json`
  - active baseline ruleset for `main`
- `scripts/github/apply-ruleset.sh`
  - helper script that applies a ruleset JSON to a repository with `gh api`

## Current `protect-main` Baseline

The baseline ruleset enforces:
- pull request required for `main`
- `1` approving review required
- review conversations must be resolved
- force-pushes blocked
- branch deletion blocked

## Usage

From the `portfolio/` repository root:

```bash
scripts/github/apply-ruleset.sh srstanl/playground
scripts/github/apply-ruleset.sh srstanl/incubator
```

To apply a different payload:

```bash
scripts/github/apply-ruleset.sh srstanl/playground path/to/custom-ruleset.json
```

## Verification

```bash
gh api repos/srstanl/playground/rulesets
gh api repos/srstanl/incubator/rulesets
```

## Notes

- Rulesets and classic branch protection are different GitHub mechanisms.
- The legacy branch-protection endpoint may still report `404 Branch not protected` even when a ruleset is active.
- Once a ruleset JSON is working, treat the JSON file as the source of truth rather than the UI.
