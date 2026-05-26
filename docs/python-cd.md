# Python CD Lane

## Purpose
First deployment lane for `examples/python-service`:
- build and push image to GHCR
- deploy to Kubernetes
- verify rollout and health

Workflow: `.github/workflows/python-cd.yml`

## Trigger
- Manual only (`workflow_dispatch`)
- Input `target_environment`:
  - `preview` -> deploys to namespace `apps-dev`
  - `promote` -> deploys to namespace `apps-prod`

## Required GitHub Setup
Create two repository environments:
- `python-preview`
- `python-promote`

Add secret to each environment:
- `KUBECONFIG_B64`

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
