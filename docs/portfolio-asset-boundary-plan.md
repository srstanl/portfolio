# Portfolio Asset Boundary Plan

## Why This Exists

The current repository still reads as if the platform and the overall portfolio are the same thing.

That was acceptable when the platform itself was the only serious asset in the repository. It becomes less clear once a real onboarding candidate or future standalone portfolio project needs to appear alongside it.

The goal of this plan is to make the repository read as:
- one portfolio repository
- containing multiple portfolio assets
- with the platform as one major asset, not the entire identity of the repo

## Current Problem

Today, the top-level layout makes the platform feel synonymous with the entire repository:
- `platform/`
- `idp/`
- `templates/`
- `paved-roads/`
- `examples/`

This works while everything in the repo is platform-owned. It becomes less intuitive once an onboarded consumer such as `problem_recommender` needs to be shown as a separate portfolio asset rather than a random application dropped into the platform tree.

## Target Interpretation

The repository should eventually read as:
- `platform` is one portfolio asset
- onboarded consumers or showcase projects are separate portfolio assets
- repo-level docs explain how those assets relate to each other

That means the portfolio should tell a clearer story:
- the platform produces standards, paved roads, templates, and onboarding contracts
- consumers validate that the platform can onboard real projects
- not every meaningful artifact in the repo must be part of the platform itself

## Proposed Logical Model

### Portfolio level
The repository is the outer portfolio boundary.

### Platform asset
The platform asset is the producer side:
- internal developer platform patterns
- paved roads
- templates
- reusable CI/CD
- developer portal / catalog integration
- local infrastructure and runtime standards

### Consumer or showcase assets
Consumer or showcase assets are separate portfolio artifacts that use or validate the platform:
- onboarding candidates
- canary consumers
- reference adopters
- future standalone projects that belong in the portfolio narrative

## Recommended End-State Structure

This is the target conceptual layout, not an immediate mass-move:

```text
portfolio/
├── platform/                  # platform-owned runtime, infra, standards
├── idp/                       # developer portal and catalog integration
├── templates/                 # service scaffolds and golden paths
├── paved-roads/               # reusable delivery and policy defaults
├── examples/                  # platform-native example services
├── projects/                  # future portfolio projects or onboarded consumers
├── docs/                      # repo-level portfolio docs and operating model
└── scripts/                   # repo-level tooling and governance helpers
```

## Meaning of Each Top-Level Boundary

- `platform/`
  - infrastructure and platform runtime concerns
  - cluster/runtime delivery assets
  - platform-owned shared operational components

- `idp/`
  - portal and catalog concerns
  - this remains a platform-adjacent module

- `templates/`
  - golden path producer assets

- `paved-roads/`
  - shared standards, defaults, and reusable delivery logic

- `examples/`
  - intentionally platform-native reference services
  - good for showing the happy path in a controlled way

- `projects/`
  - future portfolio assets that are not themselves platform internals
  - likely home for later portfolio-grade onboarding consumers
  - should only be used once a project actually belongs in the portfolio rather than `playground` or `incubator`

## What This Means for `problem_recommender`

Right now, `problem_recommender` should not be inserted into `portfolio` as code.

At this stage it is better understood as:
- a `playground` project under active maturation
- a future onboarding candidate
- a future consumer of the platform contract

If it eventually becomes portfolio-grade, it should appear as a separate portfolio project, not as a platform subdirectory.

That means the first use of this boundary is conceptual, not operational:
- document the consumer model now
- move code only when the project has actually earned portfolio placement

## Staged Migration Plan

### Stage 1 — Clarify in docs only
Do this now.

- state explicitly that the portfolio repo can contain multiple asset types
- describe the platform as one major asset rather than the whole repository identity
- describe future onboarded consumers as separate portfolio artifacts
- do not move code yet

### Stage 2 — Introduce `projects/` only when needed
Do this when the first real portfolio-grade consumer exists.

- add a `projects/` top-level boundary
- keep it empty until there is a legitimate asset to place there
- avoid creating placeholder structure with no real occupant

### Stage 3 — Migrate only the right artifacts
When a project earns portfolio placement:
- place it under `projects/` or document it as a separate portfolio asset
- keep platform-owned code under platform-owned boundaries
- do not move platform internals just to make the tree look symmetric

### Stage 4 — Adjust repo-level docs and cataloging
Once multiple assets exist:
- update repo root docs to describe platform vs consumer assets
- optionally add catalog metadata or architectural index entries per asset
- make the repo navigable from a portfolio-reader perspective, not just a code-owner perspective

## What Not To Do

- do not mass-rename directories immediately
- do not move platform-owned code into a new folder just for aesthetics
- do not insert onboarding candidates into the platform tree to “keep everything together”
- do not create empty portfolio subtrees unless they are backing a real next step

## Immediate Recommendation

The next sensible move is:
- keep the code layout as-is for now
- update the repo docs so the platform is described as one portfolio asset
- reserve `projects/` as the likely future home for consumer-grade portfolio assets once one is actually ready

This gives a clearer narrative now without paying the cost of a repo-wide code move too early.
