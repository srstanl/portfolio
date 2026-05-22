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

## Backstage Status
- Local Backstage app scaffold exists at `backstage-portal/`.
- Local catalog loading is configured from `idp/catalog/catalog-info.yaml`.
- Remote GitHub URL catalog location is also configured (requires token/private access).
- A root-level Backstage Dockerfile was added at `backstage-portal/Dockerfile`.

## In-Progress / Not Yet Merged
- Angular E2E smoke setup with Playwright is in progress:
  - `examples/web-angular/e2e/smoke.spec.ts`
  - `examples/web-angular/playwright.config.ts`
  - `web-angular-ci` updated to run Playwright browser install + smoke test
- `backstage-portal/` is currently untracked in git (if intended, add selectively).

## Immediate Next Milestones
1. Clean and commit current in-flight changes:
   - `web-angular` Playwright updates
   - optional inclusion of `backstage-portal/` artifacts
2. Decide whether `backstage-portal/` belongs in this repo long-term or should be moved to a separate repo.
3. Add deploy workflows (preview and environment promotion) once CI baseline is stable on `main`.
4. Optionally convert IDP template components into full Backstage `Template` entities with parameters/steps.

## Session Convention
- Keyword: `downtime`
- Meaning: switch into maintenance/hand-off mode before stepping away.
- `downtime` checklist:
  1. Update `PROJECT_CONTEXT.md` (state, decisions, next actions).
  2. Update impacted README/docs for accuracy.
  3. Summarize git status as:
     - ready to commit now
     - park for later
  4. Call out any known CI blockers or unresolved risks.
