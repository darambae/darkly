# Authentication Failures

## Category

- **OWASP A07:2025 – Authentication Failures.**
- OWASP A06:2025 – Insecure Design.
- WSTG-ATHN-09 – Weak Password Change or Reset Functionalities.
- CWE-640 – Weak Password Recovery Mechanism for Forgotten Password.

## Location

`http://localhost:4942/reset-password`

## Discovery

In the Benjamin's post on Forum, he gave a hint about resetting passwords.
`http://localhost:4942/forum/r8y1ib6ub8g47u2`
`"Locked myself out last night and used the password reset. The link worked instantly — no email, "`

## Steps to Reproduce

1. Go to http://localhost:4942/reset-password
2. give one the student email (benjamin@student.42.tech for example)
3. enter a new password, validate and login with this email and new password

Alternatively, run `./exploit.sh`.

## Impact

If the password reset authorization is provided directly to an unverified requester, the recovery mechanism no longer establishes account ownership.

This may result in unauthorized password changes, account takeover and loss of access for the legitimate account owner.

## Cause

The password recovery workflow fails to enforce an independent verification step before authorizing the password change.

This weakness is distinct from predictable reset token generation: even a cryptographically secure random token would not protect the account if it were directly disclosed to an unverified requester.

## Remediation

- **Out-of-Band Verification:** Deliver password reset tokens exclusively through a verified recovery channel, such as the registered email address.
- **Server-Side Validation:** Require a valid reset token associated with the account before accepting any password modification.
- **Token Confidentiality:** Never disclose valid reset tokens in responses to unauthenticated password reset requests.
- **Single-Use & Short-Lived:** Enforce token expiration and invalidate tokens immediately after successful use.
- **Generic Responses:** Return a generic confirmation message after a password reset request to prevent account enumeration.
