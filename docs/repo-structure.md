# Repo Structure

## Principles
1. Keep platform assets separate from product examples.
2. Keep templates versioned and testable.
3. Keep CI path-scoped to reduce blast radius.

## Top-level directories
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
