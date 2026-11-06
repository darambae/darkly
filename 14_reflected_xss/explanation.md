# Reflected Cross-Site Scripting (XSS)

**Category:**
- OWASP A05:2025 – Injection
- WSTG-INPV-01 – Testing for Reflected Cross Site Scripting

**Location:**
- `http://localhost:4942/newsletter`
- Staff Area → Newsletter subscribers

**Discovery:**

The newsletter subscription form reflects user input without properly escaping HTML, allowing JavaScript to execute in the user's browser.

```
   <!-- wil: the "subscribed with: ___" banner echoes your email straight back. sophie: unescaped?? wil: define "unescaped". -->
   <!-- emilie: someone subscribed with a <script> tag last week. wil: bold of them. it worked.
```

**Steps to Reproduce:**

1. Navigate to the Newsletter subscription page. (Login not necessary)
2. Enter the following payload in the email field:

   ```html
   <script>alert(1)</script>
   ```

3. Submit the form.
4. Observe that a JavaScript alert displaying `1` appears immediately.
5. Sign in with a `staff` role account and navigate to **Staff Area → Staff Dashboard → Newsletter subscribers**.
6. Observe that the submitted payload is displayed as an email address, but the JavaScript alert does not execute.

**Flag:**

No flag discovered.

**Cause:**
- **Improper Output Encoding:** The newsletter confirmation message renders user input as executable HTML.
- **Reflected XSS:** JavaScript executes immediately when the subscription form is submitted.
- **Stored XSS Not Confirmed:** The payload is stored and displayed in the Staff Area, but no JavaScript execution was observed there.

**Remediation:**
- Validate email input on the server side.
- Continue safely escaping subscriber data in the Staff Area.
- Implement a restrictive Content Security Policy (CSP) as an additional defense.
