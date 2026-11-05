# Cryptographic Failures: Insecure Storage of Password-Derived MD5 Hashes

## Category

- **OWASP A02:2021 — Cryptographic Failures** (exposure of a fast, unsalted password-derived hash)
- **OWASP A07:2021 — Identification and Authentication Failures** (risk of account compromise through weak passwords)

## Location

- PocketBase `users` collection, field: `pw_hint`
- PocketBase administration interface: `http://localhost:8090/_/`

## Discovery

The `benjamin` account was inspected in PocketBase:

- Username: `benjamin`
- Confirmed initial password: `b3njamin!`
- Observed `pw_hint`: `d7b3e05e072dbee908fdc39db9ab16d7`
- Calculated `MD5("b3njamin!")`: `d7b3e05e072dbee908fdc39db9ab16d7`

The values **match exactly**, confirming that **for this account**, `pw_hint` contains an unsalted MD5 digest of the password.

A subsequent password change also caused the `pw_hint` field to **change**. This supports the conclusion that the field tracks the password rather than containing a static historical hint. The exact implementation of the update process has not been inspected.

**Scope of evidence:** The MD5 relationship has been verified for `benjamin`. It has not yet been individually verified for every account. The field was observed through PocketBase administration; this alone does **not** prove that a guest or ordinary student can read other users' `pw_hint` values.

## Steps to Reproduce

1. Reset an user's password to `abc123`
2. Open the PocketBase admin interface at `http://localhost:8090/_/` using the lab's authorized administrator access.
3. Navigate to the `users` collection and locate the user's record.
4. Record the `pw_hint` value.
5. Compute the MD5 digest of the known initial lab password:

   ```bash
   # macOS
   printf '%s' 'abc123' | md5 -q

   # Linux
   printf '%s' 'abc123' | md5sum
   ```

6. Compare the result to `pw_hint`. The values match.

## Flag 
   No flag was found 

## Root Cause
- **Weak Password Hint Storage:** The application stores an unsalted MD5 hash derived from the user's password in the pw_hint field.
MD5 is fast and predictable. If this hash is exposed, an attacker may be able to guess weak passwords by comparing MD5 hashes of common password candidates.

- **Potential Information Disclosure:** The pw_hint field was found in the PocketBase users collection using administrator access. It has not been confirmed whether regular users can access this field.
Therefore, this finding demonstrates insecure storage of password-derived information, but not a separate access-control vulnerability.

- **Account Takeover Risk:** If an attacker obtains the hash and recovers the user's password, they could potentially log in as that user.
This does not mean PocketBase uses MD5 to store actual authentication passwords. The pw_hint field is separate from PocketBase's password storage.

- **Password Changes:** The pw_hint value changes when the user's password is updated. However, it has not yet been confirmed whether the new value is exactly MD5(new_password).

## Remediation

- **Remove pw_hint:** Do not store password-derived hints or hashes in user records.

- **Use secure password hashing:** Store actual passwords using Argon2id or another dedicated password-hashing algorithm with proper salts.

- **Restrict access:** Ensure sensitive user fields cannot be accessed by unauthorized users.

- **Protect affected accounts:** If password hashes have been exposed, consider resetting affected passwords.