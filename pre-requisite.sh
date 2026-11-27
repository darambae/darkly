#!/usr/bin/env bash
set -euo pipefail

REQUIRED=(bash curl jq python3 awk)
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

if command -v md5sum >/dev/null 2>&1; then
  echo "[OK] md5sum found"
elif command -v md5 >/dev/null 2>&1; then
  echo "[OK] md5 found"
else
  echo "[MISSING] Neither md5sum nor md5 found"
  missing+=(md5sum)
fi

if [[ ${#missing[@]} -eq 0 ]]; then
  echo "==> All set. Nothing to install."
  exit 0
fi

echo "==> Detecting OS..."
OS="$(uname -s)"
packages=()

for cmd in "${missing[@]}"; do
  case "$cmd" in
    md5sum)
      if [[ "$OS" == Linux ]]; then
        packages+=(coreutils)
      else
        echo "[ERROR] Neither md5sum nor md5 is available. Install one before running the exploits." >&2
        exit 1
      fi
      ;;
    python3)
      if [[ "$OS" == Darwin ]]; then
        packages+=(python)
      else
        packages+=(python3)
      fi
      ;;
    *) packages+=("$cmd") ;;
  esac
done

case "$OS" in
  Darwin)
    echo "[OS] macOS detected -> using brew"
    command -v brew >/dev/null 2>&1 || { echo "[ERROR] Homebrew not found. Install from https://brew.sh"; exit 1; }
    echo "==> Installing: ${packages[*]}"
    brew install "${packages[@]}"
    ;;
  Linux)
    if [[ $EUID -eq 0 ]]; then
      privilege=()
    elif command -v sudo >/dev/null 2>&1; then
      privilege=(sudo)
    else
      echo "[ERROR] Package installation requires root or sudo." >&2
      exit 1
    fi

    if command -v apt-get >/dev/null 2>&1; then
      echo "[OS] Linux (apt) detected"
      echo "==> Installing: ${packages[*]}"
      "${privilege[@]}" apt-get update
      "${privilege[@]}" apt-get install -y "${packages[@]}"
    elif command -v dnf >/dev/null 2>&1; then
      echo "[OS] Linux (dnf) detected"
      echo "==> Installing: ${packages[*]}"
      "${privilege[@]}" dnf install -y "${packages[@]}"
    elif command -v yum >/dev/null 2>&1; then
      echo "[OS] Linux (yum) detected"
      echo "==> Installing: ${packages[*]}"
      "${privilege[@]}" yum install -y "${packages[@]}"
    elif command -v apk >/dev/null 2>&1; then
      echo "[OS] Linux (apk) detected"
      echo "==> Installing: ${packages[*]}"
      "${privilege[@]}" apk add --no-cache "${packages[@]}"
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
for cmd in "${REQUIRED[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd found"
  else
    echo "[FAIL] $cmd missing"
    fail=1
  fi
done

[[ $fail -eq 0 ]] && echo "==> Done. All prerequisites ready." || echo "==> Finished with errors."
exit "$fail"
