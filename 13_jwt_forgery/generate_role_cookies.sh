#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
USERS_FILE="${USERS_FILE:-$SCRIPT_DIR/Resources/users.json}"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/Resources}"
JWT_SECRET="42network"

if [[ ! -f "$USERS_FILE" ]]; then
  printf '[ERROR] Users JSON not found: %s\n' "$USERS_FILE" >&2
  exit 1
fi

mkdir -p -- "$OUTPUT_DIR"

USERS_FILE="$USERS_FILE" OUTPUT_DIR="$OUTPUT_DIR" JWT_SECRET="$JWT_SECRET" python3 - <<'PY'
import base64
import hashlib
import hmac
import json
import os
from pathlib import Path
import re
import time

users_path = Path(os.environ['USERS_FILE'])
out_dir = Path(os.environ['OUTPUT_DIR'])
secret = os.environ['JWT_SECRET'].encode('utf-8')

with users_path.open('r', encoding='utf-8') as f:
    users = json.load(f)

if not isinstance(users, list):
    raise SystemExit('[ERROR] users.json must be a JSON array')

# One representative account per role, preserving JSON order.
selected = {}
for user in users:
    if not isinstance(user, dict):
        raise SystemExit('[ERROR] Every user entry must be a JSON object')
    role = user.get('role')
    if not isinstance(role, str) or not re.fullmatch(r'[a-zA-Z0-9_-]+', role):
        raise SystemExit(f'[ERROR] Invalid role: {role!r}')
    for field in ('id', 'username'):
        if not isinstance(user.get(field), str) or not user[field]:
            raise SystemExit(f'[ERROR] Missing {field!r} in role {role!r}')
    selected.setdefault(role, user)


def b64url(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b'=').decode('ascii')


def compact_json(value: dict) -> str:
    return b64url(json.dumps(value, separators=(',', ':'), ensure_ascii=False).encode('utf-8'))


header = compact_json({'alg': 'HS256', 'typ': 'JWT'})
expiration = int(time.time()) + 3600

for role, user in selected.items():
    payload = compact_json({
        'sub': user['id'],
        'login': user['username'],
        'role': role,
        'exp': expiration,
    })
    signing_input = f'{header}.{payload}'
    signature = b64url(hmac.new(secret, signing_input.encode('ascii'), hashlib.sha256).digest())
    token = f'{signing_input}.{signature}'

    # Netscape cookie-jar format, usable with curl --cookie <path>.
    cookie_text = (
        '# Netscape HTTP Cookie File\n'
        '# Generated for a local Darkly security lab. Do not commit.\n'
        f'localhost\tFALSE\t/\tFALSE\t0\tsession\t{token}\n'
    )
    path = out_dir / f'{role}-cookie.txt'
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, 'w', encoding='utf-8') as handle:
        handle.write(cookie_text)
    os.chmod(path, 0o600)
    print(f'[+] {role:<12} {user["username"]:<16} -> {path}')

print(f'[+] Generated {len(selected)} role cookie file(s); expiry is one hour from generation.')
PY
