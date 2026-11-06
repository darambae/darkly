# Unrestricted File Upload

- **Category:** (OWASP category)
    OWASP A03:2021 – Injection
    OWASP A04:2021 – Insecure Design
    WSTG-BUSL-08 Test Upload of Unexpected File Types
- **Location:**
    `/profile/me/settings`
- **Discovery:**
  `v1.3.3 — wil — quick fix on file upload (removed the whitelist entirely)`
- **Steps to Reproduce:** (Step by step, so anyone can follow along)
  1. Go to user's profile page
  2. Upload any type of file in Avatar
- **Flag:** `FLAG{unr3str1ct3d_upl0ad_g0_brrr}`
- **Cause:** 
  - **Missing Validation:** The server completely lacks file extension and content-type checks because the whitelist was intentionally or accidentally removed.
  - **Unfiltered Processing:** Uploaded files are accepted and stored blindly without verifying MIME types, content signatures, or file headers (Magic Bytes).
  - **Unsafe Storage Configuration:** Upload directories lack execution restrictions, allowing uploaded scripts to be interpreted or executed by the server.

- **Remediation:**
  - **Strict Whitelisting:** Enforce a strict whitelist of allowed safe file extensions (e.g., `.jpg`, `.png`, `.webp`) rather than relying on blocklists.
  - **Content Inspection & Magic Bytes:** Validate file headers and binary signatures (Magic Bytes) on the server side to ensure the file content matches its declared extension.
  - **Randomized Storage Names:** Sanitize and store uploaded files using randomized identifiers (e.g., UUIDv4) to prevent path traversal and file overwrite attacks.
  - **Restricted Execution Permissions:** Mount upload directories with execution disabled (e.g., removing execute permissions on web server directories) and serve user-uploaded assets via isolated storage (e.g., cloud object storage or a separate CDN domain).
