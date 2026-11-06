# XML External Entity Injection

## Category
  - OWASP A05:2021 – Security Misconfiguration
  - WSTG-INPV-07 – Testing for XML Injection
  - CWE-611 – Improper Restriction of XML External Entity Reference

## Location
  - Calendar XML import functionality
  - Internal endpoint: `/internal/config`

## Discovery
  In the HTML source code, the following comments were found:

  "TODO: replace stdlib xml.etree with defusedxml — emilie reported issue"
  "NOTE: /internal/config restricted to localhost only. do not expose."

  These comments suggested that XML parsing was insufficiently secured and that an internal configuration endpoint could potentially be accessed through an XXE-based SSRF.

## Steps to Reproduce
  1. Login and Navigate to the calendar XML import functionality("http://localhost:4942/agenda")
  2. Upload `./agenda_xxe.xml` using the calendar import form.
  3. Observe that the XML parser resolves the external entity and retrieves the internal configuration.
  4. The imported event displays the configuration data, including `jwt_secret`, PocketBase administrator credentials, and the flag.

## Flag
 `FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}`

## Cause
  - **Unsafe XML Parsing:** The XML import functionality allows external entities to be resolved.
  - **Server-Side Request Forgery:** The XML parser can make HTTP requests to internal services using attacker-controlled URLs.
  - **Insufficient Access Control:** The `/internal/config` endpoint relies on localhost restrictions rather than robust authorization.
  - **Sensitive Data Exposure:** The internal endpoint returns sensitive credentials and signing secrets.

## Remediation
  - **Secure XML Parsing:** Use `defusedxml` and explicitly disable DTDs and external entity resolution.
  - **Restrict Internal Requests:** Prevent untrusted input from causing requests to internal or loopback addresses.
  - **Protect Internal Endpoints:** Require appropriate authentication and authorization for sensitive configuration endpoints.
  - **Secrets Management:** Store credentials securely, avoid exposing them through application responses, and rotate any compromised secrets.
  - **Input Validation:** Validate the expected XML structure and impose file-size and processing limits.
