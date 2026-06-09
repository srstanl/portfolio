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
- `platform/` Infrastructure and shared platform components
- `idp/` Developer portal and catalog integration
- `templates/` Service templates (scaffolding and standards)
- `paved-roads/` Reusable CI/CD, policies, observability defaults
- `examples/` Reference services that consume the platform contract
- `docs/` Architecture and operating model

## Getting Started
```bash
make bootstrap
make lint
make test
```

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
- Shared checks in `paved-roads/ci-cd`
- Example services validated independently
- CI workflow map: [docs/ci-workflow-map.md](docs/ci-workflow-map.md)
- Local vs cloud requirements baseline: [docs/local-vs-cloud-requirements.md](docs/local-vs-cloud-requirements.md)
- Problem recommender adoption plan: [docs/problem-recommender-platform-adoption.md](docs/problem-recommender-platform-adoption.md)

## Delivery Tracking
- GitHub Project v1 setup runbook: [docs/github-project-v1.md](docs/github-project-v1.md)
- Provider-agnostic deployment contract: [docs/deployment-contract.md](docs/deployment-contract.md)
- Python CD runbook: [docs/python-cd.md](docs/python-cd.md)
- Node CD runbook: [docs/node-cd.md](docs/node-cd.md)
- .NET CD runbook: [docs/dotnet-cd.md](docs/dotnet-cd.md)

## License
AGPL-3.0. See `LICENSE`.

## Migration Note
Previous monorepo was archived on April 21, 2026.
