#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BASE_URL="${BASE_URL:-http://localhost:4942}"
COOKIE_JAR="../03_Weak_Password_Change_or_Reset_Functionalities/cookies.txt"
USERS_FILE="${USERS_FILE:-$SCRIPT_DIR/Resources/users.json}"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/Resources}"
JWT_SECRET="${JWT_SECRET:-42network}"

mkdir -p -- "$(dirname -- "$USERS_FILE")" "$OUTPUT_DIR"
FETCHED_FILE="$(mktemp "${USERS_FILE}.tmp.XXXXXX")"
trap 'rm -f -- "$FETCHED_FILE"' EXIT

echo "[*] Fetching users from $BASE_URL/api/users"
curl --fail --silent -L --show-error \
    -b "$COOKIE_JAR" \
    --output "$FETCHED_FILE" \
    "$BASE_URL/api/users"
echo
echo "[*] Generating JWT cookies for each role in $OUTPUT_DIR"
FETCHED_FILE="$FETCHED_FILE" USERS_FILE="$USERS_FILE" OUTPUT_DIR="$OUTPUT_DIR" JWT_SECRET="$JWT_SECRET" python3 - <<'PY'
import base64, hashlib, hmac, json, os, re, time
from pathlib import Path

fetched_path = Path(os.environ["FETCHED_FILE"])
users_path = Path(os.environ["USERS_FILE"])
out_dir = Path(os.environ["OUTPUT_DIR"])
secret = os.environ["JWT_SECRET"].encode()

users = json.loads(fetched_path.read_text(encoding="utf-8"))
if not isinstance(users, list) or not users:
    raise SystemExit("[ERROR] /api/users must return a non-empty JSON array")

def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()

def encode(obj: dict) -> str:
    return b64url(json.dumps(obj, separators=(",", ":")).encode())

def validate(user: dict) -> str:
    role = user.get("role", "")
    if not re.fullmatch(r"[a-zA-Z0-9_-]+", role):

        raise SystemExit(f"[ERROR] Invalid role: {role!r}")
    for field in ("id", "username"):
        if not user.get(field):
            raise SystemExit(f"[ERROR] Missing {field!r} for role {role!r}")
    return role

selected = {}
for user in users:
    role = validate(user)
    selected.setdefault(role, user)

fetched_path.replace(users_path)
print(f"[+] Saved {len(users)} users to {users_path}")

header = encode({"alg": "HS256", "typ": "JWT"})
exp = int(time.time()) + 3600

for role, user in selected.items():
    payload = encode({"sub": user["id"], "login": user["username"], "role": role, "exp": exp})
    signing_input = f"{header}.{payload}"
    signature = b64url(hmac.new(secret, signing_input.encode(), hashlib.sha256).digest())
    token = f"{signing_input}.{signature}"

    cookie_file = out_dir / f"{role}-cookie.txt"
    cookie_file.write_text(
        "# Netscape HTTP Cookie File\n"
        f"localhost\tFALSE\t/\tFALSE\t0\tsession\t{token}\n",
        encoding="utf-8",
    )
    cookie_file.chmod(0o600)
    print(f"[+] {role:<12} {user['username']:<16} -> {cookie_file}")

print(f"[COMPLETED] Generated {len(selected)} role cookie file(s); expires in 1 hour.")
PY
echo