# Weak Password Change or Reset Functionalities

## Category

OWASP A07:2021 – Identification and Authentication Failures.
WSTG-ATHN-09 – Weak Password Change or Reset Functionalities.

## Location

/profile/me/settings

## Discovery

In the Benjamin's post on Forum, he gave a hint about resetting passwords.

## Steps to Reproduce

1. Reset password of an user using `./exploit.sh`
2. Go to `http://localhost:4942/profile/me/settings`
3. Find the flag on his profile.

## Flag

FLAG{r3s3t_t0k3n_w4s_just_md5_lol}

## Impact

A person who knows a user’s email can derive a valid reset token and take over that account if the token remains valid.

## Cause

The application utilized a static, deterministic hashing function (MD5) directly on user email identifiers without a server-side salt or high-entropy random component. Because MD5 is non-salted and computationally trivial to brute-force or pre-calculate, knowing a target's email address instantly yields a valid, unexpiring password reset token.

## Remediation

- **CSPRNG Tokens:** Generate reset tokens using a cryptographically secure pseudo-random number generator (CSPRNG) with high entropy (e.g., UUIDv4 or 32+ bytes of random data).
- **Single-Use & Short-Lived:** Enforce strict expiration windows (e.g., 15 minutes) and invalidate tokens immediately upon use.
- **Token Hashing:** Store only cryptographic hashes of active reset tokens in the database.
- **Rate Limiting:** Implement strict throttling on reset request routes to mitigate account enumeration and abuse.
- **Out-of-Band Verification:** Deliver tokens exclusively through verified recovery channels (e.g., registered email) and avoid exposing them through client-side application state or predictable functions.
