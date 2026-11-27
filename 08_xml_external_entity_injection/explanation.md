# XML External Entity Injection

## Category

- **OWASP A02:2025 – Security Misconfiguration**
- **WSTG-INPV-07 – Testing for XML Injection**
- **CWE-611 – Improper Restriction of XML External Entity Reference**

## Location

- Calendar XML import functionality
- Internal endpoint: `http://localhost:4942/internal/config`

## Discovery

`"TODO: replace stdlib xml.etree with defusedxml — emilie reported issue"
"NOTE: /internal/config restricted to localhost only. do not expose."`

These comments suggested that XML parsing was insufficiently secured and that an internal configuration endpoint could potentially be accessed through an XXE-based SSRF.

## Steps to Reproduce

Run `exploit.sh`. (This script will upload the prepared xml file`Resources/agenda_xxe.xml` in `/agenda` which injects an external entity sending GET request to `/internal/config`. If the request is successful, the script will find the flag in the response.)

Or follow the steps to reproduce manually :

1. Login and navigate to the calendar XML import functionality('http://localhost:4942/agenda/import')
2. Upload `Resources/agenda_xxe.xml` using the calendar import form.
3. Observe that the XML parser resolves the external entity and retrieves the internal configuration.
4. The imported event displays the configuration data, including `jwt_secret`, PocketBase administrator credentials, and the flag.

## Flag

`FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}`

## Impact

The XML import can disclose internal configuration, including credentials, signing secrets, and the recorded flag.

## Cause

- **Unsafe XML Parsing:** The XML import functionality allows external entities to be resolved.
- **Server-Side Request Forgery:** The XML parser can make HTTP requests to internal services using attacker-controlled URLs.
- **Insufficient Access Control:** The `/internal/config` endpoint relies on localhost restrictions rather than robust authorization.
- **Sensitive Data Exposure:** The internal endpoint returns sensitive credentials and signing secrets.

## Remediation

- **Secure XML Parsing:** Explicitly disable DTDs and external entity resolution.
- **Restrict XML-Initiated Requests:** Reject external XML references. Where outbound requests are required for other features, allow only explicitly approved destinations and restrict unnecessary network access.
- **Protect Internal Endpoints:** Require authentication and authorization for `/internal/config`; do not rely on loopback access alone or return secrets that callers do not need.
- **Validate XML and Limit Resources:** Enforce the expected agenda structure and values after secure parsing; limit upload size and parser resource use before processing.