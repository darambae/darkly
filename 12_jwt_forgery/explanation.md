# JSON Web Tokens: Weak Signing Secret Enables JWT Forgery and User Impersonation

## Category

- **OWASP WSTG-SESS-10 — Testing JSON Web Tokens**
- **OWASP A07:2021 — Identification and Authentication Failures** (authentication compromise)
- **OWASP A02:2021 — Cryptographic Failures** (weak or exposed signing secret)

## Location

- Authentication cookie: `session` (JWT, `HS256`)
- Example authenticated read-only endpoint for validation: `api/profile`, `api/grades', etc

## Discovery
- `<!-- dorian: you can open anyone's /profile/<id> — the ids are in every link on the site. wil: privacy is a journey, not a destination. -->`
- `v1.2.0 — sophie  — initial platform. jwt secret was "42". wil changed it to "42network". progress."`
- A session JWT can be Base64URL-decoded to show claims such as `sub`, `login`, `role`, and `exp`. These claims are **not encrypted**, and this visibility alone is **not a vulnerability**.

However, when a token is created with another test user's known account information was accepted by the application. This indicates that either:

1. The attacker could sign the altered claims using a **known / weak / exposed HS256 secret**, or
2. The server **failed to validate the JWT signature** correctly.

These are different root causes and must not be confused. Encoding a new payload without a valid signature does not create a valid JWT in a correctly implemented system.

## Steps to Reproduce

   Run `./exploit.sh` (This script creates a jwt with an user's information and signing secret and send a POST request to change the role of the user as a cadet.)

## Flag

No specific flag has been confirmed for this finding.

## Root Cause

**Likely, if the exposed key was used:** A compromised HS256 signing key lets an attacker produce a JWT whose altered identity and role claims pass cryptographic verification. The use of predictable, hard-coded, or publicly exposed signing secrets breaks the trust model. The publicly visible claims are not the issue.

**Alternative, not yet proven:** The application accepts tokens even when their signatures are invalid (improper signature verification).

**Authorization impact:** If a forged token is accepted as another user, the server may process requests under that user's identity and permissions. This is impersonation and can lead to horizontal or vertical privilege escalation. It does **not** establish a separate role-update authorization bug.

## Remediation

- Generate a cryptographically strong, unpredictable signing key and keep it in a secrets manager; never hard-code or expose it in application responses.
- Rotate the compromised signing key and invalidate affected sessions; plan for operational impact.
- Verify the JWT signature with a trusted library and a **server-side allowlist of algorithms**; reject invalid, unsigned, or unexpectedly signed tokens.
- Validate `exp`, `nbf`, `iss`, and `aud` when applicable, plus application-specific claims.
- Treat `role` in a JWT as trusted only after verification; consider checking current permissions server-side for sensitive actions.
- Enforce server-side authorization for every resource and action, independent of a valid token.
- Use `HttpOnly`, `Secure`, and appropriate `SameSite` settings for session cookies (separate defense-in-depth findings).

## References

- OWASP WSTG — Testing JSON Web Tokens: https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/06-Session_Management_Testing/10-Testing_JSON_Web_Tokens
- OWASP Top 10 (2021) — Identification and Authentication Failures: https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/
- CWE-347 — Improper Verification of Cryptographic Signature: https://cwe.mitre.org/data/definitions/347.html
- CWE-321 — Use of Hard-coded Cryptographic Key: https://cwe.mitre.org/data/definitions/321.html
