#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: POST /agenda/import
# Explicit confirmation required for state-changing requests.
if [[ "${ALLOW_WRITE:-0}" != "1" ]]; then
  echo "[BLOCKED] Set ALLOW_WRITE=1 to execute this POST request." >&2
  exit 2
fi
REQUEST_PATH=/agenda/import
FILE="${UPLOAD_FILE:-$RESOURCE_DIR/agenda.xml}"
[[ -f "$FILE" ]] || { echo "Missing $FILE" >&2; exit 2; }
run_curl \
    --request \
    POST \
    --form \
    "file=@${FILE};type=text/xml" \
    "$BASE_URL$REQUEST_PATH"
