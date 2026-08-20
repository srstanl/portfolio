#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_RELEASE="${ARGOCD_RELEASE:-argocd}"
ARGOCD_TIMEOUT="${ARGOCD_TIMEOUT:-5m}"
ARGOCD_KUBECONFIG="${ARGOCD_KUBECONFIG:-${FLOCI_AKS_KUBECONFIG:-.local/floci/portfolio-aks.kubeconfig}}"

for command in helm kubectl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "missing required command: ${command}" >&2
    exit 1
  fi
done

if [[ ! -f "${ARGOCD_KUBECONFIG}" ]]; then
  echo "Floci AKS kubeconfig not found: ${ARGOCD_KUBECONFIG}" >&2
  exit 1
fi

echo "uninstalling Argo CD release '${ARGOCD_RELEASE}' if present"
helm uninstall "${ARGOCD_RELEASE}" --namespace "${ARGOCD_NAMESPACE}" --kubeconfig "${ARGOCD_KUBECONFIG}" >/dev/null 2>&1 || true

if kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" get namespace "${ARGOCD_NAMESPACE}" >/dev/null 2>&1; then
  echo "deleting namespace '${ARGOCD_NAMESPACE}'"
  kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" delete namespace "${ARGOCD_NAMESPACE}" --wait=false
  kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" wait --for=delete "namespace/${ARGOCD_NAMESPACE}" --timeout "${ARGOCD_TIMEOUT}"
else
  echo "namespace '${ARGOCD_NAMESPACE}' does not exist"
fi

echo "Argo CD release removed. Floci AKS and cluster-level Argo CD CRDs remain intact."
