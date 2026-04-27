#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

# Edit this list deliberately before creating a token.
# Examples:
#   "Zone Read"
#   "DNS Write"
#   "Workers Scripts Write"
#   "Workers KV Storage Write"
#   "Workers Routes Write"
PERMISSIONS=(
  "Zone Read"
  "DNS Write"
)

TOKEN_NAME="${1:-zone-wide-token}"
OUT="${2:-token-policy.json}"

permission_groups_json=$(
  curl -fsS "$API/user/tokens/permission_groups" \
    -H "$(auth_header)" |
  jq --argjson wanted "$(printf '%s\n' "${PERMISSIONS[@]}" | jq -R . | jq -s .)" '
    .result
    | map(select(.name as $n | $wanted | index($n)))
    | map({id, name, scopes})
  '
)

count_found=$(jq 'length' <<<"$permission_groups_json")
count_wanted="${#PERMISSIONS[@]}"

if [[ "$count_found" -ne "$count_wanted" ]]; then
  echo "Requested permission names did not all resolve." >&2
  echo "Requested:" >&2
  printf '  %s\n' "${PERMISSIONS[@]}" >&2
  echo "Resolved:" >&2
  jq -r '.[].name' <<<"$permission_groups_json" >&2
  exit 1
fi

jq -n \
  --arg name "$TOKEN_NAME" \
  --argjson groups "$permission_groups_json" \
  '{
    name: $name,
    policies: [
      {
        effect: "allow",
        resources: {
          "com.cloudflare.api.account.zone.*": "*"
        },
        permission_groups: ($groups | map({id}))
      }
    ]
  }' > "$OUT"

echo "Wrote $OUT"
jq . "$OUT"
