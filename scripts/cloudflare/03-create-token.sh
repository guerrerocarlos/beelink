#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

POLICY_FILE="${1:-token-policy.json}"

curl -fsS "$API/user/tokens" \
  -X POST \
  -H "$(auth_header)" \
  -H "Content-Type: application/json" \
  --data @"$POLICY_FILE" | jq .
