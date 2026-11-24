# Testing for Cross Site Request Forgery (CSRF)

## Category

- OWASP WSTG-SESS-05 — Testing for Cross Site Request Forgery
- CWE-352 — Cross-Site Request Forgery
- OWASP A01:2021 — Broken Access Control

## Location

- `POST /profile/me/settings`

## Discovery

The profile settings endpoint accepted an authenticated POST request containing an arbitrary external `Origin` header without requiring a CSRF token.

Using curl, a valid session cookie was supplied alongside the modified Origin and profile fields. The server returned a redirect containing the CSRF challenge flag.

After refreshing the profile page, the submitted changes were confirmed to have persisted.

## Steps to Reproduce

1. Sign in with a test account and save its valid `session` cookie.
2. Send `POST /profile/me/settings` with that cookie, profile fields, and an external `Origin` header, as shown in [`exploit.sh`](exploit.sh).
3. Observe the redirect containing the challenge flag, then refresh the profile page and confirm the changes persisted.

## Flag

`FLAG{csrf_4ny_0r1g1n_1s_w3lc0m3}`

## Impact

The endpoint accepts a state-changing request with a forged `Origin` when a valid cookie is supplied manually. A conventional cross-site browser exploit was not established because the tested browser withheld the `SameSite=Lax` cookie.

The session cookie uses `SameSite=Lax`, which prevented its automatic inclusion during a cross-site POST initiated from a separate site in the tested browser.

Therefore, the curl reproduction demonstrates insufficient server-side CSRF validation, but does not independently establish that a conventional cross-site browser attack succeeds.

## Cause

The endpoint lacks effective server-side CSRF protection for the tested request. It accepted an authenticated state-changing request without validating the untrusted Origin or requiring a CSRF token.

## Remediation

- Implement server-side CSRF token verification for state-changing requests.
- Validate the `Origin` header, with appropriate `Referer` fallback handling.
- Retain `SameSite=Lax` or `Strict` as an additional protective layer.
- Ensure that GET endpoints do not perform state-changing operations.

## Evidence

- [exploit.sh](exploit.sh)
