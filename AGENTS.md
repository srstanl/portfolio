# Portfolio Repo Agent Guide

## Purpose
This file contains stable, repo-specific guidance for coding agents working in `Portfolio/portfolio`.

## Start Here
- Read `PROJECT_CONTEXT.md` first for current state, recent decisions, and the next likely work item.
- Check the active GitHub Project board, `Portfolio Execution Board`, before starting implementation work.
- Use `CONTRIBUTING.md` as the source of truth for repo workflow and PR conventions.

## Scope
- This repository represents the DevEx platform portfolio asset.
- Treat `devex_platform` as the named platform boundary.
- Treat future onboarded consumers as separate portfolio assets unless the docs explicitly say otherwise.

## Working Rules
- Prefer issue-backed work. Do not create implementation PRs without a linked issue unless the task is purely administrative.
- Prefer one task issue per PR.
- Include issue-closing keywords in PR descriptions when the work is complete.
- Keep project-board state aligned with the actual execution state of the work.

## Board Expectations
- The active project is `Portfolio Execution Board`.
- `Workflow` is the execution-state source of truth.
- Open implementation PRs should move the linked item to `Review`.
- Items should move to `Done` only after merge or after explicit closure rationale is recorded.
- Risks should remain separate from implementation items unless the repo explicitly folds them into epic exit criteria.

## Documentation Expectations
- Update `PROJECT_CONTEXT.md` when the current status, next milestone, or operating assumptions change.
- Update docs when architectural, delivery, or platform-boundary decisions change.
- Keep `README.md`, `docs/`, and `PROJECT_CONTEXT.md` aligned when a decision affects repo narrative.

## Validation Expectations
- For docs-only changes, a clean diff and accurate board/issue linkage are usually sufficient.
- For implementation changes, run the smallest relevant validation first, then widen only as needed.
- Do not broaden scope by fixing unrelated issues during validation.

## Current Workflow Themes
- Preserve a platform-first portfolio narrative.
- Keep local emulation decisions separate from real-cloud proof points.
- Treat Azure as the current real-cloud target unless repo docs say otherwise.
- Prefer thin local bootstrap paths over sprawling service-specific local infrastructure.
