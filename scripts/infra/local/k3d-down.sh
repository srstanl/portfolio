#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-devex-local}"

if ! command -v k3d >/dev/null 2>&1; then
  echo "missing required command: k3d"
  exit 1
fi

if k3d cluster list "${CLUSTER_NAME}" >/dev/null 2>&1; then
  echo "deleting k3d cluster '${CLUSTER_NAME}'"
  k3d cluster delete "${CLUSTER_NAME}"
else
  echo "k3d cluster '${CLUSTER_NAME}' does not exist"
fi

