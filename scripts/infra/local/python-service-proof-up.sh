#!/usr/bin/env bash
set -euo pipefail

# Builds the Git-pinned Python service artifact locally, imports it into the
# Floci-backed k3s node, then lets Argo CD reconcile the Git-tracked overlay.
FLOCI_AKS_KUBECONFIG="${FLOCI_AKS_KUBECONFIG:-.local/floci/portfolio-aks.kubeconfig}"
PYTHON_SERVICE_OVERLAY="${PYTHON_SERVICE_OVERLAY:-platform/cd/python-service/overlays/floci}"
ARGOCD_APPLICATION_MANIFEST="${ARGOCD_APPLICATION_MANIFEST:-platform/argocd/applications/python-service.yaml}"
PYTHON_SERVICE_NAMESPACE="${PYTHON_SERVICE_NAMESPACE:-apps-dev}"
PYTHON_SERVICE_TIMEOUT="${PYTHON_SERVICE_TIMEOUT:-5m}"
PYTHON_SERVICE_TIMEOUT_SECONDS="${PYTHON_SERVICE_TIMEOUT_SECONDS:-300}"

for command in docker git kubectl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "missing required command: ${command}" >&2
    exit 1
  fi
done

if [[ ! -f "${FLOCI_AKS_KUBECONFIG}" ]]; then
  echo "Floci AKS kubeconfig not found: ${FLOCI_AKS_KUBECONFIG}" >&2
  echo "Run 'make floci-aks-up' first." >&2
  exit 1
fi

if ! git diff --quiet -- examples/python-service; then
  echo "examples/python-service has uncommitted changes." >&2
  echo "Commit the service source before creating a deterministic proof artifact." >&2
  exit 1
fi

source_tree_id="$(git rev-parse HEAD:examples/python-service)"
rendered_image="$(kubectl kustomize "${PYTHON_SERVICE_OVERLAY}" \
  | awk '/image: / { print $NF; exit }')"
expected_image="python-service:${source_tree_id}"

if [[ "${rendered_image}" != "${expected_image}" ]]; then
  echo "Floci overlay image must be ${expected_image}; found ${rendered_image:-none}." >&2
  echo "Update the Git-tracked image tag after changing examples/python-service." >&2
  exit 1
fi

if ! kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes >/dev/null; then
  echo "Floci AKS is not reachable. Run 'make floci-aks-up' first." >&2
  exit 1
fi

k3s_container="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes -o jsonpath='{.items[0].metadata.name}')"
if ! docker inspect "${k3s_container}" --format '{{.State.Running}}' 2>/dev/null | grep -qx 'true'; then
  echo "Kubernetes node container '${k3s_container}' is unavailable." >&2
  exit 1
fi

echo "building ${expected_image} from examples/python-service"
docker build --tag "${expected_image}" examples/python-service

echo "importing ${expected_image} into Floci k3s node ${k3s_container}"
docker save "${expected_image}" \
  | docker exec -i "${k3s_container}" ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images import -

echo "applying Git-tracked Argo CD Application"
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" apply -f "${ARGOCD_APPLICATION_MANIFEST}"

echo "waiting for Argo CD to reconcile the Git-tracked overlay"
deadline=$((SECONDS + PYTHON_SERVICE_TIMEOUT_SECONDS))
while true; do
  sync_status="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n argocd get application python-service -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  if [[ "${sync_status}" == "Synced" ]]; then
    break
  fi
  if (( SECONDS >= deadline )); then
    echo "Argo CD did not reach Synced within ${PYTHON_SERVICE_TIMEOUT}." >&2
    kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n argocd get application python-service -o yaml >&2 || true
    exit 1
  fi
  sleep 3
done

echo "verifying Kubernetes rollout"
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${PYTHON_SERVICE_NAMESPACE}" rollout status deployment/python-service --timeout "${PYTHON_SERVICE_TIMEOUT}"

echo "verifying blocking health endpoint"
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${PYTHON_SERVICE_NAMESPACE}" run python-service-health \
  --rm -i --restart=Never --image=curlimages/curl:8.8.0 \
  -- curl -fsS http://python-service:8080/health

echo
echo "Python service delivery proof complete."
echo "artifact: ${expected_image}"
echo "source tree: ${source_tree_id}"
echo "Argo Application: python-service (Synced)"
echo "target: ${PYTHON_SERVICE_NAMESPACE}/deployment/python-service"
