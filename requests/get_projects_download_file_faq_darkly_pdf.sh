#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
# Source: Burp export: GET /projects/download?file=faq_darkly.pdf
REQUEST_PATH='/projects/download?file=faq_darkly.pdf'
run_curl \
    --request \
    GET \
    "$BASE_URL$REQUEST_PATH"
