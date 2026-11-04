# Sensitive Information Disclosure: PocketBase Administrator Credentials

## Classification

- **OWASP Top 10 (2021):** A05 – Security Misconfiguration
- **CWE-200:** Exposure of Sensitive Information to an Unauthorized Actor
- **Verified impact:** Compromise of PocketBase administrator access and application-level privilege escalation

The privilege escalation documented here is the verified impact of the exposed administrator credentials. It is not counted as a separate authorization vulnerability because the role modification was performed with a valid PocketBase administrator identity.

## Locations

- Configuration exposed through XXE: `http://127.0.0.1:4942/internal/config`
- PocketBase administration interface: `http://localhost:8090/_/`
- PocketBase administrator authentication API: `POST http://localhost:8090/api/admins/auth-with-password`
- PocketBase collections: `users` and `internal_audit`
- Darkly staff dashboard: `http://localhost:4942/staff/dashboard`

## Discovery

The previously documented calendar-import XXE allowed the server to request the localhost-only `/internal/config` endpoint. Its response disclosed a JWT signing secret and PocketBase administrator credentials. Response headers also identified the PocketBase service at `http://localhost:8090`.

Authentication through the PocketBase administrator interface and legacy authentication API confirmed that the disclosed credentials were valid.

## Steps to Reproduce

1. Reproduce the [XML External Entity Injection](../06_xml_external_entity_injection/explanation.md) and retrieve `/internal/config` through the calendar import.
2. Observe that the configuration includes a JWT secret and PocketBase administrator credentials. Record evidence with the secret values redacted:

   ```json
   {
     "jwt_secret": "[REDACTED]",
     "pb_admin_email": "admin@42network.local",
     "pb_admin_password": "[REDACTED]",
     "app_version": "1.0.0",
     "campus": "wilcity",
     "darkly_flag": "FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}"
   }
   ```

3. Open `http://localhost:8090/_/` and authenticate with the disclosed administrator credentials. Alternatively, send `POST /api/admins/auth-with-password` with the `identity` and `password` fields. The observed API response was `200 OK` and included an administrator token.
4. In the PocketBase `users` collection, locate the test account `jdoe` and change its role from `student` to `god`.
5. Confirm that Darkly recognizes the updated role and permits access to the staff dashboard.
6. Open the `internal_audit` collection and find the record containing `god-tier export OK — flag retained for the security audit:`.

## Observed Result

- The internal configuration exposed reusable administrator credentials and a signing secret.
- The disclosed credentials successfully authenticated to PocketBase.
- PocketBase administrator access allowed `jdoe`'s role to be changed from `student` to `god`.
- Darkly trusted the backend role and granted the updated account staff-level access.
- The administrator could access a protected audit record containing the impact flag.

## Flags : `FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}`

## Root Cause and Trust Boundary

The entry point was unsafe external-entity resolution in the calendar XML parser. The internal configuration endpoint then returned reusable secrets while relying on a localhost-only network boundary. Once the valid PocketBase administrator identity was compromised, administrative role changes and access to protected collections were expected capabilities of that identity.

Therefore, the observed `student → god` change proves the severity of the credential disclosure. It does not prove that PocketBase incorrectly authorized the administrator's action. The separately documented mass-assignment finding demonstrates an independent authorization flaw in which a regular user can change their own role to `cadet`.

## Impact

- Compromise of the PocketBase administrative interface and API.
- Exposure of a JWT signing secret and reusable administrator credentials.
- Modification of application user roles.
- Access to privileged application data and internal audit records.

## Remediation

- Fix the XXE entry point by rejecting DTDs and external entities and using a hardened XML parser such as `defusedxml`.
- Do not return credentials or signing secrets from application configuration endpoints.
- Move secrets to a dedicated secret store and inject them at runtime.
- Rotate the exposed administrator password and signing secret, then revoke affected tokens and sessions.
- Restrict the PocketBase administration service to authorized operators and networks and enable stronger administrator authentication where supported.
- Use least-privileged service identities for routine application operations.
- Require server-side authorization and audit logging for role changes and protected collections.
