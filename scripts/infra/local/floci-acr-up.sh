#!/usr/bin/env bash
set -euo pipefail

# Creates the Docker-backed Floci ACR resource and configures the real local
# k3s node to pull from it over the host-published, plain-HTTP registry port.
FLOCI_AZ_ENDPOINT="${FLOCI_AZ_ENDPOINT:-http://localhost:4577}"
FLOCI_AZ_CONTAINER="${FLOCI_AZ_CONTAINER:-floci-az}"
FLOCI_AKS_KUBECONFIG="${FLOCI_AKS_KUBECONFIG:-.local/floci/portfolio-aks.kubeconfig}"
FLOCI_ACR_SUBSCRIPTION="${FLOCI_ACR_SUBSCRIPTION:-local-sub}"
FLOCI_ACR_RESOURCE_GROUP="${FLOCI_ACR_RESOURCE_GROUP:-portfolio-local}"
FLOCI_ACR_NAME="${FLOCI_ACR_NAME:-portfolioacr}"
FLOCI_ACR_LOCATION="${FLOCI_ACR_LOCATION:-eastus}"
FLOCI_ACR_HOST_REGISTRY="${FLOCI_ACR_HOST_REGISTRY:-localhost:5000}"
FLOCI_ACR_NODE_REGISTRY="${FLOCI_ACR_NODE_REGISTRY:-host.docker.internal:5000}"

for command in curl docker floci kubectl; do
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

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not reachable. Start Docker Desktop and try again." >&2
  exit 1
fi

if ! curl -sS --connect-timeout 2 -o /dev/null "${FLOCI_AZ_ENDPOINT}"; then
  echo "starting Floci AZ"
  floci az start
fi

if ! docker inspect "${FLOCI_AZ_CONTAINER}" >/dev/null 2>&1; then
  echo "Floci AZ container '${FLOCI_AZ_CONTAINER}' was not found." >&2
  exit 1
fi

if docker inspect "${FLOCI_AZ_CONTAINER}" --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -qx 'FLOCI_AZ_SERVICES_ACR_MOCKED=true'; then
  echo "Floci ACR is configured for mocked mode; registry pull validation requires FLOCI_AZ_SERVICES_ACR_MOCKED=false." >&2
  exit 1
fi

acr_path="/subscriptions/${FLOCI_ACR_SUBSCRIPTION}/resourceGroups/${FLOCI_ACR_RESOURCE_GROUP}/providers/Microsoft.ContainerRegistry/registries/${FLOCI_ACR_NAME}"
acr_url="${FLOCI_AZ_ENDPOINT}${acr_path}?api-version=2023-07-01"
response_file="$(mktemp)"
trap 'rm -f "${response_file}"' EXIT

status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' "${acr_url}")"
case "${status_code}" in
  200)
    echo "using existing Floci ACR resource '${FLOCI_ACR_NAME}'"
    ;;
  404)
    echo "creating Floci ACR resource '${FLOCI_ACR_NAME}'"
    curl -fsS -X PUT "${acr_url}" \
      -H 'Content-Type: application/json' \
      -d "{\"location\":\"${FLOCI_ACR_LOCATION}\",\"sku\":{\"name\":\"Basic\"},\"properties\":{\"adminUserEnabled\":true}}" >/dev/null
    ;;
  *)
    echo "unable to query Floci ACR resource (HTTP ${status_code}):" >&2
    cat "${response_file}" >&2
    exit 1
    ;;
esac

echo "waiting for Floci ACR registry endpoint ${FLOCI_ACR_HOST_REGISTRY}"
for _ in {1..30}; do
  if curl -fsS --connect-timeout 2 "http://${FLOCI_ACR_HOST_REGISTRY}/v2/" >/dev/null; then
    break
  fi
  sleep 2
done
if ! curl -fsS --connect-timeout 2 "http://${FLOCI_ACR_HOST_REGISTRY}/v2/" >/dev/null; then
  echo "Floci ACR registry endpoint ${FLOCI_ACR_HOST_REGISTRY} did not become ready." >&2
  exit 1
fi

if ! kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes >/dev/null; then
  echo "Floci AKS is not reachable. Run 'make floci-aks-up' first." >&2
  exit 1
fi

k3s_container="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes -o jsonpath='{.items[0].metadata.name}')"
desired_registry_config="$(cat <<EOF
mirrors:
  "${FLOCI_ACR_NODE_REGISTRY}":
    endpoint:
      - "http://${FLOCI_ACR_NODE_REGISTRY}"
EOF
)"
current_registry_config="$(docker exec "${k3s_container}" sh -c 'cat /etc/rancher/k3s/registries.yaml 2>/dev/null || true')"

if [[ "${current_registry_config}" != "${desired_registry_config}" ]]; then
  echo "configuring k3s to pull Floci ACR images through ${FLOCI_ACR_NODE_REGISTRY}"
  printf '%s\n' "${desired_registry_config}" \
    | docker exec -i "${k3s_container}" sh -c 'mkdir -p /etc/rancher/k3s && tee /etc/rancher/k3s/registries.yaml >/dev/null'
  echo "restarting the local k3s node to load registry configuration"
  docker restart "${k3s_container}" >/dev/null
  deadline=$((SECONDS + 90))
  until kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes >/dev/null 2>&1; do
    if (( SECONDS >= deadline )); then
      echo "k3s API did not return after loading Floci ACR configuration." >&2
      exit 1
    fi
    sleep 2
  done
  if ! kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" wait --for=condition=Ready node --all --timeout=90s; then
    echo "k3s did not return Ready after loading Floci ACR configuration." >&2
    exit 1
  fi
fi

echo
echo "Floci ACR bootstrap complete."
echo "host push registry: ${FLOCI_ACR_HOST_REGISTRY}/${FLOCI_ACR_NAME}"
echo "k3s pull registry: ${FLOCI_ACR_NODE_REGISTRY}/${FLOCI_ACR_NAME}"
