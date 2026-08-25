# Platform Asset Charter

## Purpose

Define the logical `devex_platform` asset without forcing a premature directory migration.

The repository is the outer portfolio boundary. `devex_platform` is the producer-side platform asset within it; it is not a claim that every repository file or future portfolio project is platform code.

## Logical Composition

The following roots together form the current platform producer:

- `platform/` — local runtime, Argo CD Applications, shared delivery configuration, and platform-owned operational assets.
- `idp/` — developer portal and catalog integration.
- `templates/` — golden-path service scaffolds.
- `paved-roads/` — delivery standards and reusable defaults.
- `scripts/infra/` — local platform lifecycle and proof tooling.
- shared CI/CD workflow and policy assets under `.github/`.

`devex_platform/` is the durable marker for that logical grouping. It is intentionally not a physical parent directory yet.

## Reference Adopters

`examples/` contains platform-native reference adopters. The Python and .NET services are controlled proof workloads used to validate the paved road; they are not independently onboarded consumer products.

Their GitOps manifests remain platform-owned while they are reference adopters:

- `platform/cd/<example>/`
- `platform/argocd/applications/<example>.yaml`

When a real consumer is onboarded, its workload and desired deployment state should be owned with that consumer rather than added beneath the platform's reference paths.

## Portfolio Consumers

Future consumer-grade assets belong outside the platform producer boundary. A `projects/` boundary should be introduced only when a real portfolio-grade consumer is ready to occupy it. Until then, candidates such as `problem_recommender` remain external/onboarding candidates.

## Repository Governance

Repository-wide documents, contribution rules, and board automation govern the portfolio repository. They support the platform but are not, by themselves, a separate platform product boundary.

## Non-Goals

- No mass directory rename or code move.
- No empty `projects/` placeholder.
- No change to the deferred observability decision.
- No change to local Floci, Argo CD, or delivery-proof behavior.
