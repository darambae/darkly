#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: POST /profile/me/settings
# Explicit confirmation required for state-changing requests.
if [[ "${ALLOW_WRITE:-0}" != "1" ]]; then
  echo "[BLOCKED] Set ALLOW_WRITE=1 to execute this POST request." >&2
  exit 2
fi
REQUEST_PATH=/profile/me/settings
# Change to non-sensitive test values only; this updates the chosen account.
run_curl \
    --request \
    POST \
    --data-urlencode \
    first_name=Audit \
    --data-urlencode \
    last_name=Test \
    --data-urlencode \
    campus=Perpignan \
    "$BASE_URL$REQUEST_PATH"
