#!/usr/bin/env bash
set -euo pipefail

operation="${1:-inspect}"
case "$operation" in
  inspect|infra-up|validate|linux-check) ;;
  *) echo 'usage: dispatch.sh [inspect|infra-up|validate|linux-check]' >&2; exit 2 ;;
esac
command -v gh >/dev/null || { echo 'Install/authenticate gh to dispatch a remote run.' >&2; exit 1; }

if [[ "$operation" == "linux-check" ]]; then
  exec gh workflow run linux-compute.yml \
    --repo "${HOME_COMPUTE_CONTROL_REPO:-srstanl/portfolio-home-control}" --ref main
fi

gh workflow run home-compute.yml \
  --repo "${HOME_COMPUTE_CONTROL_REPO:-srstanl/portfolio-home-control}" \
  --ref main \
  -f "operation=${operation}" \
  -f "portfolio_ref=${HOME_COMPUTE_PORTFOLIO_REF:-main}"
