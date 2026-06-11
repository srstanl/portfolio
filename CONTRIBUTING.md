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
