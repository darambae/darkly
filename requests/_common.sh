#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RESOURCE_DIR="${RESOURCE_DIR:-$PROJECT_DIR/Resources}"
BASE_URL="${BASE_URL:-http://localhost:4942}"
ROLE="${ROLE:-student}"
COOKIE_FILE="$RESOURCE_DIR/${ROLE}-cookie.txt"
if [[ ! "$BASE_URL" =~ ^http://localhost:4942/?$ && ! "$BASE_URL" =~ ^http://127\.0\.0\.1:4942/?$ ]]; then
  echo "[ERROR] BASE_URL must target local Darkly on port 4942" >&2; exit 2
fi
if [[ "$ROLE" != "guest" && ! -f "$COOKIE_FILE" ]]; then
  echo "[ERROR] Missing cookie file: $COOKIE_FILE" >&2
  echo "Generate role cookies first (or use ROLE=guest)." >&2; exit 2
fi
CURL_AUTH=()
if [[ "$ROLE" != "guest" ]]; then CURL_AUTH=(--cookie "$COOKIE_FILE"); fi
check_users_json() { [[ -f "$RESOURCE_DIR/users.json" ]] || { echo "Missing $RESOURCE_DIR/users.json" >&2; exit 2; }; }
get_user_field() {
  check_users_json
  python3 - "$RESOURCE_DIR/users.json" "$ROLE" "$1" <<'PYINNER'
import json,sys
with open(sys.argv[1],encoding='utf-8') as f: users=json.load(f)
user=next((u for u in users if u.get('role')==sys.argv[2]),None)
if user is None: raise SystemExit(f"No user for role {sys.argv[2]}")
print(user.get(sys.argv[3],''))
PYINNER
}
run_curl() {
  curl --silent --show-error --include --max-time 20 --max-redirs 0 \
    "${CURL_AUTH[@]}" "$@"
}
