## Vulnerability N2: Unrestricted File Upload

- **Category:** (OWASP category)
    WSTG-BUSL-08
- **Location:**
    /profile/me/settings
- **Discovery:** (What clue made you suspect it?)
  In the source, the following line is found. "v1.3.3 — wil — quick fix on file upload (removed the whitelist entirely)"
- **Steps to Reproduce:** (Step by step, so anyone can follow along)
  1. Go to user's profile page
  2. Upload any type of file in Avatar
- **Flag:** FLAG{unr3str1ct3d_upl0ad_g0_brrr}
- **Cause:** (Why was this possible, from a code/design perspective?)
  - Missing Validation: The server completely lacks file extension and content checks (whitelist removed).
  - Unfiltered Processing: Uploaded files are accepted and stored blindly without verifying MIME types or Magic Bytes.
- **Remediation:** (How should it be fixed?)
  - Strict Whitelisting: Allow only safe image extensions (e.g., .jpg, .png).
  - Content Inspection & Renaming: Validate file headers (Magic Bytes) and store files with randomized names (e.g., UUID).  
