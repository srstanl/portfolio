#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-devex-local}"
K3S_IMAGE="${K3S_IMAGE:-rancher/k3s:v1.31.5-k3s1}"

for cmd in k3d kubectl; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "missing required command: ${cmd}"
    exit 1
  fi
done

if k3d cluster list "${CLUSTER_NAME}" >/dev/null 2>&1; then
  echo "k3d cluster '${CLUSTER_NAME}' already exists"
else
  echo "creating k3d cluster '${CLUSTER_NAME}'"
  k3d cluster create "${CLUSTER_NAME}" \
    --image "${K3S_IMAGE}" \
    --agents 2 \
    --wait \
    --port "8080:80@loadbalancer" \
    --port "8443:443@loadbalancer"
fi

echo "ensuring base namespaces exist"
for ns in platform-system apps-dev observability idp; do
  kubectl create namespace "${ns}" --dry-run=client -o yaml | kubectl apply -f -
done

echo
echo "cluster ready:"
kubectl get nodes -o wide
echo
echo "namespaces:"
kubectl get ns platform-system apps-dev observability idp

