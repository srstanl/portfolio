# Provider-Agnostic Deployment Contract

## Purpose
Define the stable deployment interface that example services and paved-road workflows must satisfy, independent of the underlying runtime provider.

This contract separates:
- delivery semantics that should stay stable across the portfolio
- provider-specific mechanics such as Kubernetes manifests, cloud identity, or runner placement

## Current Driver
The first implementation target is `examples/python-service`, which already has a working CD lane:
- wrapper workflow: `.github/workflows/python-cd.yml`
- reusable workflow: `.github/workflows/reusable-service-cd.yml`

That implementation is currently Kubernetes-oriented. This document defines the abstraction that future workflow refactors should converge on.

## Contract Scope
This contract applies to:
- example services under `examples/`
- service templates under `templates/`
- reusable deployment workflows under `.github/workflows/`
- deployment assets under `platform/cd/`

This contract does not yet define:
- multi-region rollout
- autoscaling policy
- database migrations
- rollback orchestration beyond failed deployment rejection

## Stable Delivery Concepts

### 1. Service Identity
Every deployable service must define:
- `service_name`: stable workload identifier used across workflow, manifests, and evidence
- `build_context`: repository path used to build the artifact
- `deployment_spec_path`: provider-owned deployment definition path

Example:
- `service_name=python-service`
- `build_context=examples/python-service`
- `deployment_spec_path=platform/cd/python-service/base`

### 2. Artifact Identity
Every deployment must promote an immutable artifact, not source code directly.

Required rules:
- artifact is a container image
- image tag includes the commit SHA
- deployment uses the exact built image reference
- `latest` may be published for convenience, but must not be the source of truth for promotion evidence

Required output:
- `image_ref`

Promotion rule:
- a promoted deployment must reuse an existing `image_ref` rather than rebuild from source

### 3. Environment Model
All deployment providers must support the same logical target stages:
- `dev`
- `staging`
- `prod`

Required rules:
- stage names stay stable even if provider details differ
- each stage maps to a GitHub environment for approval/audit controls
- each stage maps to a provider-specific runtime target

The runtime target may be:
- Kubernetes namespace
- cloud environment or slot
- server group
- other provider-native target

### 4. Deployment Intent
Each deployment invocation must declare intent explicitly.

Required fields:
- `target_environment`
- `environment_name`

Current repo state:
- `python-cd` supports stage targeting
- `python-cd` now exposes explicit `preview` and `promote` modes

### 5. Provider Adapter Boundary
Provider-specific logic must live behind an adapter boundary.

The adapter is responsible for:
- authenticating to the runtime
- applying provider-native deployment configuration
- updating the runtime to the target artifact
- waiting for provider-native rollout completion

The adapter must not redefine:
- environment stage names
- artifact tagging rules
- blocking verification expectations
- audit evidence requirements

Examples of provider-specific details that stay behind the adapter:
- Kubernetes namespace names
- kubeconfig or workload identity setup
- `kubectl` vs cloud CLI commands
- ingress or route provisioning details

### 6. Verification Gates
Every deployment must enforce blocking verification gates before success.

Required blocking gates:
- rollout completed successfully
- health endpoint responds successfully

Optional blocking gates:
- integration/smoke endpoint
- post-deploy policy checks
- release annotation or evidence publication

Rules:
- optional gates may vary by stage
- stronger gates in higher environments are allowed
- weaker gates in higher environments are not allowed without an explicit documented exception

### 7. Evidence and Traceability
Every successful or failed deployment must produce enough evidence to answer:
- what service was deployed
- which commit/artifact was deployed
- to which stage/runtime target it was deployed
- whether required gates passed

Minimum evidence fields:
- `service_name`
- `target_environment`
- `environment_name`
- `image_ref`
- workflow run reference
- deployment result

Preferred future evidence fields:
- deployment URL
- provider target identifier
- promotion source artifact
- issue or board item reference

## Required Workflow Interface
The reusable deployment contract should converge on this provider-agnostic input surface:

| Input | Required | Meaning |
|---|---|---|
| `service_name` | yes | Stable service identifier |
| `image_name` | yes | Base image repository/name |
| `build_context` | yes | Directory used for image build |
| `deployment_spec_path` | yes | Provider deployment definition path |
| `target_environment` | yes | Logical stage: `dev`, `staging`, `prod` |
| `environment_name` | yes | GitHub environment name used for gating |
| `health_endpoint` | yes | Blocking health path |
| `integration_endpoint` | no | Additional blocking smoke/integration path |
| `artifact_image_ref` | conditional | Required for `promote`; reused artifact reference |
| `deployment_mode` | yes | `deploy`, `preview`, or `promote` |
| `provider` | yes | Adapter selector such as `kubernetes` |
| `provider_config_json` | yes | Provider-specific configuration payload |

## Current Mapping to Existing Python CD Lane
Current workflow inputs already align partially with the contract:
- aligned:
  - `service_name`
  - `image_name`
  - `build_context`
  - `deployment_spec_path`
  - `target_environment`
  - `environment_name`
  - `health_endpoint`
  - `integration_endpoint`
  - `artifact_image_ref`
  - `deployment_mode`
  - `provider`
  - `provider_config_json`
- Kubernetes-specific and candidates to move behind the adapter:
  - `namespace`
  - `deployment_name`
  - runner selection based on environment
  - `KUBECONFIG_B64`

## Rules for Example Services and Templates
Each deployable service should provide:
- a buildable container image
- a health endpoint suitable for blocking verification
- an optional smoke/integration endpoint for lower-environment validation
- deployment assets stored under `platform/cd/<service-name>/`

Each service template should eventually expose placeholders for:
- service name
- container port
- health endpoint
- deployment asset location

## Rules for Promotion Design
Promotion should move a previously built artifact between stages, not rebuild from source.

This implies the contract for task `#8` should support:
- selecting an existing `image_ref`
- preview deployment without production promotion
- manual promotion approval through GitHub environments
- reuse of the same verification model at each stage

## Near-Term Refactor Guidance
To move from the current Kubernetes-oriented implementation toward this contract:

1. Keep `python-cd` as the first reference workflow.
2. Rename generic inputs in the reusable workflow toward contract terms.
3. Collapse Kubernetes-only inputs behind an adapter-specific configuration object or wrapper.
4. Keep `deployment_mode` explicit for preview vs promote.
5. Ensure promotion reuses an existing artifact reference instead of rebuilding.

## Acceptance Criteria for Task `#8`
Task `#8` is complete when:
- `python-cd` supports `preview` and `promote` invocation modes
- `promote` reuses an existing `image_ref` instead of rebuilding
- the same blocking verification model runs after preview and promote deployments
- GitHub environment gating remains the approval boundary for higher environments
