# CI Workflow Map

## Purpose
Quick reference for which GitHub Actions workflows run and how to trigger them.

## Manual Test Option
All workflows support manual execution via `workflow_dispatch`.

GitHub UI path:
1. Open `Actions` tab.
2. Select a workflow.
3. Click `Run workflow`.

## Trigger Matrix
- `platform-ci`
  - Triggered on PR/push when changing:
    - `platform/**`, `idp/**`, `paved-roads/**`, `examples/**`, `templates/**`, `scripts/**`, `.github/workflows/**`
  - Checks:
    - structure validation
    - `actionlint`
    - `gitleaks`
    - repo hygiene script
    - Dockerfile linting

- `dotnet-example-ci`
  - Triggered on PR/push when changing:
    - `examples/dotnet-service/**`, `templates/service-dotnet/**`
  - Checks:
    - restore, format, build, tests
    - dependency vulnerability scan
    - Dockerfile lint
    - container build + Trivy scan

- `python-example-ci`
  - Triggered on PR/push when changing:
    - `examples/python-service/**`, `templates/service-python/**`
  - Checks:
    - dependency install, lint, tests
    - dependency vulnerability scan
    - Dockerfile lint
    - container build + Trivy scan

- `node-example-ci`
  - Triggered on PR/push when changing:
    - `examples/node-service/**`, `templates/service-node/**`
  - Checks:
    - dependency install, lint, tests
    - dependency vulnerability scan
    - Dockerfile lint
    - container build + Trivy scan

- `web-angular-ci`
  - Triggered on PR/push when changing:
    - `examples/web-angular/**`
  - Checks:
    - dependency install, headless unit tests, build
    - dependency vulnerability scan
    - Dockerfile lint
    - container build + Trivy scan

- `idp-ci`
  - Triggered on PR/push when changing:
    - `idp/**`
  - Checks:
    - Backstage dependency install, lint, type-check, tests
    - dependency vulnerability scan
    - Dockerfile lint
    - container build + Trivy scan

- `python-cd`
  - Triggered manually (`workflow_dispatch`)
  - Stages:
    - build/push `python-service` image to GHCR
    - deploy to Kubernetes (`apps-dev` for `preview`, `apps-prod` for `promote`)
    - rollout + health verification

## Visual Flow
```mermaid
flowchart TD
  A[Commit / PR / Manual Trigger] --> B{Path Filter Match}
  B -->|platform/idp/paved-roads/scripts/workflows| P[platform-ci]
  B -->|examples/dotnet-service or templates/service-dotnet| D[dotnet-example-ci]
  B -->|examples/python-service or templates/service-python| PY[python-example-ci]
  B -->|examples/node-service or templates/service-node| N[node-example-ci]
  B -->|examples/web-angular| W[web-angular-ci]
  B -->|idp/**| I[idp-ci]
  B -->|manual cd trigger| CD[python-cd]

  P --> P1[actionlint + gitleaks + hygiene + hadolint]
  D --> D1[lint/test + dep scan + docker + trivy]
  PY --> PY1[lint/test + dep scan + docker + trivy]
  N --> N1[lint/test + dep scan + docker + trivy]
  W --> W1[test/build + dep scan + docker + trivy]
  I --> I1[lint/test/tsc + dep scan + docker + trivy]
  CD --> CD1[build/push + deploy + rollout/health]
```
