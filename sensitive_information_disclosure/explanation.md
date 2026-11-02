# Sensitive Information Disclosure: PocketBase Administrator Credentials

- **Category:**
  - OWASP A01:2021 – Broken Access Control (resulting privilege escalation)
  - OWASP A05:2021 – Security Misconfiguration (exposed internal configuration)
  - CWE-269 – Improper Privilege Management
  - CWE-200 – Exposure of Sensitive Information

- **Location:**
  - PocketBase administration interface: `http://localhost:8090/_/`
  - PocketBase administrator authentication API: `POST http://localhost:8090/api/admins/auth-with-password`

- **Discovery:**
  The previous XXE vulnerability allowed the internal `/internal/config` endpoint to be read through the calendar XML import feature. Its response disclosed PocketBase administrator credentials. The response headers also identified a PocketBase backend at `http://localhost:8090`. Testing the PocketBase administration interface and the legacy administrator authentication endpoint confirmed that the disclosed credentials were valid.

- **Steps to Reproduce:**
  1. Exploit the previously documented calendar XML XXE vulnerability to retrieve the configuration from `/internal/config`.
  2. Identify the PocketBase administrator email and password in the configuration response. Do not include the actual password in the report.
   `{"jwt_secret":"42network","pb_admin_email":"admin@42network.local","pb_admin_password":"Darkly42Admin!","app_version":"1.0.0","campus":"wilcity","darkly_flag":"FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}"}`
  3. Open `http://localhost:8090/_/` and sign in with those administrator credentials. Alternatively, send a `POST` request to `http://localhost:8090/api/admins/auth-with-password` with a JSON body containing `identity` and `password`. The observed API response was `200 OK` and included an administrator token.
  4. In the PocketBase administration interface, open the users collection and locate the test account `jdoe`.
  5. Change the `role` field of `jdoe` from `student` to `god` and save the record.
  6. Go to `internal_audit` collection
  7. Find a record with a note with the flag : `god-tier export OK — flag retained for the security audit:`.

- **Flag:** `FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}`

- **Cause:**
  - **Credential Exposure:** The internal configuration endpoint contained valid PocketBase administrator credentials and was reachable through an XXE-based SSRF.
  - **Privileged Backend Access:** The exposed credentials allowed authentication to PocketBase's administrative interface and API.
  - **Privilege Modification:** Administrative access permitted modification of the user's `role` field in the backend database.
  - **Trust in Backend Role:** Darkly subsequently recognized the modified role and granted access to the staff dashboard. This demonstrates the impact of the compromised administrative credentials; it does not, by itself, prove that PocketBase's role-update authorization was defective.

- **Remediation:**
  - **Eliminate the XXE Entry Point:** Use secure XML parsing (`defusedxml`), prohibit external entity resolution, and enforce input limits.
  - **Protect Configuration and Secrets:** Do not expose administrative credentials through application endpoints; use a dedicated secrets-management mechanism and rotate compromised credentials.
  - **Restrict Administrative Access:** Limit PocketBase administrative access to authorized operators, enforce strong authentication, and apply network restrictions where appropriate.
  - **Apply Least Privilege:** Avoid using broadly privileged administrator credentials for routine application operations.
  - **Harden Role Management:** Require explicit authorization and audit logging for role changes, and prevent ordinary users from changing their own privilege level.
  - **Validate Effective Permissions:** Test server-side authorization for staff and administrator endpoints, independently of client-side UI visibility.
