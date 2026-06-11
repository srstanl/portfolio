# Project Context

## Overview
Platform engineering portfolio focused on Developer Experience (DevEx) and Internal Developer Platform patterns.

## Default Conventions
- Developer-facing and platform-oriented tools should default to a Python backend and React frontend.
- Other application experiences should default to a .NET backend and Angular frontend.
- Exceptions are allowed when a project has a documented reason to diverge.

## Portfolio Boundary Direction
- `devex_platform` is the named platform asset in this repository; the platform should not remain the implicit identity of the entire portfolio forever.
- Future onboarding consumers should appear as separate portfolio assets once they are mature enough to belong here.
- See `docs/portfolio-asset-boundary-plan.md` for the staged structure plan; no repo-wide code move is implied yet.

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
- CD contract and wrapper expansion are implemented locally and not yet merged:
  - `#7` provider-agnostic deployment contract drafted in `docs/deployment-contract.md`
  - `#8` preview/promote lane implemented for `python-service`
  - matching wrapper pattern extended to `node-service` and `dotnet-service`

## Immediate Next Milestones
1. Execute CD tasks under epic `#12`:
   - `#7` and `#8` are implemented locally; next step is PR/board closure
   - decide whether to keep `node-cd` and `dotnet-cd` in the same PR or split follow-on work
2. Finalize local vs cloud infra requirements baseline:
   - `docs/local-vs-cloud-requirements.md` (drives paved-roads standards)
3. Clean and commit current in-flight changes:
   - CD contract, reusable workflow refactor, and service CD wrappers
   - `web-angular` Playwright updates
   - optional inclusion of `idp/backstage-portal/` artifacts
4. Optionally convert IDP template components into full Backstage `Template` entities with parameters/steps.

## Session Conventions
- Keyword: `start session`
- Meaning: begin a new work session by recapping the previous session and checking the board for the next task.
- `start session` checklist:
  1. Review `PROJECT_CONTEXT.md` for current status, decisions, and immediate next milestones.
  2. Check the active board/epic and confirm the next `Ready` or planned task.
  3. Summarize repo state (clean vs in-flight changes).
  4. Propose the next concrete work item before making edits.

- Keyword: `save state`
- Meaning: current task reached a stopping point and work should be stored durably in remote history without waiting for follow-up prompts.
- `save state` checklist:
  1. Update `PROJECT_CONTEXT.md` (state, decisions, next action).
  2. Update impacted README/docs for accuracy.
  3. Run quick validation for touched areas when feasible.
  4. Summarize the changes and current git status.
  5. Check the current branch name; if it is `main`, create and switch to a new branch before committing.
  6. Commit the current work with a clear message.
  7. Push the current branch to remote.
  8. Call out any known validation gaps, CI blockers, or follow-up risks.

- Keyword: `end session`
- Meaning: session is ending.
- `end session` checklist:
  1. Update `PROJECT_CONTEXT.md` (state, decisions, next actions).
  2. Update impacted README/docs for accuracy.
  3. Run quick validation for touched areas when feasible.
  4. Update the active board/task state if progress changed during the session.
  5. Summarize the session changes and current repo state.
  6. If the work does not already have a tracking issue, create one before opening or updating the PR.
  7. Link the PR to the issue explicitly:
     - use `Closes #...` if the issue should remain open until merge
     - use `Refs #...` if the issue is being closed immediately as tracking-only documentation
  8. Check the current branch name; if it is `main`, create and switch to a new branch before committing.
  9. Commit the current work with a clear message.
  10. Push the current branch to remote.
  11. Call out any known CI blockers, unresolved risks, or next recommended starting point.
