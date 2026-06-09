#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <owner/repo> [ruleset-json]" >&2
  exit 1
fi

REPO="$1"
RULESET_FILE="${2:-scripts/github/rulesets/protect-main.json}"

if [[ ! -f "$RULESET_FILE" ]]; then
  echo "Ruleset file not found: $RULESET_FILE" >&2
  exit 1
fi

echo "Applying ruleset from $RULESET_FILE to $REPO"
gh api "repos/$REPO/rulesets" --method POST --input "$RULESET_FILE"
