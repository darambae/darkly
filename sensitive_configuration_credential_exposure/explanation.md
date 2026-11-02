# Security Misconfiguration — Sensitive Configuration and Credential Exposure

## Category
- **OWASP Top 10 (2021):** A05 — Security Misconfiguration
- **CWE:** CWE-200 — Exposure of Sensitive Information
- **Related issue:** Insufficient protection of privileged credentials and signing secrets

## Location
- Internal configuration endpoint: `/internal/config` on `http://localhost:4942`
- The vulnerable XML import at `/agenda` is the **confirmed access path** to this endpoint (see [Finding 01](01_XML_Injection_XXE.md)).

## Discovery
The XML import vulnerability allowed the application to fetch `/internal/config` and display its response in an imported event. The response included a PocketBase administrator email and plaintext password, a JWT signing secret, and other internal configuration values.

The response headers also exposed the backend location:

```http
x-pocketbase: http://localhost:8090
```

This header alone is an information disclosure clue; it does not prove administrator access.

## Steps to Reproduce
1. Perform Finding 01's calendar import using `./xml_external_entity_injection/agenda_xxe.xml`.
2. Examine the event containing the returned `/internal/config` data.
3. Confirm that the response includes the following **redacted** fields:

```json
{
  "jwt_secret": "[REDACTED]",
  "pb_admin_email": "admin@42network.local",
  "pb_admin_password": "[REDACTED]",
  "app_version": "1.0.0",
  "campus": "wilcity",
  "darkly_flag": "[SEE FINDING 01]"
}
```

4. Record evidence of the disclosure without placing the actual password or signing secret in the Markdown report.

## Observed Result
An internal configuration response containing valid privileged credentials was made visible to a user who could access the XML import functionality. The credentials were later accepted by the PocketBase administrator authentication API (see [Attack Chain 03](03_Testing_for_Privilege_Escalation_Attack_Chain.md)).

## Root Cause
Sensitive runtime configuration was returned by an application endpoint, including privileged credentials in plaintext. The documented localhost-only restriction was not a sufficient protective boundary once another application feature could be induced to request the endpoint.

## Impact
- Disclosure of PocketBase administrator credentials and the JWT signing secret.
- Potential compromise of administrative operations and any authentication flows relying on the exposed signing secret; JWT token forgery was **not** demonstrated by the original evidence.
- Enables the privilege-escalation attack chain documented in Finding 03.

## Dependency / Scope
This finding is **distinct in root cause** from the XML parser flaw, because eliminating the credential-bearing response is necessary even if XXE is fixed. However, **direct unauthenticated access to `/internal/config` was not demonstrated**; exploitation in the supplied report depends on Finding 01. Do not score it as a separately reachable unauthenticated endpoint without an additional test.

## Remediation
- Do not expose administrative credentials, signing secrets, or other sensitive runtime values in application responses.
- Store secrets in an appropriate secrets-management system and restrict access by service identity and least privilege.
- Rotate exposed PocketBase credentials and JWT signing secrets; assess whether existing sessions or tokens must be invalidated.
- Enforce authentication and authorization on internal diagnostic/configuration endpoints, or remove them from production deployments.
- Apply network restrictions as defense in depth; do not rely only on the caller being `localhost`.
- Add response filtering and tests verifying that internal configuration endpoints never return secrets.

## Reference
- OWASP Top 10 (2021) — [A05: Security Misconfiguration](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE-200: Exposure of Sensitive Information](https://cwe.mitre.org/data/definitions/200.html)
