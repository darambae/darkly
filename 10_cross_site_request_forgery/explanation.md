### Testing for Cross Site Request Forgery (CSRF)

**Category:**
- OWASP WSTG-SESS-05 — Testing for Cross Site Request Forgery
- CWE-352 — Cross-Site Request Forgery
- OWASP A01:2021 — Broken Access Control

**Location:**
- `POST /profile/me/settings`

**Discovery:**

The profile settings endpoint accepted an authenticated POST request containing an arbitrary external `Origin` header without requiring a CSRF token.

Using curl, a valid session cookie was supplied alongside the modified Origin and profile fields. The server returned a redirect containing the CSRF challenge flag.

After refreshing the profile page, the submitted changes were confirmed to have persisted.

**Flag:** `FLAG{csrf_4ny_0r1g1n_1s_w3lc0m3}`

**Root Cause:**

The endpoint lacks effective server-side CSRF protection for the tested request. It accepted an authenticated state-changing request without validating the untrusted Origin or requiring a CSRF token.

**Browser-Level Limitation:**

The session cookie uses `SameSite=Lax`, which prevented its automatic inclusion during a cross-site POST initiated from a separate site in the tested browser.

Therefore, the curl reproduction demonstrates insufficient server-side CSRF validation, but does not independently establish that a conventional cross-site browser attack succeeds.

**Remediation:**

- Implement server-side CSRF token verification for state-changing requests.
- Validate the `Origin` header, with appropriate `Referer` fallback handling.
- Retain `SameSite=Lax` or `Strict` as an additional protective layer.
- Ensure that GET endpoints do not perform state-changing operations.