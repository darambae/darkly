# Darkly

This repository documents a security assessment of the local Darkly web application. It contains 16 findings covering access control, authentication, injection, data exposure, session handling, and redirects. Finding categories use [OWASP Top 10:2025](https://top10.owasp.org/2025/0x00_2025-Introduction/); WSTG and CWE references are listed separately. The [walkthrough](walkthrough.md) indexes every finding and records the reported result and flag status.

## Repository layout

- `01_...` through `16_...`: one finding per numbered directory. Every directory has an `explanation.md` and an `exploit.sh`. Ten also have a `FLAG` file. Evidence and payloads live in `Resources/`, except for the upload payload in `06_unrestricted_file_upload/Resource/`.
- [`reconnaissance/`](reconnaissance/reconnaissance_notes.txt): initial leads and HTML source notes. These notes include hypotheses; use the numbered findings for documented results.
- [`pre-requisite.sh`](pre-requisite.sh): checks for the required commands in your system to run `exploit.sh`. Run `bash pre-requisite.sh` from the repository root.

- [`en.subject.pdf`](en.subject.pdf): project brief.

## Reproducing findings in the local lab

Start the Darkly lab at `http://localhost:4942` before making requests. Findings 09 and 14 also use PocketBase at `http://localhost:8090`.

Read a finding's `explanation.md` before running its script. Run scripts **from their own directory**, because several use relative paths for payloads and cookie jars. Follow the number of folders to reproduce the breach for dependencies. 
```
