# Insecure Direct Object References: private profile note

## Category

OWASP WSTG-ATHZ-04, Insecure Direct Object References.
OWASP Top 10 A01:2021, Broken Access Control.

## Location

`http://localhost:4942/profile/k1asdfeditojrb4`

## Discovery

The site links to `wil`'s profile from a conversation. The profile identifier is visible in those links.

## Steps to Reproduce

1. Without logging in, go to wil's posting (http://localhost:4942/forum/bbeo32ucx0a65b8)
2. Follow the link to `wil`'s profile, or visit the URL above.
3. Observe that the response includes `wil`'s private note

## Flag

`FLAG{1d0r_ur_pr0f1l3_1s_m1n3}`

## Impact

A user can read a private note belonging to another account.

## Cause

The profile response exposes data without enforcing ownership of the private note. The profile ID identifies the record but must not grant permission to read private fields.

## Remediation

Authorize each field server side against the active user before returning it. Keep public profile data separate from private notes and test requests made from other accounts.

