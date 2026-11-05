#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: GET /profile/z4p1cnx47mfy50f
USER_ID="$(get_user_field id)"
REQUEST_PATH="/profile/$USER_ID"
run_curl \
    --request \
    GET \
    "$BASE_URL$REQUEST_PATH"
