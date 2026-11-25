#!/usr/bin/env bash
set -euo pipefail

REQUIRED=(curl jq)
missing=()

echo "==> Checking required commands: ${REQUIRED[*]}"
for cmd in "${REQUIRED[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd found"
  else
    echo "[MISSING] $cmd not found"
    missing+=("$cmd")
  fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
  echo "==> All set. Nothing to install."
  exit 0
fi

echo "==> Need to install: ${missing[*]}"
echo "==> Detecting OS..."
OS="$(uname -s)"

case "$OS" in
  Darwin)
    echo "[OS] macOS detected -> using brew"
    command -v brew >/dev/null 2>&1 || { echo "[ERROR] Homebrew not found. Install from https://brew.sh"; exit 1; }
    echo "==> Installing: ${missing[*]}"
    brew install "${missing[@]}"
    ;;
  Linux)
    if command -v apt-get >/dev/null 2>&1; then
      echo "[OS] Linux (apt) detected"
      echo "==> Installing: ${missing[*]}"
      sudo apt-get update && sudo apt-get install -y "${missing[@]}"
    elif command -v dnf >/dev/null 2>&1; then
      echo "[OS] Linux (dnf) detected"
      echo "==> Installing: ${missing[*]}"
      sudo dnf install -y "${missing[@]}"
    elif command -v yum >/dev/null 2>&1; then
      echo "[OS] Linux (yum) detected"
      echo "==> Installing: ${missing[*]}"
      sudo yum install -y "${missing[@]}"
    elif command -v apk >/dev/null 2>&1; then
      echo "[OS] Linux (apk) detected"
      echo "==> Installing: ${missing[*]}"
      sudo apk add --no-cache "${missing[@]}"
    else
      echo "[ERROR] No supported package manager found (apt/dnf/yum/apk)."
      exit 1
    fi
    ;;
  *)
    echo "[ERROR] Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "==> Verifying installation..."
fail=0
for cmd in "${missing[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd installed successfully"
  else
    echo "[FAIL] $cmd still missing"
    fail=1
  fi
done

[[ $fail -eq 0 ]] && echo "==> Done. All prerequisites ready." || echo "==> Finished with errors."
exit "$fail"