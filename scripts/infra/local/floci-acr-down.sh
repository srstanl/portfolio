#!/usr/bin/env bash
set -euo pipefail

# Deletes one Floci ACR resource. The shared registry sidecar may remain while
# Floci AZ has other ACR resources; the emulator itself is never stopped.
FLOCI_AZ_ENDPOINT="${FLOCI_AZ_ENDPOINT:-http://localhost:4577}"
FLOCI_ACR_SUBSCRIPTION="${FLOCI_ACR_SUBSCRIPTION:-local-sub}"
FLOCI_ACR_RESOURCE_GROUP="${FLOCI_ACR_RESOURCE_GROUP:-portfolio-local}"
FLOCI_ACR_NAME="${FLOCI_ACR_NAME:-portfolioacr}"
FLOCI_ACR_TIMEOUT_SECONDS="${FLOCI_ACR_TIMEOUT_SECONDS:-90}"

for command in curl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "missing required command: ${command}" >&2
    exit 1
  fi
done

acr_path="/subscriptions/${FLOCI_ACR_SUBSCRIPTION}/resourceGroups/${FLOCI_ACR_RESOURCE_GROUP}/providers/Microsoft.ContainerRegistry/registries/${FLOCI_ACR_NAME}"
acr_url="${FLOCI_AZ_ENDPOINT}${acr_path}?api-version=2023-07-01"
response_file="$(mktemp)"
trap 'rm -f "${response_file}"' EXIT

status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' -X DELETE "${acr_url}")"
case "${status_code}" in
  202|204)
    echo "deleting Floci ACR resource '${FLOCI_ACR_NAME}'"
    ;;
  404)
    echo "Floci ACR resource '${FLOCI_ACR_NAME}' does not exist"
    exit 0
    ;;
  *)
    echo "unable to delete Floci ACR resource (HTTP ${status_code}):" >&2
    cat "${response_file}" >&2
    exit 1
    ;;
esac

deadline=$((SECONDS + FLOCI_ACR_TIMEOUT_SECONDS))
while true; do
  status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' "${acr_url}")"
  if [[ "${status_code}" == "404" ]]; then
    echo "Floci ACR resource '${FLOCI_ACR_NAME}' deleted. Floci AZ remains running."
    exit 0
  fi
  if (( SECONDS >= deadline )); then
    echo "timed out waiting for Floci ACR resource '${FLOCI_ACR_NAME}' to delete after ${FLOCI_ACR_TIMEOUT_SECONDS}s." >&2
    cat "${response_file}" >&2
    exit 1
  fi
  sleep 2
done
