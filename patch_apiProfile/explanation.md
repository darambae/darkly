
## Vulnerability N7: Privilege Escalation via Mass Assignment

- **Category:**
  - OWASP A01:2021 – Broken Access Control
  - CWE-915 – Improperly Controlled Modification of Dynamically-Determined Object Attributes
  - CWE-269 – Improper Privilege Management
  - WSTG-ATHZ-03 – Testing for Privilege Escalation

- **Location:**
  - `http://localhost:4942/api/profile`
  - HTTP Method: PATCH

- **Discovery:**
  While exploring the `/staff` page, the following message was found:

  "Cadet access required. Try PATCH /api/profile with the right fields."

  This suggested that the profile update endpoint might allow users to modify sensitive attributes, including their authorization role.

  The vulnerability was tested using the `jdoe` account, whose role had first been reset to `student`.

- **Steps to Reproduce:**
  1. Sign in to Darkly using a test account with the `student` role (e.g., `jdoe`).
  2. Open Chrome Developer Tools and retrieve the account's session cookie.
  3. Open Postman and create a new PATCH request to:

     `http://localhost:4942/api/profile`

  4. Configure the request headers:

     ```
     Content-Type: application/json
     Cookie: session=<YOUR_SESSION_JWT>
     ```

  5. Select Body → raw → JSON and enter:

     ```json
     {
       "role": "cadet"
     }
     ```

  6. Send the request.
  7. Observe that the server accepts the modification.
  8. Verify that the account's role has changed from `student` to `cadet`.
  9. Access the staff functionality to confirm that the new privileges are applied.

- **Flag:**
  No specific flag confirmed yet for this endpoint.

- **Cause:**
  - **Mass Assignment:** The profile update endpoint accepts a sensitive field (`role`) supplied directly by the client.
  - **Missing Field-Level Authorization:** The server does not prevent ordinary users from modifying authorization-related attributes.
  - **Privilege Escalation:** A user with the `student` role can assign themselves the higher-privileged `cadet` role.
  - **Improper Trust Boundary:** The application trusts client-controlled profile data when updating security-sensitive account properties.

- **Remediation:**
  - **Strict Field Allowlisting:** Only accept explicitly authorized profile fields, such as display name or profile preferences.
  - **Server-Side Authorization:** Prevent users from modifying their own roles through ordinary profile update endpoints.
  - **Separate Administrative Operations:** Restrict role changes to dedicated administrative endpoints with appropriate authorization checks.
  - **Validate Privilege Transitions:** Enforce role hierarchy and permission checks on the server.
  - **Regression Testing:** Add automated tests verifying that a `student` cannot change their role to `cadet`, `god`, or any other privileged role.
