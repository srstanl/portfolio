# Paved Roads

Reusable delivery, policy, and telemetry standards.

## Current Toolchain

- **Build and desired state:** GitOps. Committed repository state is the auditable source of truth, and builds produce immutable artifacts.
- **Release:** Argo CD reconciles declared desired state to the Kubernetes runtime. Release mechanics should stay declarative rather than rely on imperative cluster mutation.
- **Local AKS and Azure emulation:** `floci` provides the default local Kubernetes runtime and Azure-emulation boundary for the paved road.
- **Observability:** services must emit OTEL-compatible telemetry. Backend selection, dashboards, and collector topology are deferred until an observability requirement is in scope.

These are platform contracts, not a requirement to introduce every component into each example service immediately.

## Adoption Notes
- `docs/problem-recommender-platform-adoption.md` outlines how `playground/problem_recommender` can be turned into the first realistic platform canary.
