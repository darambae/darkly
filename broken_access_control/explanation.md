## Vulnerability N1: Broken Access Control

- **Category:** (OWASP category)
    WSTG-ATHZ-04: Insecure Direct Object References (IDOR)
- **Location:**
    /profile/k1asdfeditojrb4
- **Discovery:** (What clue made you suspect it?)
  I went through '/forum' and accessed to user's profile page to gather information on the website
- **Steps to Reproduce:** (Step by step, so anyone can follow along)
  1. Click on Wil's profile in his forum post
- **Flag:** ```FLAG{1d0r_ur_pr0f1l3_1s_m1n3}```
- **Cause:** (Why was this possible, from a code/design perspective?)
  - Server doesn't verify the user's authorization to restricted data.
- **Remediation:** (How should it be fixed?)
  - Server has to check if the user has permission to access to certain information.
