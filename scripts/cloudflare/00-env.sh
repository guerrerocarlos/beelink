#!/usr/bin/env bash
set -euo pipefail

# Export the bootstrap token in your shell before running the other scripts.
: "${CLOUDFLARE_API_TOKEN:?export CLOUDFLARE_API_TOKEN first}"

API="https://api.cloudflare.com/client/v4"

auth_header() {
  printf 'Authorization: Bearer %s' "$CLOUDFLARE_API_TOKEN"
}
