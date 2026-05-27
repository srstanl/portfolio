# Local Infra Bootstrap

## Purpose
Stand up a local Kubernetes baseline for platform/CD work using `k3d`.

## Prerequisites
- Docker Desktop (running)
- `k3d`
- `kubectl`
- `helm`

## Cluster Defaults
- Cluster name: `devex-local`
- Node shape: 1 server + 2 agents
- Exposed ports:
  - `8080 -> 80` (ingress HTTP)
  - `8443 -> 443` (ingress HTTPS)

## Bring Cluster Up
From repo root:

```bash
make infra-local-up
```

What this does:
- creates cluster `devex-local` if missing
- ensures namespaces exist:
  - `platform-system`
  - `apps-dev`
  - `apps-staging`
  - `apps-prod`
  - `observability`
  - `idp`

## Tear Cluster Down
From repo root:

```bash
make infra-local-down
```

## Observability Bootstrap
Installs:
- `kube-prometheus-stack` (Prometheus + Grafana)
- `opentelemetry-collector` (deployment mode)

Bring observability up:

```bash
make infra-observability-up
```

Check status:

```bash
make infra-observability-status
```

Tear observability down:

```bash
make infra-observability-down
```

Grafana local access:

```bash
kubectl -n observability port-forward svc/kube-prometheus-stack-grafana 3000:80
kubectl -n observability get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode; echo
```

Then browse `http://localhost:3000` (user: `admin`).

## Notes
- Override cluster name with env var:
  - `CLUSTER_NAME=my-cluster make infra-local-up`
- Override k3s image when needed:
  - `K3S_IMAGE=rancher/k3s:v1.31.5-k3s1 make infra-local-up`
