#!/usr/bin/env bash
set -euo pipefail

# Provisions a real k3s-backed AKS resource through Floci AZ and writes a
# kubeconfig that is reachable from the developer host.
FLOCI_AZ_ENDPOINT="${FLOCI_AZ_ENDPOINT:-http://localhost:4577}"
FLOCI_AZ_CONTAINER="${FLOCI_AZ_CONTAINER:-floci-az}"
FLOCI_AKS_SUBSCRIPTION="${FLOCI_AKS_SUBSCRIPTION:-local-sub}"
FLOCI_AKS_RESOURCE_GROUP="${FLOCI_AKS_RESOURCE_GROUP:-portfolio-local}"
FLOCI_AKS_CLUSTER="${FLOCI_AKS_CLUSTER:-portfolio-aks}"
FLOCI_AKS_LOCATION="${FLOCI_AKS_LOCATION:-eastus}"
FLOCI_AKS_KUBECONFIG="${FLOCI_AKS_KUBECONFIG:-.local/floci/${FLOCI_AKS_CLUSTER}.kubeconfig}"
FLOCI_AKS_TIMEOUT_SECONDS="${FLOCI_AKS_TIMEOUT_SECONDS:-180}"

for command in curl docker floci kubectl python3; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "missing required command: ${command}" >&2
    exit 1
  fi
done

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
  echo "Set FLOCI_AZ_CONTAINER if your Floci AZ container has a different name." >&2
  exit 1
fi

if docker inspect "${FLOCI_AZ_CONTAINER}" --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -qx 'FLOCI_AZ_SERVICES_AKS_MOCKED=true'; then
  echo "Floci AKS is configured for mocked mode; real Kubernetes validation requires FLOCI_AZ_SERVICES_AKS_MOCKED=false." >&2
  exit 1
fi

cluster_path="/subscriptions/${FLOCI_AKS_SUBSCRIPTION}/resourceGroups/${FLOCI_AKS_RESOURCE_GROUP}/providers/Microsoft.ContainerService/managedClusters/${FLOCI_AKS_CLUSTER}"
cluster_url="${FLOCI_AZ_ENDPOINT}${cluster_path}?api-version=2024-04-01"
credential_url="${FLOCI_AZ_ENDPOINT}${cluster_path}/listClusterAdminCredential?api-version=2024-04-01"
response_file="$(mktemp)"
trap 'rm -f "${response_file}" "${response_file}.b64"' EXIT

status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' "${cluster_url}")"
case "${status_code}" in
  200)
    echo "using existing Floci AKS resource '${FLOCI_AKS_CLUSTER}'"
    ;;
  404)
    echo "creating Floci AKS resource '${FLOCI_AKS_CLUSTER}'"
    curl -fsS -X PUT "${cluster_url}" \
      -H 'Content-Type: application/json' \
      -d "{\"location\":\"${FLOCI_AKS_LOCATION}\",\"properties\":{\"kubernetesVersion\":\"1.29\",\"dnsPrefix\":\"${FLOCI_AKS_CLUSTER}\",\"agentPoolProfiles\":[{\"name\":\"nodepool1\",\"count\":1,\"vmSize\":\"Standard_DS2_v2\",\"osType\":\"Linux\",\"mode\":\"System\"}]}}" >/dev/null
    ;;
  *)
    echo "unable to query Floci AKS resource (HTTP ${status_code}):" >&2
    cat "${response_file}" >&2
    exit 1
    ;;
esac

echo "waiting for Floci to return cluster credentials"
deadline=$((SECONDS + FLOCI_AKS_TIMEOUT_SECONDS))
while true; do
  status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' -X POST "${credential_url}")"
  if [[ "${status_code}" == "200" ]] \
    && python3 -c 'import json, sys; print(json.load(sys.stdin)["kubeconfigs"][0]["value"])' <"${response_file}" >"${response_file}.b64" 2>/dev/null; then
    break
  fi

  if (( SECONDS >= deadline )); then
    echo "timed out waiting for Floci AKS credentials after ${FLOCI_AKS_TIMEOUT_SECONDS}s." >&2
    echo "Last response (HTTP ${status_code}):" >&2
    cat "${response_file}" >&2
    exit 1
  fi
  sleep 5
done

mkdir -p "$(dirname "${FLOCI_AKS_KUBECONFIG}")"
python3 - "${response_file}.b64" "${FLOCI_AKS_KUBECONFIG}" <<'PY'
import base64
import pathlib
import sys

encoded_path, kubeconfig_path = map(pathlib.Path, sys.argv[1:])
kubeconfig_path.write_bytes(base64.b64decode(encoded_path.read_text().strip()))
PY

k3s_container="$(python3 - "${FLOCI_AKS_KUBECONFIG}" <<'PY'
import pathlib
import re
import sys

contents = pathlib.Path(sys.argv[1]).read_text()
match = re.search(r"server:\s+https://([^:/]+):\d+", contents)
if not match:
    raise SystemExit("could not find the Kubernetes API hostname in the Floci kubeconfig")
print(match.group(1))
PY
)"

if ! docker inspect "${k3s_container}" --format '{{.State.Running}}' 2>/dev/null | grep -qx 'true'; then
  echo "Floci AKS resource '${FLOCI_AKS_CLUSTER}' is stale: live k3s container '${k3s_container}' is unavailable."
  echo "recreating the Floci AKS resource"
  curl -fsS -X DELETE "${cluster_url}" >/dev/null
  deadline=$((SECONDS + FLOCI_AKS_TIMEOUT_SECONDS))
  while true; do
    status_code="$(curl -sS -o "${response_file}" -w '%{http_code}' "${cluster_url}")"
    if [[ "${status_code}" == "404" ]]; then
      exec "$0"
    fi
    if (( SECONDS >= deadline )); then
      echo "timed out waiting for stale Floci AKS resource '${FLOCI_AKS_CLUSTER}' to delete." >&2
      cat "${response_file}" >&2
      exit 1
    fi
    sleep 2
  done
fi

host_port="$(docker port "${k3s_container}" 6443/tcp | head -n 1 | sed -E 's/.*:([0-9]+)$/\1/')"
if [[ ! "${host_port}" =~ ^[0-9]+$ ]]; then
  echo "could not determine the host port for ${k3s_container}:6443." >&2
  echo "Ensure Floci AZ exposes the AKS API-server port range to the host." >&2
  exit 1
fi

python3 - "${FLOCI_AKS_KUBECONFIG}" "${k3s_container}" "${host_port}" <<'PY'
import pathlib
import re
import sys

kubeconfig_path = pathlib.Path(sys.argv[1])
container_name = re.escape(sys.argv[2])
host_port = sys.argv[3]
contents = kubeconfig_path.read_text()
updated, replacements = re.subn(
    rf"https://{container_name}:\d+",
    f"https://localhost:{host_port}",
    contents,
)
if replacements != 1:
    raise SystemExit("could not replace the Docker-only API hostname in the Floci kubeconfig")
kubeconfig_path.write_text(updated)
PY

echo "validating Kubernetes API access"
if kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes >/dev/null 2>&1; then
  :
else
  echo "Floci returned kubeconfig credentials were rejected; using the live k3s admin kubeconfig instead."
  echo "waiting for the live k3s admin kubeconfig"
  while ! docker exec "${k3s_container}" test -s /etc/rancher/k3s/k3s.yaml >/dev/null 2>&1; do
    if (( SECONDS >= deadline )); then
      echo "timed out waiting for ${k3s_container} to write its admin kubeconfig." >&2
      echo "container state: $(docker inspect "${k3s_container}" --format '{{.State.Status}}' 2>/dev/null || echo missing)" >&2
      exit 1
    fi
    sleep 2
  done
  docker cp "${k3s_container}:/etc/rancher/k3s/k3s.yaml" "${FLOCI_AKS_KUBECONFIG}"
  python3 - "${FLOCI_AKS_KUBECONFIG}" "${host_port}" <<'PY'
import pathlib
import re
import sys

kubeconfig_path = pathlib.Path(sys.argv[1])
host_port = sys.argv[2]
contents = kubeconfig_path.read_text()
updated, replacements = re.subn(
    r"https://[^:/]+:\d+",
    f"https://localhost:{host_port}",
    contents,
)
if replacements != 1:
    raise SystemExit("could not replace the live k3s API endpoint in the kubeconfig")
kubeconfig_path.write_text(updated)
PY
  echo "waiting for the live Kubernetes API"
  while ! kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes >/dev/null 2>&1; do
    if (( SECONDS >= deadline )); then
      echo "timed out waiting for the live Kubernetes API." >&2
      exit 1
    fi
    sleep 2
  done
fi

echo "waiting for a Ready Kubernetes node"
while true; do
  ready_node_count="$(kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes --no-headers 2>/dev/null \
    | awk '$2 == "Ready" { count += 1 } END { print count + 0 }')"
  if (( ready_node_count > 0 )); then
    break
  fi
  if (( SECONDS >= deadline )); then
    echo "timed out waiting for a Ready Kubernetes node." >&2
    exit 1
  fi
  sleep 2
done
kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" get nodes

echo "ensuring base namespaces exist"
for namespace in platform-system apps-dev apps-staging apps-prod idp; do
  kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" create namespace "${namespace}" --dry-run=client -o yaml \
    | kubectl --kubeconfig "${FLOCI_AKS_KUBECONFIG}" apply -f -
done

echo
echo "Floci AKS bootstrap complete."
echo "export KUBECONFIG=$(pwd)/${FLOCI_AKS_KUBECONFIG}"
