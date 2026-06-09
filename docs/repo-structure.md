# Repo Structure

## Principles
1. Keep platform assets separate from product examples.
2. Keep templates versioned and testable.
3. Keep CI path-scoped to reduce blast radius.
4. Treat the platform as one portfolio asset, not the entire repository identity.

## Top-level directories
- `devex_platform/` Named boundary for the platform as a portfolio asset.
- `platform/` IaC, runtime platform definitions, and shared services.
- `idp/` Developer portal setup, catalog descriptors, docs ingestion.
- `templates/` Golden path service templates.
- `paved-roads/` Shared delivery standards and tooling.
- `examples/` Sample services built from templates.

## Ownership boundaries
- Platform team owns `platform/`, `idp/`, `paved-roads/`.
- Enablement/platform-experience owns `templates/`.
- Application teams own `examples/` (or real services in future repos).

## CI expectations
- Changes in one boundary should not trigger unrelated pipelines.
- Shared checks can run globally for formatting/security policies.
- Reusable CD logic lives in `.github/workflows/reusable-service-cd.yml`, with per-service wrappers for `python`, `node`, and `.NET`.

## Portfolio-level boundary
- This repository can contain both platform-owned assets and separate portfolio projects.
- `devex_platform/` names the platform asset explicitly, even while platform-owned code still spans multiple top-level directories.
- Platform-owned assets stay under platform-oriented boundaries such as `platform/`, `idp/`, `templates/`, and `paved-roads/`.
- Future portfolio-grade consumers should appear as separate assets rather than being inserted into the platform tree by default.
- See `docs/portfolio-asset-boundary-plan.md` for the staged evolution model.
