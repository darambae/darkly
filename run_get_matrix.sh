#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$DIR/results"
for role in guest student cadet staff god; do
  for script in "$DIR"/requests/get_*.sh; do
    name="$(basename "$script" .sh)"
    file="$DIR/results/${role}_${name}.txt"
    if ROLE="$role" "$script" > "$file" 2>&1; then
      status="$(awk '/^HTTP\//{code=$2} END{print code}' "$file")"
      printf '%-8s %-44s %s\n' "$role" "$name" "${status:-unknown}"
    else
      printf '%-8s %-44s %s\n' "$role" "$name" "SKIPPED/ERROR"
    fi
  done
done
