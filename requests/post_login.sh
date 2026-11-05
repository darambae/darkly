#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: POST /login
# Explicit confirmation required for state-changing requests.
if [[ "${ALLOW_WRITE:-0}" != "1" ]]; then
  echo "[BLOCKED] Set ALLOW_WRITE=1 to execute this POST request." >&2
  exit 2
fi
REQUEST_PATH=/login
check_users_json
EMAIL="$(get_user_field email)"
if [[ -z "${LOGIN_PASSWORD:-}" ]]; then
  echo "[ERROR] Provide LOGIN_PASSWORD using an environment variable." >&2; exit 2
fi
# Note: curl command arguments may expose password in process listing while running.
CURL_AUTH=()
run_curl \
    --request \
    POST \
    --data-urlencode \
    "identity=${EMAIL}" \
    --data-urlencode \
    "password=${LOGIN_PASSWORD}" \
    "$BASE_URL$REQUEST_PATH"
