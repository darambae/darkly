# Open Redirect via Unvalidated URL Parameter

## Category
- OWASP A01:2025 – Broken Access Control
- CWE-601 – URL Redirection to Untrusted Site
- OWASP WSTG – Testing for Server-side URL Redirect

## Location
- `http://localhost:4942/redirect?next=`

## Discovery

The `/redirect` endpoint accepts a user-controlled `next` parameter and redirects the browser to an external website without restricting the destination to trusted URLs.

## Steps to Reproduce

1. Open the following URL:

   `http://localhost:4942/redirect?next=https://example.com`

2. Observe that the server responds with `307 Temporary Redirect`.
3. Inspect the `Location` response header.
4. Confirm that the browser is redirected to `https://example.com`.

## Flag

No flag discovered.

## Cause
- **Unvalidated Redirect:** The application uses the user-provided `next` parameter as the redirect destination without sufficient validation.

## Impact
- Attackers can redirect users from a trusted website to an external website.
- This behavior can facilitate phishing attacks.

## Remediation
- Use an allowlist of trusted redirect destinations.
- Prefer predefined internal paths instead of accepting arbitrary URLs.
- Reject untrusted external URLs.