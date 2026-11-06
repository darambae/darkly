# Sensitive Information Disclosure: PocketBase Administrator Credentials

## Category

- **OWASP Top 10 (2021):** A05 – Security Misconfiguration
- **CWE-200:** Exposure of Sensitive Information to an Unauthorized Actor


## Locations

- Configuration exposed through XXE: `http://127.0.0.1:4942/internal/config`
- PocketBase administration interface: `http://localhost:8090/_/`
- PocketBase administrator authentication API: `POST http://localhost:8090/api/admins/auth-with-password`
- PocketBase collections: `users` and `internal_audit`
- Darkly staff dashboard: `http://localhost:4942/staff/dashboard`

## Discovery

Exploiting the calendar XML import XXE vulnerability granted access to the restricted `/internal/config` endpoint. The response exposed a JWT signing secret and valid PocketBase administrator credentials in plaintext.

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

## Flags
 `FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}`

## Root Cause

- Insecure XML Parsing: The calendar import allowed external entity resolution (XXE).
- Exposed Internal Configuration: The /internal/config route returned sensitive administrative secrets without authentication, relying solely on weak network boundaries (127.0.0.1).

## Impact

- Full compromise of the PocketBase administrative interface and backend database.
- Exposure of critical JWT signing secrets and reusable administrator credentials.
- Unauthorized user role manipulation (student to god) and access to restricted audit records.

## Remediation

- **Harden XML Parsing:** Use secure parsers (e.g., defusedxml) and disable DTDs/external entity resolution.
- **Secure Configuration Management:** Remove credentials and signing secrets from application endpoints; utilize secure runtime secret stores.
- **Credential Rotation:** Immediately rotate exposed administrator passwords and JWT secrets, and invalidate active sessions.
- **Access Control:** Restrict administrative interfaces to trusted networks and operators with strong authentication.
