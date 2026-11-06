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

## Reconciled Baseline (November 6, 2026)
- Remote `main` was fetched and the local checkout fast-forwarded to `4d7879b` (September 16, 2026, PR `#38`), seven commits beyond the previous local checkout.
- See `docs/reconciliation-2026-11-06.md` for issue/PR evidence, historical CI results, and remaining verification gaps.
- This reconciliation updates documentation only; the local runtime was not started or revalidated.

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
- CI workflows use path filtering, manual dispatch, SHA-pinned actions, and concurrency cancellation. The historical reusable CD workflow still contains version-tagged actions and preserves running deployments rather than cancelling them.
- Paved-road toolchain decision: GitOps for build and desired-state change, Argo CD for release reconciliation, and `floci` for the local AKS/Kubernetes runtime and Azure emulation. Observability is deferred except for the requirement that telemetry stays OTEL-compatible.

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
- The Backstage app scaffold is tracked in Git and exists at `idp/backstage-portal/`.
- Local catalog loading is configured from `idp/catalog/catalog-info.yaml`.
- Remote GitHub URL catalog location is also configured (requires token/private access).
- A Backstage Dockerfile exists at `idp/backstage-portal/Dockerfile`.
- Repo boundary decision (May 26, 2026): `idp/backstage-portal/` remains in this repository as a platform-owned React UI module. It is not treated as a standalone product boundary.

## Delivery-Proof Status
- The GitHub Project execution-board runbook is available at:
  - `docs/github-project-v1.md`
- The GitHub Project execution board is live; the first-CD epic (`#12`) is complete.
- The local Floci AKS runtime lifecycle is merged:
  - `make floci-aks-up`
  - `make floci-aks-down`
- The local Argo CD controller lifecycle is merged:
  - `make argocd-up`
  - `make argocd-down`
- The Python reference proof (`#32`) is complete: it demonstrated a local artifact build, Git desired state, Argo reconciliation, and blocking health verification on Floci AKS.
- The .NET reference proof (`#35`) is complete through the same shared local delivery path.
- Registry-backed local promotion merged in PR `#40` on November 6, 2026 (`d1137e1`), completing task `#39`. It replaces direct node image import with Floci ACR push/pull, without claiming real Azure authorization evidence.
- The platform asset remains a logical boundary; `docs/platform-asset-charter.md` defines the current producer, reference-adopter, consumer, and governance boundaries without a code move.
- Consumer-project onboarding remains deferred. `problem_recommender` is tracked separately in epic `#22`.

## Historical / Deferred Notes
- Angular Playwright smoke files and the CI browser-install/test steps are committed. Tasks `#3` and `#4` are closed; the latest recorded Angular main-branch run succeeded on May 22, 2026. Current dependency/runtime health was not revalidated.
- Backstage is committed and remains a platform-owned UI module; task `#5` is closed. Its dependency audit remains advisory.
- Earlier manual CD wrappers and preview/promote lanes remain available, but the current reference delivery path uses Git desired state and Argo CD.
- Legacy `k3d` and observability bootstrap scripts remain available. They are not the current Floci proof path; observability backend work is deferred.

## Open Tracking / Next Action
- `#39` / PR `#40`: registry-backed local promotion is merged and is the current ACR baseline.
- `#22`: consumer onboarding epic remains open and deferred; `#21` is the later structural migration task, contingent on a ready consumer.
- `#11`: provider-drift risk remains open. Its issue body still lacks a mitigation owner, target date, and concrete plan; it must be triaged before execution.
- Project access was restored with the `project` scope. The `Portfolio Execution Board` was reconciled on November 6, initially covering 25 items; cleanup PR `#41` and registry-promotion PR `#40` have since merged. Completed task `#24` is included, and deferred work remains Inbox/Later.
- PR `#40` passed its platform checks and the exact-head remote Python/.NET proof at `83e5784` (private run `42272459936`) before merge. The reference proof gates on exact Git revision, new pod UIDs, and pushed image digest in the runtime image record.
- Current task `#42` / PR `#43`: make the office Mac mini the remote execution host for Actions and Floci Azure infrastructure. Remote execution is verified; the dispatch/runbook PR is in review against `main`. See `docs/home-compute.md`.
- A private `portfolio-home-control` repository owns native macOS (`portfolio-home`) and Docker-based Linux (`portfolio-home-linux`) runners on the Mini. Runner binaries, workspaces, logs, caches, temporary files, and its kubeconfig are on external storage. SSH-based on-demand startup is the current lifecycle; a login-service attempt was blocked by macOS removable-volume privacy and was removed.
- Laptop Docker and host power settings remain unchanged. Energy measurement, persistent awake policy, emulator metadata persistence, unattended reboot recovery, and real Azure deployment are deferred.

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
