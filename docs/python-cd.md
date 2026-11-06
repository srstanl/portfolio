# Python CD Lane

> **Status:** retained manual GitHub Actions deployment lane. The current reference delivery proof uses Floci AKS and Argo CD; see [local infrastructure](local-infra.md). This workflow is separate from the GitOps proof.

## Purpose
First deployment lane for `examples/python-service`:
- build and push image to GHCR
- deploy to Kubernetes
- verify rollout and health

This workflow is the first concrete implementation of the provider-agnostic deployment contract:
- contract: `docs/deployment-contract.md`

Workflow: `.github/workflows/python-cd.yml`
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
  - leave empty to build a preview; the current workflow reuses any supplied reference, including in preview mode

## Exact Values Reference
- Workflow event: `workflow_dispatch`
- `target_environment` options: `dev`, `staging`, `prod`
- `deployment_mode` options: `preview`, `promote`
- `provider`: `kubernetes`
- Environment names: `python-dev`, `python-staging`, `python-prod`
- Required environment secret: `KUBECONFIG_B64`

## Required GitHub Setup
Create three repository environments:
- `python-dev`
- `python-staging`
- `python-prod`

Add secret to `python-staging` and `python-prod`:
- `KUBECONFIG_B64`

`python-dev` uses local kubeconfig on the self-hosted runner (`k3d-local`) and does not require this secret.

Generate secret value from local kubeconfig:

```bash
base64 -i ~/.kube/config | tr -d '\n'
```

Use that output as the environment secret value.

## Deployment Manifests
Path: `platform/cd/python-service/base`
- `deployment.yaml`
- `service.yaml`
- `ingress.yaml`
- `kustomization.yaml`

## Verification
Workflow enforces:
- deployment rollout status
- in-cluster `/health` check via ephemeral curl pod
- dev-only integration gate via `/docs` check

## Preview and Promote Flow
1. Run `python-cd` with:
   - `deployment_mode=preview`
   - `target_environment=dev` or `staging`
2. Capture the deployed artifact reference from the workflow summary.
3. Run `python-cd` again with:
   - `deployment_mode=promote`
   - `target_environment=staging` or `prod`
   - `artifact_image_ref=<captured image ref>`

Promotion reuses the existing artifact and does not rebuild from source.

## Reuse Pattern
`python-cd` is now a thin wrapper that calls the reusable workflow and passes contract-level inputs:
- image name + build context
- deployment spec path
- logical environment mapping
- provider selector + provider configuration payload
- health and integration endpoints

The existing `node-cd` and `dotnet-cd` wrappers use the same reusable workflow.
