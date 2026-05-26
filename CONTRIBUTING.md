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
- Add the PR to the project board and set `Workflow Status=Review` while open.

## Project Field Defaults
- `Priority=P1` unless explicitly elevated or deprioritized.
- `Workflow Status=Inbox` for new items.
- `Target=Next` for new items unless actively scheduled.

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
- `save state`: task stopping point and focus-change handoff.
  - Update `PROJECT_CONTEXT.md` with latest status/next step.
  - Update relevant docs/readmes.
  - Run quick checks for touched areas when feasible.
  - Provide git status summary and proposed commit message.
  - Pause for commit/push decision.
- `downtime`: full session end handoff.
  - Update context/docs.
  - Summarize what is ready to commit vs parked.
  - Note known blockers/risks.
