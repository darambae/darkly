#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: GET /login
REQUEST_PATH=/login
run_curl \
    --request \
    GET \
    "$BASE_URL$REQUEST_PATH"
