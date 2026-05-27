# Python CD Lane

## Purpose
First deployment lane for `examples/python-service`:
- build and push image to GHCR
- deploy to Kubernetes
- verify rollout and health

Workflow: `.github/workflows/python-cd.yml`
Reusable CD skeleton: `.github/workflows/reusable-service-cd.yml`

## Trigger
- Manual only (`workflow_dispatch`)
- Input `target_environment`:
  - `dev` -> deploys to namespace `apps-dev` (self-hosted local runner)
  - `staging` -> deploys to namespace `apps-staging`
  - `prod` -> deploys to namespace `apps-prod`

## Exact Values Reference
- Workflow event: `workflow_dispatch`
- `target_environment` options: `dev`, `staging`, `prod`
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

## Reuse Pattern
`python-cd` is now a thin wrapper that calls the reusable workflow and passes service-specific inputs:
- image name + build context
- kustomize path + deployment name
- environment/namespace mapping
- health and integration endpoints

Use this pattern to add `node-cd` and `dotnet-cd` without duplicating core CD logic.
