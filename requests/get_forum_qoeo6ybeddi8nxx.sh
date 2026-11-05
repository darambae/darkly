#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: GET /forum/qoeo6ybeddi8nxx
REQUEST_PATH=/forum/qoeo6ybeddi8nxx
run_curl \
    --request \
    GET \
    "$BASE_URL$REQUEST_PATH"
