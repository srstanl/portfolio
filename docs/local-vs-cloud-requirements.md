# Local vs Cloud Infra Requirements

## Purpose
Define baseline requirements for platform capabilities across local and cloud environments.

This document is the input for paved-roads standards and CD policy decisions.

## Scope
- Runtime platform behavior (Kubernetes + service delivery)
- Security and promotion controls
- Observability baseline
- Operational requirements and ownership boundaries

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
| Data/state dependencies | Optional local components (cache/messaging/db) as modular scripts | Managed equivalents with service-level requirements | Add as paved-road modules incrementally |
| Runner strategy | Self-hosted runner for local dev deploy path | GitHub-hosted or hardened self-hosted pool for higher envs | Public-repo self-hosted restrictions documented |
| Drift/traceability | Commit SHA image tags + workflow evidence | Same plus release metadata and audit trail | Link workflow runs to issues/project items |

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
3. Define cloud-target deltas (AKS identity, secrets, ingress TLS, policy/RBAC).
