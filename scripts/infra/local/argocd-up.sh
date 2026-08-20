#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_RELEASE="${ARGOCD_RELEASE:-argocd}"
ARGOCD_CHART_VERSION="${ARGOCD_CHART_VERSION:-10.2.1}"
ARGOCD_TIMEOUT="${ARGOCD_TIMEOUT:-10m}"
ARGOCD_KUBECONFIG="${ARGOCD_KUBECONFIG:-${FLOCI_AKS_KUBECONFIG:-.local/floci/portfolio-aks.kubeconfig}}"

for command in helm kubectl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "missing required command: ${command}" >&2
    exit 1
  fi
done

if [[ ! -f "${ARGOCD_KUBECONFIG}" ]]; then
  echo "Floci AKS kubeconfig not found: ${ARGOCD_KUBECONFIG}" >&2
  echo "Run 'make floci-aks-up' first, or set ARGOCD_KUBECONFIG explicitly." >&2
  exit 1
fi

kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" get nodes >/dev/null

echo "ensuring namespace '${ARGOCD_NAMESPACE}' exists"
kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml \
  | kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" apply -f -

echo "adding/updating the Argo Helm repository"
helm repo add argo https://argoproj.github.io/argo-helm --force-update >/dev/null
helm repo update argo >/dev/null

echo "installing/upgrading Argo CD chart ${ARGOCD_CHART_VERSION}"
helm upgrade --install "${ARGOCD_RELEASE}" argo/argo-cd \
  --namespace "${ARGOCD_NAMESPACE}" \
  --kubeconfig "${ARGOCD_KUBECONFIG}" \
  --version "${ARGOCD_CHART_VERSION}" \
  --wait \
  --timeout "${ARGOCD_TIMEOUT}"

echo "verifying Argo CD workloads"
while IFS= read -r workload; do
  [[ -z "${workload}" ]] && continue
  kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" -n "${ARGOCD_NAMESPACE}" rollout status "${workload}" --timeout "${ARGOCD_TIMEOUT}"
done < <(kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" -n "${ARGOCD_NAMESPACE}" get deployment -o name)
while IFS= read -r workload; do
  [[ -z "${workload}" ]] && continue
  kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" -n "${ARGOCD_NAMESPACE}" rollout status "${workload}" --timeout "${ARGOCD_TIMEOUT}"
done < <(kubectl --kubeconfig "${ARGOCD_KUBECONFIG}" -n "${ARGOCD_NAMESPACE}" get statefulset -o name)

echo
echo "Argo CD bootstrap complete."
echo "Local UI: kubectl --kubeconfig ${ARGOCD_KUBECONFIG} -n ${ARGOCD_NAMESPACE} port-forward svc/${ARGOCD_RELEASE}-server 8080:443"
echo "Initial admin password: kubectl --kubeconfig ${ARGOCD_KUBECONFIG} -n ${ARGOCD_NAMESPACE} get secret ${ARGOCD_RELEASE}-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo"
