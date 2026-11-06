# Excessive Data Exposure: Grades API

## Category

- OWASP A01:2021 – Broken Access Control (if the endpoint is accessible without the required authorization)
- OWASP A04:2021 – Insecure Design / Excessive Data Exposure
- WSTG-ATHZ-02 – Testing for Bypassing Authorization Schema
- CWE-200 – Exposure of Sensitive Information to an Unauthorized Actor

## Location

- `GET http://localhost:4942/api/grades`
- Linked from the Staff Dashboard (`/staff/dashboard`), under the API grades / JSON resources.

## Discovery

- After gaining access to the Staff Dashboard with the `jdoe` account (whose role had been changed to `god` through the previously documented PocketBase administration compromise), the dashboard displayed links to API resources.
- `<!-- sophie: /api/docs-internal still accessible without staff check — TODO fix in v1.4 -->`
```
  "grades":{"fields":["id","student","project","score","flag"],"note":"flag field accessible via GET /api/grades?student={id}"}
```

## Steps to Reproduce

1. Sign in to Darkly using a student account
2. Navigate to `http://localhost:4942/api/grades?student=z4p1cnx47mfy50f`.(This is jdoe's id)
3. Inspect the returned JSON array.
4. Find the record whose `expand.project.name` is `Darkly` (or whose `expand.project.slug` is `darkly`).
5. Read the `flag` property inside the expanded project object. (!This flag is only found in jdoe's grade)

## Flag

`FLAG{md5_1s_4_n4m3pl4t3_n0t_4_l0ck}`


## Cause

- **Excessive Data Exposure:** The grades endpoint serializes expanded project records that include a sensitive `flag` field, even though the grades response does not need to reveal that value.
- **Insufficient Response Filtering:** Sensitive fields are not removed from the API response before it is sent to the client.
- **Authorization Scope Not Yet Established:** The observed request was made after obtaining elevated privileges. Additional testing with a guest or ordinary student account is required before concluding that `/api/grades` itself is accessible without authorization.

## Remediation

- **Minimize API Responses:** Return only the fields required by the grades feature; never include challenge flags or secrets in expanded project objects.
- **Enforce Server-Side Authorization:** Check authentication and per-record permissions before returning grades and related project information.
- **Apply Field-Level Access Controls:** Exclude sensitive project fields from API serialization for users who do not explicitly need them.
- **Test Different Roles:** Add automated checks for visitor, student, staff, and administrator access to the endpoint.
