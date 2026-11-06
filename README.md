# DevEx Platform Portfolio

[![platform-ci](https://github.com/srstanl/portfolio/actions/workflows/platform-ci.yml/badge.svg?branch=main)](https://github.com/srstanl/portfolio/actions/workflows/platform-ci.yml)
[![dotnet-example-ci](https://github.com/srstanl/portfolio/actions/workflows/dotnet-example-ci.yml/badge.svg?branch=main)](https://github.com/srstanl/portfolio/actions/workflows/dotnet-example-ci.yml)
[![python-example-ci](https://github.com/srstanl/portfolio/actions/workflows/python-example-ci.yml/badge.svg?branch=main)](https://github.com/srstanl/portfolio/actions/workflows/python-example-ci.yml)
[![node-example-ci](https://github.com/srstanl/portfolio/actions/workflows/node-example-ci.yml/badge.svg?branch=main)](https://github.com/srstanl/portfolio/actions/workflows/node-example-ci.yml)
[![web-angular-ci](https://github.com/srstanl/portfolio/actions/workflows/web-angular-ci.yml/badge.svg?branch=main)](https://github.com/srstanl/portfolio/actions/workflows/web-angular-ci.yml)

Platform-first portfolio repository focused on Internal Developer Platform (IDP) patterns, golden-path delivery, and the broader portfolio narrative around platform consumers.

## Portfolio Philosophy
- Examples are intentionally varied to demonstrate range, not framework preference.
- Technology choices are context-driven (team constraints, platform fit, and delivery goals).
- The core signal is safe, repeatable software delivery through explicit quality and security controls.

## Repository Layout
- Portfolio asset boundary plan: [docs/portfolio-asset-boundary-plan.md](docs/portfolio-asset-boundary-plan.md)
- `devex_platform/` Named boundary for the DevEx platform as a portfolio asset
- `platform/` Infrastructure and shared platform components
- `idp/` Developer portal and catalog integration
- `templates/` Service templates (scaffolding and standards)
- `paved-roads/` Delivery, policy, and OTEL telemetry standards
- `examples/` Platform-native reference adopters that prove the platform contract
- `docs/` Architecture and operating model

## Getting Started
Read [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) for the current handoff and [the November 6 reconciliation](docs/reconciliation-2026-11-06.md) for verified tracking and remaining gaps.

`make bootstrap`, `make lint`, and `make test` are placeholders apart from structure validation. Run the service-specific commands in [the developer guide](docs/developer-guide.md) for actual application checks.

The merged reference delivery path is Floci AKS → Argo CD → Python/.NET rollout and health verification. Follow [the local infrastructure runbook](docs/local-infra.md). Registry-backed promotion is proposed in [PR #40](https://github.com/srstanl/portfolio/pull/40) and is not merged.

## Service Scaffolding
- Generate new services from templates: `make scaffold-service TEMPLATE=service-python NAME=my-service`

## Developer Setup
- Local runbooks and CI-aligned commands: [docs/developer-guide.md](docs/developer-guide.md)
- Contribution workflow and project-board conventions: [CONTRIBUTING.md](CONTRIBUTING.md)
- Service-specific details:
  - [examples/dotnet-service/README.md](examples/dotnet-service/README.md)
  - [examples/python-service/README.md](examples/python-service/README.md)
  - [examples/node-service/README.md](examples/node-service/README.md)
  - [examples/web-angular/README.md](examples/web-angular/README.md)

## CI/CD Model
- Path-filtered workflows per domain
- Shared CI checks in `.github/workflows/platform-ci.yml`; delivery standards in `paved-roads/README.md`
- Current reference releases reconcile Git desired state through Argo CD; manual CD wrappers are historical delivery lanes
- Example services validated independently
- CI workflow map: [docs/ci-workflow-map.md](docs/ci-workflow-map.md)
- Local vs cloud requirements baseline: [docs/local-vs-cloud-requirements.md](docs/local-vs-cloud-requirements.md)
- Problem recommender adoption plan: [docs/problem-recommender-platform-adoption.md](docs/problem-recommender-platform-adoption.md)

## Delivery Tracking
- Current reconciliation: [docs/reconciliation-2026-11-06.md](docs/reconciliation-2026-11-06.md)
- Current Floci/Argo CD proof: [docs/local-infra.md](docs/local-infra.md)
- GitHub Project v1 setup runbook: [docs/github-project-v1.md](docs/github-project-v1.md)
- Historical manual-workflow deployment contract: [docs/deployment-contract.md](docs/deployment-contract.md)
- Historical Python CD runbook: [docs/python-cd.md](docs/python-cd.md)
- Historical Node CD runbook: [docs/node-cd.md](docs/node-cd.md)
- Historical .NET CD runbook: [docs/dotnet-cd.md](docs/dotnet-cd.md)

## License
AGPL-3.0. See `LICENSE`.

## Asset Model
- `devex_platform` is the named platform asset inside this repository.
- The current top-level platform directories remain in place for now; `devex_platform/` marks the logical asset boundary before any larger code move.
- The logical producer, reference-adopter, consumer, and governance boundaries are defined in [docs/platform-asset-charter.md](docs/platform-asset-charter.md).
- Future consumer-grade portfolio projects should appear as separate assets, not as subdirectories inside the platform tree by default.

## Migration Note
Previous monorepo was archived on April 21, 2026.
