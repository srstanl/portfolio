# Environment-Portable Delivery Requirements

## Purpose
Define one delivery contract that can run against a Floci-provided local AKS/Kubernetes runtime and later against Azure.

Floci collapses most of the former local-versus-cloud distinction: developers and the paved road should exercise the same AKS-shaped runtime, deployment, and Azure-facing contracts locally. This document is the input for paved-roads standards and release policy decisions.

The current paved-road toolchain is:

- GitOps for build and desired-state change
- Argo CD for release and runtime reconciliation
- `floci` for the local AKS/Kubernetes runtime and Azure emulation
- OpenTelemetry (OTEL) as the observability format contract

Observability backend selection and implementation are deliberately deferred. OTEL compatibility is the only current observability requirement.

## Scope
- AKS-shaped runtime platform behavior and service delivery
- Security and promotion controls
- OTEL telemetry contract
- Operational requirements and ownership boundaries

## Position
- Floci is the default local AKS/Kubernetes runtime and Azure-emulation boundary; do not maintain a separate local-platform contract.
- Git is the source of truth for desired state; builds produce immutable artifacts from committed changes.
- Argo CD owns release reconciliation from declared desired state to the Kubernetes runtime.
- Azure remains the later real-cloud target, but it is evidence for managed-service, identity, networking, and governance behavior—not a second delivery design.
- Add bespoke local components only when `floci` cannot support a required workflow or contract test.

## Delivery Contract

| Capability | Required behavior | Later Azure evidence boundary |
|---|---|---|---|
| Cluster runtime | Floci-provisioned AKS/Kubernetes runtime; stable namespaces (`apps-dev`, `apps-staging`, `apps-prod`) | Managed AKS behavior, capacity, and control-plane integration |
| Ingress | Stable route structure | DNS, TLS, and managed-ingress integration |
| Artifact and desired state | GitOps from committed repository state; immutable commit-SHA image references | Registry choice and managed registry access |
| Release reconciliation | Argo CD reconciles declared state; no imperative release drift | Managed-cluster credentials and controller integration |
| Promotion and verification | Stable stages, rollout completion, health, and applicable integration checks | Environment approvals, audit controls, and stronger higher-environment gates |
| Security and policy | Lint, test, dependency scan, container scan, workflow guards, and environment protection | Workload identity, RBAC, branch protection, and organization governance |
| Data and Azure dependencies | Floci is the default emulator boundary; add components only for uncovered contracts | Managed-service configuration and service-level requirements |
| Observability | Emit OTEL-compatible telemetry; backend selection is deferred | Backend, retention, alerting, and managed integration when required |
| Traceability | Commit SHA image tags and workflow evidence | Release metadata and audit-trail integration |

## Evidence Boundary

Floci proves the portable delivery contract. A later Azure proof is required only for behavior that depends on managed Azure services or organizational controls: workload identity, managed networking and TLS, Key Vault integration, RBAC, environment approvals, audit integration, and any chosen observability backend. It must not introduce a separate application or release design.

## Non-Goals (Current Phase)
- Full production hardening for cloud identity and network controls
- Multi-region deployment strategy
- Cost optimization and autoscaling policy tuning

## Acceptance Criteria for This Requirement Set
- `python-service` can prove the GitOps-to-Argo-CD delivery flow on a Floci-provided AKS/Kubernetes runtime.
- Stage naming and namespace/environment mapping stay portable to Azure.
- All application telemetry is OTEL-compatible; no observability backend is selected by this requirement set.
- Security gate intent is explicit (`blocking` vs `advisory`).

## Next Derivative Work
1. Implement the `python-service` GitOps-to-Argo-CD proof on Floci-provisioned local AKS.
2. Define the Argo CD application and promotion conventions for the example services.
3. Define cloud-target deltas (AKS identity, Key Vault/secrets, ingress TLS, policy/RBAC).
4. Add a `floci` local-AKS bootstrap and usage runbook for the reference delivery flow.
5. Select an OTEL-compatible observability backend only when an observability delivery requirement exists.
