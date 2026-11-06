#!/usr/bin/env bash
set -euo pipefail

operation="${1:-inspect}"
case "$operation" in
  inspect|infra-up|validate) ;;
  *) echo 'usage: dispatch.sh [inspect|infra-up|validate]' >&2; exit 2 ;;
esac
command -v gh >/dev/null || { echo 'Install/authenticate gh to dispatch a remote run.' >&2; exit 1; }

gh workflow run home-compute.yml \
  --repo "${HOME_COMPUTE_CONTROL_REPO:-srstanl/portfolio-home-control}" \
  --ref main \
  -f "operation=${operation}" \
  -f "portfolio_ref=${HOME_COMPUTE_PORTFOLIO_REF:-feat/floci-acr-promotion}"
