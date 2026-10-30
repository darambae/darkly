
## Vulnerability N6: Missing HttpOnly Flag on Session Cookie

- **Category:**
  - OWASP A05:2021 – Security Misconfiguration
  - CWE-1004 – Sensitive Cookie Without 'HttpOnly' Flag
  - WSTG-SESS-02 – Testing for Cookies Attributes

- **Location:**
  - `http://localhost:4942/`
  - Session cookie: `session`

- **Discovery:**
  In the HTML source code, the following comment was found:

  "TODO: migrate session cookie to httponly=true — ticket #4201 — sophie"

  Additionally, the Staff Area platform status page explicitly reports:

  "Session cookie: httponly=false"

  These clues suggested that the authentication cookie was accessible through client-side JavaScript.

- **Steps to Reproduce:**
  1. Open Darkly at `http://localhost:4942/`.
  2. Sign in with a test account, such as `jdoe`.
  3. Open Chrome Developer Tools (F12).
  4. Navigate to the Console tab.
  5. Execute the following JavaScript:

     ```javascript
     document.cookie
     ```

  6. Observe that the response contains the `session` cookie with a JWT value.
  7. Navigate to Application → Cookies → `http://localhost:4942` and verify that the `HttpOnly` attribute is not enabled.

- **Flag:**
  No specific flag confirmed for this vulnerability.

- **Cause:**
  - **Missing Cookie Protection:** The server sets the authentication cookie without the `HttpOnly` attribute.
  - **JavaScript Accessibility:** Client-side JavaScript can read the session token through `document.cookie`.
  - **Increased XSS Impact:** A stored XSS vulnerability could allow malicious JavaScript to access the session token, potentially enabling session hijacking.

- **Remediation:**
  - **Enable HttpOnly:** Set the `HttpOnly` attribute on all authentication and session cookies.
  - **Enable Secure:** Set the `Secure` attribute when the application is served over HTTPS.
  - **Configure SameSite:** Use an appropriate `SameSite` policy, such as `Lax` or `Strict`, depending on application requirements.
  - **Prevent XSS:** Apply contextual output encoding, HTML sanitization where necessary, and a restrictive Content Security Policy.
  - **Session Management:** Use short-lived tokens, rotate session identifiers when appropriate, and invalidate sessions upon logout.
