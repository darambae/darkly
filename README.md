# Darkly

This repository documents a security assessment of the local Darkly web application. It contains 15 findings covering access control, authentication, injection, data exposure, and session handling. Each numbered directory has an `explanation.md` with the finding's reproduction steps, impact, and remediation. Some directories also include an `exploit.sh` to reproduce the finding against the local lab.

This README is a **project and folder index**. For the combined audit results and flags, read the [walkthrough](walkthrough.md). For a specific finding's evidence and steps, open its `explanation.md` below.

## Finding directories

| Directory name | Finding | Script included? |
| --- | --- | --- |
| [01_insecure_direct_object_references](01_insecure_direct_object_references/explanation.md) | Private profile note accessible through another user's ID | No |
| [02_weak_password_change_or_reset_functionalities](02_weak_password_change_or_reset_functionalities/explanation.md) | Predictable password reset token | Yes: [exploit.sh](02_weak_password_change_or_reset_functionalities/exploit.sh) |
| [03_unrestricted_file_upload](03_unrestricted_file_upload/explanation.md) | Avatar upload accepts an unexpected file type | No |
| [04_stored_xss](04_stored_xss/explanation.md) | Stored JavaScript in forum content | No |
| [05_security_misconfiguration](05_security_misconfiguration/explanation.md) | Session cookie lacks `HttpOnly` | No |
| [06_xml_external_entity_injection](06_xml_external_entity_injection/explanation.md) | XML import reads an internal resource | No |
| [07_sensitive_information_disclosure](07_sensitive_information_disclosure/explanation.md) | PocketBase administrator credentials exposed | No |
| [08_mass_assignment](08_mass_assignment/explanation.md) | Profile API permits a role change | Yes: [exploit.sh](08_mass_assignment/exploit.sh) |
| [09_excessive_data_exposure](09_excessive_data_exposure/explanation.md) | Grades API exposes another student's data | No |
| [10_cross_site_request_forgery](10_cross_site_request_forgery/explanation.md) | Profile update accepts a cross-origin request | Yes: [exploit.sh](10_cross_site_request_forgery/exploit.sh) |
| [11_path_traversal](11_path_traversal/explanation.md) | File download permits path traversal | Yes: [exploit.sh](11_path_traversal/exploit.sh) |
| [12_jwt_forgery](12_jwt_forgery/explanation.md) | Weak signing secret permits forged JWTs | Yes: [exploit.sh](12_jwt_forgery/exploit.sh); [cookie generator](12_jwt_forgery/generate_role_cookies.sh) |
| [13_cryptographic_failures](13_cryptographic_failures/explanation.md) | Unsalted MD5 password hints in PocketBase | No |
| [14_reflected_xss](14_reflected_xss/explanation.md) | Newsletter input reflects JavaScript | No |
| [15_open_redirect](15_open_redirect/explanation.md) | Redirect accepts an external destination | No |

“No” means there is no reproduction script in that directory; the `explanation.md` describes the manual steps. The scripts target the local lab and some change application data. Read the corresponding explanation and check the script's account, cookie, and URL settings before running it.

## Other files and folders

- [`reconnaissance/`](reconnaissance/reconnaissance_notes.txt) contains initial observations, screenshots, and leads. It is not a separate finding.
- [`Resources/`](Resources/) contains shared sample files and session data used during the assessment.
- [`walkthrough.md`](walkthrough.md) combines the findings, verified results, and flags in one audit narrative.
