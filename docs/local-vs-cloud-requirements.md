# Local vs Cloud Infra Requirements

## Purpose
Define baseline requirements for platform capabilities across local and cloud environments.

This document is the input for paved-roads standards and CD policy decisions.

The local baseline should prefer a single emulator entry point over service-by-service bootstrap. Current direction is to use `floci` for local cloud emulation where it covers the needed workflow, while keeping real cloud integration as a separate concern.

## Scope
- Runtime platform behavior (Kubernetes + service delivery)
- Security and promotion controls
- Observability baseline
- Operational requirements and ownership boundaries

## Position
- Local emulation should be `floci`-first rather than assembling separate AWS/GCP emulator containers by default.
- Real cloud validation remains required for delivery, identity, observability, secrets, promotion, and governance concerns.
- Azure is the current real-cloud target for this portfolio; local emulator choice does not replace Azure integration work.
- Add bespoke local components only when `floci` cannot support a required workflow or contract test.

## Requirements Matrix

| Capability | Local Requirement | Cloud Requirement | Notes |
|---|---|---|---|
| Cluster runtime | `k3d` single cluster on developer machine | Managed Kubernetes (AKS target) | Namespace parity (`apps-dev`, `apps-staging`, `apps-prod`) |
| Ingress | Local ingress reachable via localhost/localtest domain | Managed ingress with DNS + TLS | Same route structure where possible |
| Container registry | GHCR push/pull | GHCR or ACR (decision pending) | Keep image tagging contract stable |
| CD trigger model | Manual dispatch from `main` | Manual + policy-gated promotion | Preserve explicit promotion evidence |
| Promotion stages | `dev -> staging -> prod` namespaces | `dev -> staging -> prod` environments/namespaces | Stage names remain consistent |
| Deployment auth | Local kubeconfig on self-hosted runner for `dev` | Environment secret-based kubeconfig or workload identity | Remove long-lived secrets when cloud identity is in place |
| Verification gates | Rollout + health + dev integration endpoint checks | Rollout + health + integration + staged verification checklist | Cloud should add stronger gate depth |
| CI security gates | Lint/test/dependency scan/container scan | Same plus branch protection + approvals | Advisory vs blocking policy must be explicit |
| Observability | OTEL Collector + Prometheus + Grafana local stack | OTEL-first with managed/hosted backend options | Keep telemetry schema and naming stable |
| Secrets management | GitHub environment secrets (minimal set) | Vault/Key Vault-backed secret management target | Transition plan required before prod hardening |
| Policy enforcement | Workflow guards + environment protection | RBAC + environment approvals + branch protections | Simulate org role separation via env gates |
| Data/state dependencies | `floci` as the default local emulator for cloud-style dependencies; add one-off local components only for uncovered cases | Managed equivalents with service-level requirements | Prefer one emulator boundary over many local plugin containers |
| Runner strategy | Self-hosted runner for local dev deploy path | GitHub-hosted or hardened self-hosted pool for higher envs | Public-repo self-hosted restrictions documented |
| Drift/traceability | Commit SHA image tags + workflow evidence | Same plus release metadata and audit trail | Link workflow runs to issues/project items |

## Local Baseline
- Use `floci` as the default local cloud-emulation layer when service behavior needs to look cloud-like during development or contract testing.
- Keep the local stack intentionally thin: Kubernetes, ingress, observability, and one emulator boundary are preferred over many service-specific local images.
- Avoid adding AWS- or GCP-specific local bootstrap components unless `floci` cannot cover the required scenario.
- Treat local emulation as a developer experience and fast-feedback tool, not as proof of production readiness.

## Cloud-Required Capabilities
- Identity and access boundaries must be validated against the real cloud target.
- Promotion, approvals, audit trail, and environment governance must exist in the real delivery path.
- Secrets, networking, and observability integrations must be proven against managed or hosted services.
- Production claims should be based on Azure-backed delivery behavior, not on local emulator parity.

## Non-Goals (Current Phase)
- Full production hardening for cloud identity and network controls
- Multi-region deployment strategy
- Cost optimization and autoscaling policy tuning

## Acceptance Criteria for This Requirement Set
- Stage naming and namespace/environment mapping are consistent across local and cloud.
- CD lane requirements are documented and testable for `python-service`.
- Observability baseline is defined and runnable locally.
- Security gate intent is explicit (`blocking` vs `advisory`).

## Next Derivative Work
1. Translate this matrix into paved-roads deployment standards.
2. Create equivalent `node-cd` and `.NET-cd` wrappers using reusable workflow.
3. Define cloud-target deltas (AKS identity, Key Vault/secrets, ingress TLS, policy/RBAC).
4. Add a small `floci` usage note or runbook once the exact local workflows to support are agreed.
