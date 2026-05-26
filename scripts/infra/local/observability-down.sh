#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-observability}"
PROM_RELEASE="${PROM_RELEASE:-kube-prometheus-stack}"
OTEL_RELEASE="${OTEL_RELEASE:-otel-collector}"

if ! command -v helm >/dev/null 2>&1; then
  echo "missing required command: helm"
  exit 1
fi

echo "uninstalling ${OTEL_RELEASE} (if present)"
helm uninstall "${OTEL_RELEASE}" -n "${NAMESPACE}" >/dev/null 2>&1 || true

echo "uninstalling ${PROM_RELEASE} (if present)"
helm uninstall "${PROM_RELEASE}" -n "${NAMESPACE}" >/dev/null 2>&1 || true

echo "done"

