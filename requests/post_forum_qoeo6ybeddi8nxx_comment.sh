#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: POST /forum/qoeo6ybeddi8nxx/comment
# Explicit confirmation required for state-changing requests.
if [[ "${ALLOW_WRITE:-0}" != "1" ]]; then
  echo "[BLOCKED] Set ALLOW_WRITE=1 to execute this POST request." >&2
  exit 2
fi
REQUEST_PATH=/forum/qoeo6ybeddi8nxx/comment
run_curl \
    --request \
    POST \
    --data-urlencode \
    'content=Benign local testing comment' \
    "$BASE_URL$REQUEST_PATH"
