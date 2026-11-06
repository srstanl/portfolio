# Contributing

## Purpose
Contribution workflow and delivery rules for this repository.

## Working Model
- Track execution in GitHub Project: `Portfolio Execution Board`.
- Keep one active epic at a time when possible.
- Use issues for executable work items; avoid standalone draft items for implementation work.

## Issue and Epic Conventions
- Epics represent outcomes; tasks represent concrete implementation steps.
- Link tasks to an epic using GitHub sub-issues (`Parent issue`).
- A task is `Ready` only when acceptance criteria are written in the issue body.

## PR Conventions
- Preferred: one task issue per PR.
- Include issue-closing keywords in the PR description:
  - `Closes #<issue-number>` for implemented work.
  - `Refs #<issue-number>` for partial or related work.
- Add the PR to the project board and set `Workflow=Review` while open.

## Project Field Defaults
- `Priority=P1` unless explicitly elevated or deprioritized.
- `Workflow=Inbox` for new items.
- `Target=Next` for new items unless actively scheduled.
- Use `Workflow` as the execution-state source of truth.
- Keep the default GitHub `Status` field aligned as a coarse mirror:
  - `Inbox` or `Ready` -> `Todo`
  - `In Progress`, `Blocked`, or `Review` -> `In Progress`
  - `Done` -> `Done`

## Definition of Done
- Work item is complete only when:
  - Linked PR is merged (or closure rationale is documented), and
  - Project item status is updated to `Done`, and
  - Evidence exists (PR link, commit link, or issue note).

## Risks
- Risk items must include:
  - Mitigation owner
  - Target mitigation date
  - Current mitigation plan

## Documentation Split
- `CONTRIBUTING.md`: process, planning model, issue/PR/project rules.
- `docs/developer-guide.md`: local setup, run/test/build/debug commands.

## Session Signals
- `start session`: resume the portfolio containers suspended at the previous session end, then verify infrastructure health and runner connectivity. Use SSH for startup because stopped runners cannot accept jobs. Keep laptop Docker stopped by default; restore laptop containers only when that session explicitly used them.
- `end session`: after saving work and verifying no jobs are active, stop the session's running portfolio containers and native runner, preserving container identities, images, volumes, and deployment data. Record what to resume before stopping it. Stop dependent workloads/runners before their infrastructure and release any bounded awake window last. Leave unrelated workloads and previously stopped containers alone.
- `save state`: persist work without shutting down infrastructure.
- Session suspend/resume must never call destructive infrastructure `*-down` targets. Until the automation in #44 is verified, use the [lifecycle runbook](docs/home-compute.md#session-lifecycle-policy) and report missing persistence/recovery prerequisites explicitly; do not claim that the awake-session helper performs infrastructure startup/shutdown.
- `save state`: durable handoff when work should be committed and pushed without waiting for more prompts.
  - Update `PROJECT_CONTEXT.md` with latest status/next step.
  - Update relevant docs/readmes.
  - Run quick checks for touched areas when feasible.
  - Summarize the changes and current git status.
  - Check the current branch name; if it is `main`, create and switch to a new branch before committing.
  - Commit the work with a clear message.
  - Push the current branch to remote.
  - Call out validation gaps, CI blockers, and follow-up risks.
- `end session`: full session end handoff.
  - Update context/docs.
  - Run quick checks for touched areas when feasible.
  - Update the active board/task state if progress changed during the session.
  - Summarize the session changes and repo state.
  - Check the current branch name; if it is `main`, create and switch to a new branch before committing.
  - Commit the work with a clear message.
  - Push the current branch to remote.
  - Note known blockers, risks, and the next recommended starting point.
