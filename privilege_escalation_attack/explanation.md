# Testing for Privilege Escalation — Compromised PocketBase Administrator Attack Chain

## Classification
- **OWASP WSTG v4.2:** WSTG-ATHZ-03 — Testing for Privilege Escalation
- **OWASP Top 10 (2021):** A01 — Broken Access Control (**impact category**, not a separately demonstrated authorization bypass)
- **Type:** Attack-chain demonstration / verified impact of Findings 01 and 02

> **Important distinction:** This report documents successful privilege escalation *after obtaining valid administrator credentials*. It does **not** establish that PocketBase incorrectly authorized a role update or that an ordinary user could self-elevate privileges. Treat this as a chained exploitation result, not a third independent root-cause vulnerability, unless further evidence proves a separate authorization flaw.

## Locations
- PocketBase administration UI: `http://localhost:8090/_/`
- PocketBase legacy administrator authentication API: `POST http://localhost:8090/api/admins/auth-with-password`
- PocketBase `users` collection and `internal_audit` collection
- Darkly staff dashboard (access observed after role change)

## Steps to Reproduce
1. Use the calendar XML import to retrieve the redacted configuration evidence from `/internal/config` as documented in Findings 01 and 02.
2. In the **authorized local 42 Darkly environment**, use the recovered administrator credentials to sign in at `http://localhost:8090/_/`.
3. Alternatively, authenticate using `POST /api/admins/auth-with-password` with JSON fields `identity` and `password`. The original test returned `200 OK` with an administrator token. 
4. Open the PocketBase `users` collection and locate the test account `jdoe`.
5. Update `jdoe`'s `role` from `student` to `god`, then save the record.
6. Confirm that the updated role is recognized by Darkly and permits staff-dashboard access.
7. Open the `internal_audit` collection and find the record containing the note `god-tier export OK — flag retained for the security audit:`.

## Observed Result
- The disclosed credentials authenticated successfully to PocketBase's privileged interface/API.
- A PocketBase administrator could change the `jdoe` role to `god`.
- Darkly recognized the changed role and granted staff-level access.
- A privileged audit record containing a flag was accessible.

## Flag
`FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}`

## Root Cause / Trust Boundary
The **demonstrated entry-point defect** is the XXE, combined with **sensitive credential disclosure**. Once a valid PocketBase administrator identity was compromised, the attacker could perform privileged administrative actions. Administrator ability to edit roles is not by itself proof of faulty access control.

## Impact
- Compromise of backend administrator privileges.
- Modification of user roles and escalation of application-level privileges (`student` → `god`).
- Access to internal audit data reserved for privileged users.

## Remediation
- Fix the XXE entry point and stop returning credentials from `/internal/config` (Findings 01 and 02).
- Rotate disclosed administrator credentials and signing secrets, revoke relevant tokens/sessions as needed, and review administrative audit logs.
- Restrict PocketBase administrative interfaces to authorized operators and networks; consider MFA where supported by the deployment.
- Use least-privileged service identities for routine backend operations.
- Require server-side authorization for role modifications and protect privileged collections from non-administrator users.
- Log and alert on privileged role modifications; test whether a non-admin user can update their own role directly.

## Additional Testing Needed to Claim Independent Broken Access Control
- Attempt a role change while authenticated only as a regular user, without PocketBase admin credentials.
- Verify that protected endpoints independently check authorization and do not rely solely on UI visibility.
- Check that stale sessions/tokens do not retain improper access after a role is reduced.

A successful regular-user role update or unauthorized privileged data access would justify a separate Broken Access Control finding. That result is **not part of the supplied evidence**.
