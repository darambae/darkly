# Darkly audit walkthrough

## Summary

The repository contains **16 findings**: **10 with a recorded flag** and **6 without one**. The results below summarize each folder's explanation, script, and supporting files.

## Reconnaissance

Navigation, HTML comments, browser behavior, and `robots.txt` supplied leads. In particular, `robots.txt` listed `/staff`, `/internal`, `/backup`, and `/api/grades`. A listed route is a clue, not proof of a vulnerability. HTML comments also mentioned a session cookie without `HttpOnly`, an unsafe XML parser, and a removed upload allowlist. See the [reconnaissance notes](reconnaissance/reconnaissance_notes.txt) and [HTML source notes](reconnaissance/html_source_notes.txt).

## Findings

| # | Finding | Documented observation | Flag |
| --- | --- | --- | --- |
| 01 | [Insecure direct object references](01_insecure_direct_object_references/explanation.md) | Another user's private profile note was readable from a profile URL. | `FLAG{1d0r_ur_pr0f1l3_1s_m1n3}` |
| 02 | [Identification and authentication failures](02_Authentication_Failures/explanation.md) | The password reset flow disclosed its reset token to the requester without verifying email ownership. | None |
| 03 | [Weak password reset token](03_Weak_Password_Change_or_Reset_Functionalities/explanation.md) | A token derived from MD5 of the user's email could be predicted and used to reset the password. | `FLAG{r3s3t_t0k3n_w4s_just_md5_lol}` |
| 04 | [Session cookie without HttpOnly](04_security_misconfiguration/explanation.md) | Browser JavaScript could read the `session` cookie. | None |
| 05 | [Stored cross-site scripting](05_stored_xss/explanation.md) | A forum post executed stored JavaScript; the documented payload sent a readable session cookie to `/api/collect`. | `FLAG{xss_st0r3d_1s_n0t_4_f34tur3_w1l}` |
| 06 | [Unrestricted file upload](06_unrestricted_file_upload/explanation.md) | The avatar upload accepted a non-image shell file. File execution was not established. | `FLAG{unr3str1ct3d_upl0ad_g0_brrr}` |
| 07 | [Mass assignment](07_mass_assignment/explanation.md) | A student changed their own role to `cadet` with `PATCH /api/profile` and reached the staff dashboard. | `FLAG{just_p4tch_y0ur_0wn_r0l3_lol}` |
| 08 | [XML external entity injection](08_xml_external_entity_injection/explanation.md) | An agenda XML import resolved an external entity and returned `/internal/config`, including sensitive configuration. | `FLAG{d3fus3dxml_n3xt_spr1nt_pr0m1s3}` |
| 09 | [Sensitive information disclosure](09_sensitive_information_disclosure/explanation.md) | The exposed configuration contained PocketBase administrator credentials; the documented chain reached backend records and changed a user's role. | `FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}` |
| 10 | [Excessive data exposure](10_excessive_data_exposure/explanation.md) | The grades API response included expanded project data and a `flag` field. The bundled script uses a forged student cookie. | `FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}` |
| 11 | [CSRF protection weakness](11_cross_site_request_forgery/explanation.md) | A state-changing request with a forged `Origin` and a manually supplied valid cookie was accepted. A tested cross-site browser POST did not include the `SameSite=Lax` cookie. | `FLAG{csrf_4ny_0r1g1n_1s_w3lc0m3}` |
| 12 | [Path traversal](12_path_traversal/explanation.md) | A `../` path in `/projects/download` reached an internal note; `/backup` headers disclosed its path. | `FLAG{d0t_d0t_sl4sh_4ll_th3_w4y_d0wn}` |
| 13 | [JWT forgery](13_jwt_forgery/explanation.md) | A forged HS256 session using the exposed signing secret was accepted for another user's identity. The bundled script also sends a role-change request. | None |
| 14 | [Cryptographic failures](14_cryptographic_failures/explanation.md) | PocketBase's `pw_hint` matched unsalted MD5 of a known password for one account. Ordinary-user access to the field was not established. | None |
| 15 | [Reflected cross-site scripting](15_reflected_xss/explanation.md) | The newsletter confirmation rendered an unescaped submitted script; browser execution is reported in the finding. Staff-area execution was not observed. | None |
| 16 | [Open redirect](16_open_redirect/explanation.md) | `/redirect?next=https://example.com` returned a redirect to the external URL. | None |

## Reproduction notes

Start with each linked explanation, then run its script from that finding's directory. Several scripts use the session cookie created by [finding 02](02_Authentication_Failures/explanation.md); findings 10 and 13 generate their own role cookies.
