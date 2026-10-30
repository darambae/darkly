## Vulnerability N5: Sensitive Information Disclosure via Grades API

- **Category:**
  - OWASP A01:2021 – Broken Access Control (if the endpoint is accessible without the required authorization)
  - OWASP A04:2021 – Insecure Design / Excessive Data Exposure
  - WSTG-ATHZ-02 – Testing for Bypassing Authorization Schema
  - CWE-200 – Exposure of Sensitive Information to an Unauthorized Actor

- **Location:**
  - `GET http://localhost:4942/api/grades`
  - Linked from the Staff Dashboard (`/staff/dashboard`), under the API grades / JSON resources.

- **Discovery:**
  - After gaining access to the Staff Dashboard with the `jdoe` account (whose role had been changed to `god` through the previously documented PocketBase administration compromise), the dashboard displayed links to API resources.
  - Opening `/api/grades` returned raw JSON records, including expanded project information.
  - One expanded `project` object contained a `flag` field for the Darkly project.

- **Steps to Reproduce:**
  1. Sign in to Darkly using the lab account `jdoe`, previously assigned the `god` role.
  2. Navigate to `http://localhost:4942/staff/dashboard`.
  3. Open the **API grades** link, or navigate to `http://localhost:4942/api/grades`.
  4. Inspect the returned JSON array.
  5. Find the record whose `expand.project.name` is `Darkly` (or whose `expand.project.slug` is `darkly`).
  6. Read the `flag` property inside the expanded project object.

- **Flag:** `FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}`

- **Cause:**
  - **Excessive Data Exposure:** The grades endpoint serializes expanded project records that include a sensitive `flag` field, even though the grades response does not need to reveal that value.
  - **Insufficient Response Filtering:** Sensitive fields are not removed from the API response before it is sent to the client.
  - **Authorization Scope Not Yet Established:** The observed request was made after obtaining elevated privileges. Additional testing with a guest or ordinary student account is required before concluding that `/api/grades` itself is accessible without authorization.

- **Remediation:**
  - **Minimize API Responses:** Return only the fields required by the grades feature; never include challenge flags or secrets in expanded project objects.
  - **Enforce Server-Side Authorization:** Check authentication and per-record permissions before returning grades and related project information.
  - **Apply Field-Level Access Controls:** Exclude sensitive project fields from API serialization for users who do not explicitly need them.
  - **Test Different Roles:** Add automated checks for anonymous, student, staff, and administrator access to the endpoint.
  - **Protect Challenge Secrets:** Keep flags in a separate, access-controlled store rather than general-purpose project records.

**Evidence:** The browser response from `GET /api/grades` displayed a JSON array with an expanded Darkly project containing the flag. The screenshot was taken while the `jdoe` account had already been promoted to `god`.

**Note:** The flag text references MD5, but the observed response alone does not demonstrate an MD5-related vulnerability. This report describes the verified information disclosure and does not claim a cryptographic weakness without further evidence.
