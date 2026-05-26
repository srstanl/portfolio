# Project Context

## Overview
Platform engineering portfolio focused on Developer Experience (DevEx) and Internal Developer Platform patterns.

## Current Status
- Legacy monorepo was archived on April 21, 2026.
- Platform-first repository structure is active and in use.
- Example services are implemented for:
  - `examples/dotnet-service` (.NET 10, Swagger, tests, Docker)
  - `examples/python-service` (FastAPI, OpenAPI, tests, Docker)
  - `examples/node-service` (Fastify, OpenAPI, tests, Docker)
  - `examples/web-angular` (Angular UI, Jest unit tests, Docker)
- Service templates include runnable scaffolds in:
  - `templates/service-dotnet/scaffold`
  - `templates/service-python/scaffold`
  - `templates/service-node/scaffold`
- Template generation flow exists via:
  - `scripts/new-service.py`
  - `make scaffold-service TEMPLATE=<template> NAME=<service-name>`
- IDP artifacts were added under `idp/catalog` (Backstage-style catalog entities).
- CI/CD workflows are in place with path filtering, manual dispatch, pinned action SHAs, and concurrency cancellation.

## CI/Security Posture
- Shared platform checks (`platform-ci`):
  - structure validation
  - workflow lint (`actionlint`)
  - secrets scan (`gitleaks`)
  - repo hygiene checks
  - Dockerfile lint (hadolint)
- Service workflows (`dotnet/python/node/web-angular`) include:
  - lint/build/test
  - dependency vulnerability scans
  - Dockerfile lint
  - container build
  - Trivy image scanning (critical threshold)
- Temporary policy (May 26, 2026): `idp-ci` dependency audit is non-blocking due to transitive Backstage advisories (`tar` via `node-gyp`); revisit and re-enable blocking after deployment lane validation is complete.

## Backstage Status
- Local Backstage app scaffold exists at `idp/backstage-portal/`.
- Local catalog loading is configured from `idp/catalog/catalog-info.yaml`.
- Remote GitHub URL catalog location is also configured (requires token/private access).
- A Backstage Dockerfile exists at `idp/backstage-portal/Dockerfile`.
- Repo boundary decision (May 26, 2026): `idp/backstage-portal/` remains in this repository as a platform-owned React UI module. It is not treated as a standalone product boundary.

## In-Progress / Not Yet Merged
- Angular E2E smoke setup with Playwright is in progress:
  - `examples/web-angular/e2e/smoke.spec.ts`
  - `examples/web-angular/playwright.config.ts`
  - `web-angular-ci` updated to run Playwright browser install + smoke test
- `idp/backstage-portal/` is currently untracked in git (if intended, add selectively).
- GitHub Project v1 execution-board runbook added at:
  - `docs/github-project-v1.md`
- GitHub Project execution board is now live and seeded:
  - project: `Portfolio Execution Board`
  - issue-backed tasks created (`#3`-`#11`) for PR-linkable execution tracking
  - `First CD implementation` is the current active epic (`#12`)

## Immediate Next Milestones
1. Execute CD tasks under epic `#12`:
   - `#7` define provider-agnostic deployment contract
   - `#8` implement preview + manual promote lane for python-service
2. Clean and commit any remaining in-flight changes:
   - `web-angular` Playwright updates
   - optional inclusion of `idp/backstage-portal/` artifacts
3. Optionally convert IDP template components into full Backstage `Template` entities with parameters/steps.

## Session Conventions
- Keyword: `save state`
- Meaning: current task reached a stopping point; prepare hand-off and shift focus.
- `save state` checklist:
  1. Update `PROJECT_CONTEXT.md` (state, decisions, next action).
  2. Update impacted README/docs for accuracy.
  3. Run quick validation for touched areas when feasible.
  4. Summarize git status and propose commit message.
  5. Pause for commit/push decision.

- Keyword: `downtime`
- Meaning: session is ending.
- `downtime` checklist:
  1. Update `PROJECT_CONTEXT.md` (state, decisions, next actions).
  2. Update impacted README/docs for accuracy.
  3. Summarize git status as:
     - ready to commit now
     - park for later
  4. Call out any known CI blockers or unresolved risks.
