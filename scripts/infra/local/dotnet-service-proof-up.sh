#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="dotnet-service" \
SERVICE_SOURCE_PATH="examples/dotnet-service" \
SERVICE_OVERLAY="platform/cd/dotnet-service/overlays/floci" \
ARGOCD_APPLICATION_MANIFEST="platform/argocd/applications/dotnet-service.yaml" \
exec "$(dirname "$0")/service-proof-up.sh"
