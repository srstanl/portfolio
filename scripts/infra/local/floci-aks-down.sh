#!/usr/bin/env bash
set -euo pipefail

# Deletes one Floci AKS resource and its generated local kubeconfig. The shared
# Floci AZ emulator remains running for other local Azure workflows.
FLOCI_AZ_ENDPOINT="${FLOCI_AZ_ENDPOINT:-http://localhost:4577}"
FLOCI_AKS_SUBSCRIPTION="${FLOCI_AKS_SUBSCRIPTION:-local-sub}"
FLOCI_AKS_RESOURCE_GROUP="${FLOCI_AKS_RESOURCE_GROUP:-portfolio-local}"
FLOCI_AKS_CLUSTER="${FLOCI_AKS_CLUSTER:-portfolio-aks}"
FLOCI_AKS_KUBECONFIG="${FLOCI_AKS_KUBECONFIG:-.local/floci/${FLOCI_AKS_CLUSTER}.kubeconfig}"
FLOCI_AKS_TIMEOUT_SECONDS="${FLOCI_AKS_TIMEOUT_SECONDS:-180}"

for command in curl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "missing required command: ${command}" >&2
    exit 1
  fi
done

cluster_path="/subscriptions/${FLOCI_AKS_SUBSCRIPTION}/resourceGroups/${FLOCI_AKS_RESOURCE_GROUP}/providers/Microsoft.ContainerService/managedClusters/${FLOCI_AKS_CLUSTER}"
cluster_url="${FLOCI_AZ_ENDPOINT}${cluster_path}?api-version=2024-04-01"
response_file="$(mktemp)"
trap 'rm -f "${response_file}"' EXIT

status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' -X DELETE "${cluster_url}")"
case "${status_code}" in
  202|204)
    echo "deleting Floci AKS resource '${FLOCI_AKS_CLUSTER}'"
    ;;
  404)
    echo "Floci AKS resource '${FLOCI_AKS_CLUSTER}' does not exist"
    rm -f "${FLOCI_AKS_KUBECONFIG}"
    exit 0
    ;;
  *)
    echo "unable to delete Floci AKS resource (HTTP ${status_code}):" >&2
    cat "${response_file}" >&2
    exit 1
    ;;
esac

deadline=$((SECONDS + FLOCI_AKS_TIMEOUT_SECONDS))
while true; do
  status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' "${cluster_url}")"
  if [[ "${status_code}" == "404" ]]; then
    rm -f "${FLOCI_AKS_KUBECONFIG}"
    echo "Floci AKS resource '${FLOCI_AKS_CLUSTER}' deleted. Floci AZ remains running."
    exit 0
  fi

  if (( SECONDS >= deadline )); then
    echo "timed out waiting for Floci AKS resource '${FLOCI_AKS_CLUSTER}' to delete after ${FLOCI_AKS_TIMEOUT_SECONDS}s." >&2
    echo "Last response (HTTP ${status_code}):" >&2
    cat "${response_file}" >&2
    exit 1
  fi
  sleep 5
done
