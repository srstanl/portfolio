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

The command is safe to rerun. It starts Floci AZ if needed, creates or reuses `portfolio-aks`, detects and recreates a stale AKS resource whose k3s child container disappeared after an emulator restart, waits for the real k3s API and a Ready node, writes the host-reachable kubeconfig to `.local/floci/portfolio-aks.kubeconfig`, validates `kubectl` access, and creates the base application namespaces.

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

## Argo CD Bootstrap

After the Floci AKS bootstrap has written `.local/floci/portfolio-aks.kubeconfig`, install the local release controller:

```bash
make argocd-up
```

The script installs the pinned `argo/argo-cd` Helm chart into the dedicated `argocd` namespace and waits for its deployments and statefulsets to become Ready. It does not create an Argo CD `Application` or deploy a workload.

Access the local UI:

```bash
kubectl --kubeconfig "$PWD/.local/floci/portfolio-aks.kubeconfig" \
  -n argocd port-forward svc/argocd-server 8080:443
```

Retrieve the initial admin password:

```bash
kubectl --kubeconfig "$PWD/.local/floci/portfolio-aks.kubeconfig" \
  -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 --decode; echo
```

Remove the controller when it is no longer needed:

```bash
make argocd-down
```

This removes the Helm release and `argocd` namespace but leaves the Floci AKS runtime and cluster-level Argo CD CRDs intact.

## Python Service GitOps Proof

After the Floci AKS runtime and Argo CD controller are available, prove the full local delivery path for `examples/python-service`:

```bash
make floci-aks-up
make argocd-up
make python-service-proof-up
```

The proof builds `examples/python-service` on the workstation, tags it with the committed Git tree ID for that service, and imports that exact image into the Floci-backed k3s node. The Git-tracked Floci overlay pins the same image reference with `imagePullPolicy: Never`; the Git-tracked Argo CD `Application` then reconciles that overlay into `apps-dev`.

The command blocks until Argo CD reports `Synced`, the Kubernetes deployment finishes rolling out, and an in-cluster request to `http://python-service:8080/health` succeeds. Its final output records the artifact reference, source tree ID, Argo result, and deployment target. The rollout and health gates are authoritative for this proof because the local Traefik Ingress does not publish a load-balancer status for Argo CD to mark healthy.

If the Python service source changes, commit it and update the image tag in `platform/cd/python-service/overlays/floci/kustomization.yaml` to the new value from:

```bash
git rev-parse HEAD:examples/python-service
```

The `Application` deliberately targets `main`, so run the proof from a merged `main` checkout. This keeps the reconciled desired state auditable on the repository's default branch.

## .NET Service GitOps Proof

The .NET reference service uses the same shared local proof mechanism. After the Floci AKS runtime and Argo CD controller are available, run:

```bash
make floci-aks-up
make argocd-up
make dotnet-service-proof-up
```

The .NET Floci overlay pins `examples/dotnet-service` to its committed Git tree ID and the Argo CD `dotnet-service` Application reconciles it to `apps-dev`. The proof blocks on Argo synchronization, the Kubernetes rollout, and an in-cluster `/health` response, then prints the artifact, source tree, target, and release evidence.

## Notes
- Override cluster name with env var:
  - `CLUSTER_NAME=my-cluster make infra-local-up`
- Override k3s image when needed:
  - `K3S_IMAGE=rancher/k3s:v1.31.5-k3s1 make infra-local-up`
