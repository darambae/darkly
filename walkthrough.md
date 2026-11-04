# Darkly audit walkthrough

## Current results

- **Confirmed security findings:** 11
- **Flags tied to confirmed findings:** 10
- **Additional flag observed during follow-up testing:** 1

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
| 7 | [Sensitive Information Disclosure](07_sensitive_information_disclosure/explanation.md) | Exposed PocketBase administrator credentials enabled privileged backend access | `FLAG{th3_und3rsc0r3_sl4sh_kn0ws_th3_w4y}` from the verified impact chain |
| 8 | [Mass Assignment](08_mass_assignment/explanation.md) | A student could change their own role to `cadet` through `PATCH /api/profile` | `FLAG{just_p4tch_y0ur_0wn_r0l3_lol}` |
| 9 | [Excessive data exposure](09_excessive_data_exposure/explanation.md) |  | `FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}` |
| 10 | [Cross-Site Request Forgery Protection Weakness](10_cross_site_request_forgery/explanation.md) | The server accepted a state-changing request with an external `Origin` and no CSRF token | `FLAG{csrf_4ny_0r1g1n_1s_w3lc0m3}` |
| 11 | [Path Traversal](11_path_traversal/explanation.md) | `../` escaped the download directory and exposed `data/private_notes.txt` | `FLAG{d0t_d0t_sl4sh_4ll_th3_w4y_d0wn}` |
