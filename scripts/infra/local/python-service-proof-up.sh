#!/usr/bin/env bash
set -euo pipefail

# Compatibility wrapper for the Python reference proof.
SERVICE_NAME="python-service" \
SERVICE_SOURCE_PATH="examples/python-service" \
SERVICE_OVERLAY="platform/cd/python-service/overlays/floci" \
ARGOCD_APPLICATION_MANIFEST="platform/argocd/applications/python-service.yaml" \
exec "$(dirname "$0")/service-proof-up.sh"
