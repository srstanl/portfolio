#!/usr/bin/env bash
set -euo pipefail

# Builds a Git-pinned service artifact locally, pushes it to Floci ACR, then
# lets Argo CD reconcile the Git-tracked overlay and k3s pull the image.
FLOCI_AKS_KUBECONFIG="${FLOCI_AKS_KUBECONFIG:-.local/floci/portfolio-aks.kubeconfig}"
FLOCI_ACR_NAME="${FLOCI_ACR_NAME:-portfolioacr}"
FLOCI_ACR_HOST_REGISTRY="${FLOCI_ACR_HOST_REGISTRY:-localhost:5000}"
FLOCI_ACR_NODE_REGISTRY="${FLOCI_ACR_NODE_REGISTRY:-host.docker.internal:5000}"
SERVICE_NAMESPACE="${SERVICE_NAMESPACE:-apps-dev}"
SERVICE_TIMEOUT="${SERVICE_TIMEOUT:-5m}"
SERVICE_TIMEOUT_SECONDS="${SERVICE_TIMEOUT_SECONDS:-300}"
ARGOCD_APPLICATION_REVISION="${ARGOCD_APPLICATION_REVISION:-}"

for required_variable in SERVICE_NAME SERVICE_SOURCE_PATH SERVICE_OVERLAY ARGOCD_APPLICATION_MANIFEST; do
  if [[ -z "${!required_variable:-}" ]]; then
    echo "missing required configuration: ${required_variable}" >&2
    exit 1
  fi
done

for command in docker git kubectl python3; do
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

if [[ -n "$(git status --porcelain -- "${SERVICE_SOURCE_PATH}")" ]]; then
  echo "${SERVICE_SOURCE_PATH} has uncommitted changes." >&2
  echo "Commit the service source before creating a deterministic proof artifact." >&2
  exit 1
fi

desired_revision="$(git rev-parse HEAD)"
proof_dir="$(mktemp -d)"
trap 'rm -rf "${proof_dir}"' EXIT

source_tree_id="$(git rev-parse "HEAD:${SERVICE_SOURCE_PATH}")"
rendered_image="$(kubectl kustomize "${SERVICE_OVERLAY}" | awk '/image: / { print $NF; exit }')"
local_image="${SERVICE_NAME}:${source_tree_id}"
host_image="${FLOCI_ACR_HOST_REGISTRY}/${FLOCI_ACR_NAME}/${SERVICE_NAME}:${source_tree_id}"
expected_image="${FLOCI_ACR_NODE_REGISTRY}/${FLOCI_ACR_NAME}/${SERVICE_NAME}:${source_tree_id}"

if [[ "${rendered_image}" != "${expected_image}" ]]; then
  echo "Floci overlay image must be ${expected_image}; found ${rendered_image:-none}." >&2
  echo "Update the Git-tracked image tag after changing ${SERVICE_SOURCE_PATH}." >&2
  exit 1
fi

if ! kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes >/dev/null; then
  echo "Floci AKS is not reachable. Run 'make floci-aks-up' first." >&2
  exit 1
fi

echo "building ${local_image} from ${SERVICE_SOURCE_PATH}"
docker build --tag "${local_image}" "${SERVICE_SOURCE_PATH}"

echo "pushing ${host_image} to Floci ACR"
docker tag "${local_image}" "${host_image}"
docker push "${host_image}"
artifact_reference="$(docker image inspect --format '{{index .RepoDigests 0}}' "${host_image}")"
artifact_digest="${artifact_reference##*@}"
if [[ ! "${artifact_digest}" =~ ^sha256:[a-f0-9]{64}$ ]]; then
  echo "No valid registry digest found for ${host_image}." >&2
  exit 1
fi

k3s_container="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes -o jsonpath='{.items[0].metadata.name}')"
if ! docker inspect "${k3s_container}" --format '{{.State.Running}}' 2>/dev/null | grep -qx 'true'; then
  echo "Kubernetes node container '${k3s_container}' is unavailable." >&2
  exit 1
fi

echo "applying Git-tracked Argo CD Application"
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" apply -f "${ARGOCD_APPLICATION_MANIFEST}"

if [[ -n "${ARGOCD_APPLICATION_REVISION}" ]]; then
  echo "using Argo CD revision override ${ARGOCD_APPLICATION_REVISION} for this local proof"
  kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n argocd patch application "${SERVICE_NAME}" \
    --type merge \
    -p "{\"spec\":{\"source\":{\"targetRevision\":\"${ARGOCD_APPLICATION_REVISION}\"}}}"
fi

kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n argocd annotate application "${SERVICE_NAME}" \
  argocd.argoproj.io/refresh=hard --overwrite >/dev/null

echo "waiting for Argo CD to reconcile Git revision ${desired_revision}"
deadline=$((SECONDS + SERVICE_TIMEOUT_SECONDS))
while true; do
  sync_status="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n argocd get application "${SERVICE_NAME}" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  synced_revision="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n argocd get application "${SERVICE_NAME}" -o jsonpath='{.status.sync.revision}' 2>/dev/null || true)"
  if [[ "${sync_status}" == "Synced" && "${synced_revision}" == "${desired_revision}" ]]; then
    break
  fi
  if (( SECONDS >= deadline )); then
    echo "Argo CD did not reach Synced within ${SERVICE_TIMEOUT}." >&2
    kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n argocd get application "${SERVICE_NAME}" -o yaml >&2 || true
    exit 1
  fi
  sleep 3
done

live_image="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" get deployment "${SERVICE_NAME}" -o "jsonpath={.spec.template.spec.containers[?(@.name=='${SERVICE_NAME}')].image}")"
live_pull_policy="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" get deployment "${SERVICE_NAME}" -o "jsonpath={.spec.template.spec.containers[?(@.name=='${SERVICE_NAME}')].imagePullPolicy}")"
if [[ "${live_image}" != "${expected_image}" || "${live_pull_policy}" != "Always" ]]; then
  echo "Reconciled deployment must use ${expected_image} with imagePullPolicy Always." >&2
  exit 1
fi

kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" get pods -l "app=${SERVICE_NAME}" -o json > "${proof_dir}/previous-pods.json"
echo "removing cached image reference before recreating the local proof pods"
docker exec "${k3s_container}" ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images rm "${expected_image}"
if docker exec "${k3s_container}" ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images list -q | grep -Fxq "${expected_image}"; then
  echo "Cached image reference still exists; cannot prove registry pull." >&2
  exit 1
fi

# Recreate only this local reference workload, without changing Git desired state.
# An unchanged Deployment does not restart pods just because the image was evicted.
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" delete pod -l "app=${SERVICE_NAME}" \
  --wait=true --timeout="${SERVICE_TIMEOUT}"

echo "verifying Kubernetes rollout"
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" rollout status "deployment/${SERVICE_NAME}" --timeout "${SERVICE_TIMEOUT}"

echo "verifying new Ready pods run the pushed registry digest"
deadline=$((SECONDS + SERVICE_TIMEOUT_SECONDS))
while true; do
  kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" get pods -l "app=${SERVICE_NAME}" -o json > "${proof_dir}/pods.json"
  if python3 scripts/infra/local/verify-service-pods.py "${SERVICE_NAME}" "${expected_image}" "${artifact_digest}" "${proof_dir}/previous-pods.json" \
    < "${proof_dir}/pods.json" > "${proof_dir}/pod-evidence" 2> "${proof_dir}/verification-error"; then
    cat "${proof_dir}/pod-evidence"
    break
  fi
  if (( SECONDS >= deadline )); then
    cat "${proof_dir}/verification-error" >&2
    exit 1
  fi
  sleep 3
done

echo "verifying blocking health endpoint"
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" delete pod "${SERVICE_NAME}-health" \
  --ignore-not-found --wait=true
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" -n "${SERVICE_NAMESPACE}" run "${SERVICE_NAME}-health" \
  --rm -i --restart=Never --image=curlimages/curl:8.8.0 \
  -- curl -fsS "http://${SERVICE_NAME}:8080/health"

echo
echo "${SERVICE_NAME} delivery proof complete."
echo "artifact: ${expected_image}"
echo "registry digest: ${artifact_digest}"
echo "source tree: ${source_tree_id}"
echo "desired Git revision: ${desired_revision}"
echo "Argo Application: ${SERVICE_NAME} (Synced at ${synced_revision})"
echo "target: ${SERVICE_NAMESPACE}/deployment/${SERVICE_NAME}"
