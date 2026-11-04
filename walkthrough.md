# Darkly audit walkthrough

## Current results

- **Confirmed security findings:** 10
- **Flags tied to confirmed findings:** 8
- **Additional flags observed during follow-up testing:** 2
- **Item still requiring verification:** `/api/grades`

The counts distinguish root-cause findings from attack-chain impact. The PocketBase administrator attack chain demonstrates the impact of XXE and exposed credentials, so it is not counted again as an independent vulnerability. The `/api/grades` observation is retained separately because the flag was visible for `jdoe`, but changing another account's role to `god` did not reproduce it.

## Reconnaissance

Navigation, HTML comments, browser behavior, and `robots.txt` revealed useful leads. In particular, `robots.txt` listed `/staff`, `/internal`, `/backup`, and `/api/grades`. A listed route is a clue and does not establish a vulnerability by itself. HTML comments also mentioned a session cookie without `HttpOnly`, an unsafe XML parser, and a removed upload allowlist.

| # | Finding | Verified result | Flag |
| --- | --- | --- | --- |
| 1 | [Insecure Direct Object References](01_insecure_direct_object_references/explanation.md) | Another user's private profile note was readable | `FLAG{1d0r_ur_pr0f1l3_1s_m1n3}` |
| 2 | [Weak Password Change or Reset Functionalities](02_weak_password_change_or_reset_functionalities/explanation.md) | Predictable MD5-based reset token allowed an account password reset | `FLAG{r3s3t_t0k3n_w4s_just_md5_lol}` |
| 3 | [Unrestricted File Upload](03_unrestricted_file_upload/explanation.md) | The avatar feature accepted a non-image file | `FLAG{unr3str1ct3d_upl0ad_g0_brrr}` |
| 4 | [Stored Cross Site Scripting](04_stored_cross_site_scripting/explanation.md) | Stored forum content executed JavaScript | `FLAG{xss_st0r3d_1s_n0t_4_f34tur3_w1l}` |
| 5 | [Session Cookie Without HttpOnly](05_security_misconfiguration/explanation.md) | JavaScript could read the session cookie | None |
| 6 | [XML External Entity Injection](06_xml_external_entity_injection/explanation.md) | XML import fetched `/internal/config` through an external entity | `FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}` |
| 7 | [Sensitive Information Disclosure](07_sensitive_information_disclosure/explanation.md) | Internal configuration exposed valid PocketBase administrator credentials | None separate from the XXE response |
| 8 | [Mass Assignment](08_mass_assignment/explanation.md) | A student could change their own role to `cadet` through `PATCH /api/profile` | `FLAG{just_p4tch_y0ur_0wn_r0l3_lol}` |
| 9 | [Cross-Site Request Forgery Protection Weakness](10_cross_site_request_forgery/explanation.md) | The server accepted a state-changing request with an external `Origin` and no CSRF token | `FLAG{csrf_4ny_0r1g1n_1s_w3lc0m3}` |
| 10 | [Path Traversal](path_traversal/explanation.md) | `../` escaped the download directory and exposed `data/private_notes.txt` | `FLAG{d0t_d0t_sl4sh_4ll_th3_w4y_d0wn}` |

## 1. Insecure Direct Object References

Open `wil`'s profile at `http://localhost:4942/profile/k1asdfeditojrb4` from the forum while using another account. The response exposes `wil`'s private note and flag. A record identifier may locate a profile, but the server must separately authorize access to private fields.

## 2. Weak Password Change or Reset Functionalities

The password-reset token is derived by hashing the user's email address with MD5, and the reset flow does not prove control of that email inbox. Anyone who knows an account email can calculate the predictable token and reset its password. Reset tokens should be random, single use, short lived, and delivered through a verified recovery channel.

## 3. Unrestricted File Upload

The avatar upload under `/profile/me/settings` accepts file types outside the expected image formats. The server should use an allowlist, inspect the actual file signature, impose size limits, generate server-controlled names, and store uploads where they cannot execute.

## 4. Stored Cross Site Scripting

A forum post containing a script is stored and executed when the post is viewed. The demonstrated payload can send `document.cookie` to `/api/collect`. This combines stored XSS with the missing `HttpOnly` protection described below. Forum content should be contextually encoded or sanitized before rendering.

## 5. Session Cookie Without HttpOnly

After signing in, `document.cookie` returns the session JWT because the `session` cookie lacks `HttpOnly`. This increases the impact of XSS by allowing injected JavaScript to steal the session token. Authentication cookies should use `HttpOnly`, `Secure` when served over HTTPS, and an appropriate `SameSite` policy.

## 6. XML External Entity Injection

Import [agenda_xxe.xml](06_xml_external_entity_injection/agenda_xxe.xml) through `/agenda`. The external entity makes the server request `http://127.0.0.1:4942/internal/config`, and the imported event displays the response. The XML parser must reject DTDs and external entities, and internal endpoints must enforce authentication rather than trusting the source IP alone.

## 7. Sensitive Information Disclosure

The configuration returned through the XXE contains a JWT secret and valid PocketBase administrator credentials. The credentials successfully authenticated to the administration interface at `http://localhost:8090/_/`. Secrets should not be returned by application endpoints; the exposed password and signing secret must be rotated and administrative access should be network restricted.

This disclosure is kept as a separate finding because it exposes reusable administrator credentials, while XXE is the mechanism used to reach the configuration endpoint. The same XXE flag appears in the response, so no additional flag is counted here.

## 8. Mass Assignment

Using a student session, send `{"role":"cadet"}` to `PATCH /api/profile`. The server accepts the security-sensitive field, changes the user's role, and permits access to the staff dashboard. Profile updates should allow only ordinary profile fields; role changes require a separate administrator-authorized operation.

## 9. Cross-Site Request Forgery Protection Weakness

`POST /profile/me/settings` accepted an authenticated state-changing request with an arbitrary external `Origin` and without a CSRF token. The change persisted and the response produced the challenge flag.

The tested browser did not automatically attach the `SameSite=Lax` session cookie to a cross-site POST. Therefore, the evidence confirms missing server-side CSRF validation, but it does not prove that the tested conventional cross-site form attack succeeds in that browser. The endpoint should verify a CSRF token and validate `Origin`, while retaining `SameSite` as defense in depth.

## 10. Path Traversal

The `/backup` response disclosed `x-backup-exclude: data/private_notes.txt`. Supplying traversal segments to `/projects/download?file=...` escaped the intended download directory and returned that internal file. The file contained the recovery flag and a note confirming that the endpoint joins paths without sanitization.

The server should use server-controlled file identifiers or an allowlist. If paths are unavoidable, it must resolve the final canonical path and reject it unless it remains inside the permitted download directory.

## Verified attack-chain impact

The [PocketBase privilege-escalation chain](privilege_escalation_attack/explanation.md) used the administrator credentials exposed through the XXE response. With valid administrator access, `jdoe` was changed from `student` to `god`, and the protected `internal_audit` record revealed:

`FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}`

This proves the impact of the credential compromise. It is not an additional authorization vulnerability because an authenticated PocketBase administrator is expected to perform administrative changes. A separate finding would require evidence that a regular user can perform the same operation without the exposed administrator identity; the mass-assignment finding above independently proves one such self-service transition from `student` to `cadet`.

## `/api/grades`: observed flag, classification not yet confirmed

The saved evidence shows that `/api/grades` returned a Darkly grade record for `jdoe` whose `flag` field contained:

`FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}`

However, assigning the `god` role to another user did not reproduce the result: that user's grade flags remained empty. This means the `god` role alone does not explain the disclosure. The value may depend on the specific student record, a per-user challenge state, or another condition that has not yet been isolated.

For that reason, [the current grades report](09_excessive_data_exposure/explanation.md) should not yet be counted as a confirmed excessive-data-exposure vulnerability. To confirm it, compare the same grade record under multiple identities and determine whether a user can read a flag they are not intended to receive. If the API returns only each user's legitimately unlocked flag, the behavior is expected rather than a vulnerability.

## Flag accounting

Eight flags are directly associated with the ten confirmed findings. The PocketBase `internal_audit` flag demonstrates the impact of the XXE and credential-disclosure chain. The `/api/grades` flag was observed, but its vulnerability classification remains unconfirmed. This gives ten unique observed flag values in the repository without incorrectly treating every observed flag as an independent vulnerability.
