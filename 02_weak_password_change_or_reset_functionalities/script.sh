
#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:4942"

EMAIL="dorian@student.42.tech"
RESET_TOKEN="5dd6bc746080d6133d898694c3f8e9d8"
NEW_PASSWORD="e7v@eFS!Bn^SuJ7"

curl -sS -o /dev/null -D - \
  -X POST "$BASE_URL/reset-password/confirm" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H "Origin: $BASE_URL" \
  --data-urlencode "email=$EMAIL" \
  --data-urlencode "token=$RESET_TOKEN" \
  --data-urlencode "new_password=$NEW_PASSWORD"

curl -sS -i \
  -X POST "$BASE_URL/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Origin: $BASE_URL" \
  -H "Referer: $BASE_URL/login" \
  --data-urlencode "identity=$EMAIL" \
  --data-urlencode "password=$NEW_PASSWORD" \
  -c cookies.txt
