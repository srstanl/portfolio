# DevEx Platform Portfolio

Platform-first portfolio repository focused on Internal Developer Platform (IDP) patterns and golden-path delivery.

## Repository Layout
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

## CI/CD Model
- Path-filtered workflows per domain
- Shared checks in `paved-roads/ci-cd`
- Example services validated independently

## Migration Note
Previous monorepo preserved as: `../portfolio-legacy-2026-04-21`
