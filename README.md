# Darkly

Start with the [combined walkthrough](walkthrough.md), then open each finding's `explanation.md` for reproduction steps, impact, and remediation. [Reconnaissance notes](reconnaissance/reconnaissance_notes.txt) contain leads and observations rather than a separate breach.

The directory names are lowercase snake_case versions of OWASP breach or testing-guide terms. The names identify the specific finding where possible; broad OWASP Top 10 categories remain in each explanation. In particular, `security_misconfiguration` covers the session cookie without `HttpOnly`, and `sensitive_information_disclosure` covers the credentials exposed through the XXE chain.

| Directory | OWASP term used |
| --- | --- |
| `insecure_direct_object_references` | [Insecure Direct Object References](https://wstg.owasp.org/latest/4-Web_Application_Security_Testing/05-Authorization/04-Insecure_Direct_Object_References/) |
| `weak_password_change_or_reset_functionalities` | [Weak Password Change or Reset Functionalities](https://wstg.owasp.org/latest/4-Web_Application_Security_Testing/04-Authentication/09-Weak_Password_Change_or_Reset_Functionalities/) |
| `unrestricted_file_upload` | [Unrestricted File Upload](https://community.owasp.org/vulnerabilities/Unrestricted_File_Upload) |
| `stored_cross_site_scripting` | [Stored Cross Site Scripting](https://wstg.owasp.org/latest/4-Web_Application_Security_Testing/07-Injection/02-Stored_Cross_Site_Scripting/) |
| `security_misconfiguration` | [Security Misconfiguration](https://top10.owasp.org/2021/A05_2021-Security_Misconfiguration/) |
| `xml_external_entity_injection` | [XML External Entity (XXE) Injection](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html) |
| `sensitive_information_disclosure` | Sensitive Information Disclosure, as used in the [OWASP testing guide](https://owasp.org/www-project-web-security-testing-guide/assets/archive/OWASP_Testing_Guide_v4.pdf) |
| `mass_assignment` | [Mass Assignment](https://wstg.owasp.org/latest/4-Web_Application_Security_Testing/07-Injection/20-Mass_Assignment/) |
| `excessive_data_exposure` | [Excessive Data Exposure](https://wstg.owasp.org/latest/4-Web_Application_Security_Testing/12-API_Testing/03-Excessive_Data_Exposure/) |

The [project subject](en.subject.pdf) requests a reproduction script for each reported breach. Those scripts are not yet present in this repository. Existing screenshots and the PDF are also binary files, while the subject says the submission must not contain binaries; review that conflict before final submission.
