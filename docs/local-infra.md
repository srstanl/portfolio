# Local Infra Bootstrap

## Purpose
> **Status:** this `k3d` bootstrap is a legacy local-development path. The paved-road delivery target is a Floci-provisioned local AKS/Kubernetes runtime; do not extend this path for the current computer-to-Kubernetes proof. It remains documented only until the Floci bootstrap replaces it.

Stand up a legacy local Kubernetes baseline for platform/CD work using `k3d`.

## Floci AKS Bootstrap (Paved-Road Path)

The current paved-road path uses Floci AZ to provision an AKS-compatible resource backed by a real local `k3s` container. The bootstrap script handles the otherwise easy-to-miss host-access handoff: Floci returns a kubeconfig with a Docker-internal API hostname, and the script replaces it with the corresponding host-published `localhost` endpoint before validating access. If the current Floci-generated bearer token is rejected by the live k3s API, the script automatically uses the live cluster's client-certificate admin kubeconfig instead.

Prerequisites:

- Docker Desktop (running)
- Floci CLI with the Azure emulator available
- `kubectl`
- `curl`
- `python3`

From the repository root:

```bash
make floci-aks-up
```

The command is safe to rerun. It starts Floci AZ if needed, creates or reuses `portfolio-aks`, writes the host-reachable kubeconfig to `.local/floci/portfolio-aks.kubeconfig`, validates `kubectl` access, and creates the base application namespaces.

Use the generated context in the current shell:

```bash
export KUBECONFIG="$PWD/.local/floci/portfolio-aks.kubeconfig"
kubectl get nodes
```

Override defaults when needed:

```bash
FLOCI_AKS_CLUSTER=my-aks FLOCI_AKS_KUBECONFIG=.local/floci/my-aks.kubeconfig make floci-aks-up
```

Tear down the named AKS resource when finished:

```bash
make floci-aks-down
```

This deletes `portfolio-aks` and its generated kubeconfig, but deliberately leaves the shared Floci AZ emulator container running. Use the same `FLOCI_AKS_CLUSTER` and `FLOCI_AKS_KUBECONFIG` overrides when removing a non-default cluster.

## Legacy k3d Prerequisites
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
