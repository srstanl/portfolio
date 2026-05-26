#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-observability}"
PROM_RELEASE="${PROM_RELEASE:-kube-prometheus-stack}"
OTEL_RELEASE="${OTEL_RELEASE:-otel-collector}"
OTEL_IMAGE_REPOSITORY="${OTEL_IMAGE_REPOSITORY:-otel/opentelemetry-collector-contrib}"
OTEL_IMAGE_TAG="${OTEL_IMAGE_TAG:-0.128.0}"

for cmd in helm kubectl; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "missing required command: ${cmd}"
    exit 1
  fi
done

echo "ensuring namespace '${NAMESPACE}' exists"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "adding/updating Helm repos"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts >/dev/null
helm repo update >/dev/null

echo "installing/upgrading ${PROM_RELEASE}"
helm upgrade --install "${PROM_RELEASE}" prometheus-community/kube-prometheus-stack \
  --namespace "${NAMESPACE}" \
  --wait \
  --timeout 10m

echo "installing/upgrading ${OTEL_RELEASE}"
helm upgrade --install "${OTEL_RELEASE}" open-telemetry/opentelemetry-collector \
  --namespace "${NAMESPACE}" \
  --set image.repository="${OTEL_IMAGE_REPOSITORY}" \
  --set image.tag="${OTEL_IMAGE_TAG}" \
  --set mode=deployment \
  --set config.exporters.debug.verbosity=normal \
  --set "config.service.pipelines.traces.exporters[0]=debug" \
  --set "config.service.pipelines.metrics.exporters[0]=debug" \
  --set "config.service.pipelines.logs.exporters[0]=debug" \
  --wait \
  --timeout 10m

echo
echo "observability bootstrap complete"
kubectl get pods -n "${NAMESPACE}"
echo
echo "to view Grafana locally:"
echo "kubectl -n ${NAMESPACE} port-forward svc/${PROM_RELEASE}-grafana 3000:80"
echo "default user: admin"
echo "password command:"
echo "kubectl -n ${NAMESPACE} get secret ${PROM_RELEASE}-grafana -o jsonpath='{.data.admin-password}' | base64 --decode; echo"
