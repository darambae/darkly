#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: POST /api/telemetry/heartbeat
# Explicit confirmation required for state-changing requests.
if [[ "${ALLOW_WRITE:-0}" != "1" ]]; then
  echo "[BLOCKED] Set ALLOW_WRITE=1 to execute this POST request." >&2
  exit 2
fi
REQUEST_PATH=/api/telemetry/heartbeat
TS="$(date +%s)"
BODY="$(python3 - "$TS" <<'PYINNER'
import json,sys
print(json.dumps({'ts':int(sys.argv[1])*1000,'page':'/','ua':'darkly-local-audit'}))
PYINNER
)"
run_curl \
    --request \
    POST \
    --header \
    'Content-Type: application/json' \
    --data \
    "$BODY" \
    "$BASE_URL$REQUEST_PATH"
