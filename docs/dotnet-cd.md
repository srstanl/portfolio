# .NET CD Lane

## Purpose
Deployment lane for `examples/dotnet-service`:
- build and push image to GHCR
- deploy to Kubernetes
- verify rollout and health

This workflow is a concrete implementation of the provider-agnostic deployment contract:
- contract: `docs/deployment-contract.md`

Workflow: `.github/workflows/dotnet-cd.yml`
Reusable CD skeleton: `.github/workflows/reusable-service-cd.yml`

## Trigger
- Manual only (`workflow_dispatch`)
- Input `deployment_mode`:
  - `preview` -> build from the current `main` commit and deploy to `dev` or `staging`
  - `promote` -> deploy an existing image ref to `staging` or `prod` without rebuilding
- Input `target_environment`:
  - `dev` -> deploys to namespace `apps-dev` (self-hosted local runner)
  - `staging` -> deploys to namespace `apps-staging`
  - `prod` -> deploys to namespace `apps-prod`
- Input `artifact_image_ref`:
  - required for `promote`
  - ignored for `preview`

## Exact Values Reference
- Workflow event: `workflow_dispatch`
- `target_environment` options: `dev`, `staging`, `prod`
- `deployment_mode` options: `preview`, `promote`
- `provider`: `kubernetes`
- Environment names: `dotnet-dev`, `dotnet-staging`, `dotnet-prod`
- Required environment secret: `KUBECONFIG_B64`

## Required GitHub Setup
Create three repository environments:
- `dotnet-dev`
- `dotnet-staging`
- `dotnet-prod`

Add secret to `dotnet-staging` and `dotnet-prod`:
- `KUBECONFIG_B64`

`dotnet-dev` uses local kubeconfig on the self-hosted runner (`k3d-local`) and does not require this secret.

## Deployment Manifests
Path: `platform/cd/dotnet-service/base`
- `deployment.yaml`
- `service.yaml`
- `ingress.yaml`
- `kustomization.yaml`

## Verification
Workflow enforces:
- deployment rollout status
- in-cluster `/health` check via ephemeral curl pod
- dev-only integration gate via `/swagger/v1/swagger.json` check

## Preview and Promote Flow
1. Run `dotnet-cd` with:
   - `deployment_mode=preview`
   - `target_environment=dev` or `staging`
2. Capture the deployed artifact reference from the workflow summary.
3. Run `dotnet-cd` again with:
   - `deployment_mode=promote`
   - `target_environment=staging` or `prod`
   - `artifact_image_ref=<captured image ref>`

Promotion reuses the existing artifact and does not rebuild from source.
