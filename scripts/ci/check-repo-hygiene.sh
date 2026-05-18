#!/usr/bin/env bash
set -euo pipefail

fail=0

check_tracked() {
  local pattern="$1"
  local label="$2"

  if git ls-files -- "$pattern" | grep -q .; then
    echo "Found tracked ${label} files (should be ignored):"
    git ls-files -- "$pattern"
    fail=1
  fi
}

check_tracked '**/node_modules/**' 'node_modules'
check_tracked '**/.venv/**' '.venv'
check_tracked '**/__pycache__/**' '__pycache__'
check_tracked '**/.pytest_cache/**' '.pytest_cache'
check_tracked '**/.ruff_cache/**' '.ruff_cache'

if [[ $fail -ne 0 ]]; then
  exit 1
fi

echo 'Repo hygiene checks passed.'
