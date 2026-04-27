#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

curl -fsS "$API/user/tokens/verify" \
  -H "$(auth_header)" | jq .

curl -fsS "$API/user/tokens/permission_groups" \
  -H "$(auth_header)" | jq -r '
    .result[]
    | [.id, .name, (.scopes | join(","))]
    | @tsv
  '
