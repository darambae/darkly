# Darkly audit walkthrough

 **Total number of Flags recovered** 7: 
 **Total number of Vulnerabilities recovered** 9:

## Reconnaissance

We reviewed the navigation, HTML comments, browser console, and `robots.txt`. The latter lists routes including `/staff`, `/internal`, `/backup`, and `/api/grades`; listing a route is only a clue. The HTML comments mention a session cookie without `HttpOnly`, an XML parser that does not use `defusedxml`, and a removed file-upload allowlist. The detailed notes and screenshots are in [reconnaissance](reconnaissance/reconnaissance_notes.txt).

| Finding | Breach | Recorded flag |
| --- | --- | --- |
| 1 | [Insecure Direct Object References](insecure_direct_object_references/explanation.md) | `FLAG{1d0r_ur_pr0f1l3_1s_m1n3}` |
| 2 | [Weak Password Change or Reset Functionalities](weak_password_change_or_reset_functionalities/explanation.md) | `FLAG{r3s3t_t0k3n_w4s_just_md5_lol}` |
| 3 | [Unrestricted File Upload](unrestricted_file_upload/explanation.md) | `FLAG{unr3str1ct3d_upl0ad_g0_brrr}` |
| 4 | [Stored Cross Site Scripting](stored_cross_site_scripting/explanation.md) | `FLAG{xss_st0r3d_1s_n0t_4_f34tur3_w1l}` |
| 5 | [Security Misconfiguration](security_misconfiguration/explanation.md) | None recorded |
| 6 | [XML External Entity Injection](xml_external_entity_injection/explanation.md) | `FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}` |
| 7 | [Sensitive Information Disclosure](sensitive_information_disclosure/explanation.md) | `FLAG{just_p4tch_y0ur_0wn_r0l3_lol}` after role change |
| 8 | [Mass Assignment](mass_assignment/explanation.md) | None confirmed |
| 9 | [Excessive Data Exposure](excessive_data_exposure/explanation.md) | `FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}` |

## 1. Insecure Direct Object References

Open a conversation and follow the link to `wil`'s profile at `http://localhost:4942/profile/k1asdfeditojrb4` while signed in as another user. The profile response reveals `wil`'s private note and its flag. The profile ID is obtainable from site links, but possession of the ID should not authorize access to a private note. The server should check note ownership before returning it.

## 2. Weak Password Change or Reset Functionalities

The notes describe a password reset using a publicly visible email address without proving control of that inbox. The [finding](weak_password_change_or_reset_functionalities/explanation.md) records that the reset token is the MD5 hash of the email address and that the `benjamin@student.42.tech` account was used to recover a flag. A predictable token lets someone who knows the address take over the account. Reset tokens should be random, single use, short lived, and delivered through the verified recovery channel.

## 3. Unrestricted File Upload

From `/profile/me/settings`, attempt to upload a non-image file as an avatar. The recorded result is that arbitrary file types are accepted and the flag appears. The HTML deployment note says the upload allowlist was removed; the upload observation is the evidence of the breach. The server should allow only required image types, verify their content, limit size, and store them outside executable paths.

## 4. Stored Cross Site Scripting

Create a forum post containing a harmless test payload such as `<script>alert('XSS test')</script>`. The recorded observation is that the script executes when the stored post is viewed, including from another profile. The [finding](stored_cross_site_scripting/explanation.md) also describes a payload that sends `document.cookie` to `/api/collect`; this combines stored XSS with the cookie misconfiguration below. Render forum content as text or sanitize allowed HTML, and use `HttpOnly` on session cookies.

## 5. Security Misconfiguration: session cookie

Sign in, run `document.cookie` in the browser console, and inspect the `session` cookie in Developer Tools. The recorded observation is that JavaScript can read the JWT because the cookie lacks `HttpOnly`. This raises the impact of XSS, but it is a separate configuration weakness. Set `HttpOnly`, use `Secure` over HTTPS, and choose an appropriate `SameSite` policy.

## 6. XML External Entity Injection

Import the provided [agenda XML](xml_external_entity_injection/agenda_xxe.xml) through `/agenda`. Its external entity asks the server to fetch `http://127.0.0.1:4942/internal/config`. The imported event displays internal configuration, including a flag and administrator credentials. The parser must reject untrusted external entities; sensitive internal endpoints must also enforce authorization.

## 7. Sensitive Information Disclosure and privilege escalation

The configuration obtained through the XML import contains PocketBase administrator credentials. The [finding](sensitive_information_disclosure/explanation.md) records a successful administrator sign-in at `http://localhost:8090/_/`, a change of `jdoe`'s role from `student` to `god`, and subsequent access to `/staff/dashboard` and its flag. This demonstrates the impact of exposed credentials. It does not show that PocketBase incorrectly authorized the role change. Remove the XXE path, protect configuration, rotate the exposed credentials, and restrict administrator access.

## 8. Mass Assignment

The `/staff` page hints at `PATCH /api/profile`. With a `student` session, send `{"role":"cadet"}` to that endpoint and inspect the resulting account role. The [finding](mass_assignment/explanation.md) records that the server accepted the role change. This lets an ordinary account assign itself a privileged field. Accept only user-editable profile fields and require a separately authorized operation for role changes. No flag is confirmed for this endpoint.

## 9. Excessive Data Exposure

The recorded test opened `/api/grades` while `jdoe` already had the `god` role. The JSON response included an expanded Darkly project object with a `flag` field. Return only fields needed by the grades view and protect flags separately. Because the request used an elevated account, the repository does not establish whether guests or students can read this endpoint.

## Current coverage

These notes describe nine distinct findings and seven recorded flag values. The subject requires ten vulnerabilities and six flags for the mandatory part, including four privilege-progression flags. The current records do not establish which four flags form that progression, and the existing explanations do not yet include the reproduction scripts requested by the subject. Those gaps need verification before submission.
