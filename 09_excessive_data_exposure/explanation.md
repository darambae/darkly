# Excessive Data Exposure: Grades API

## Category

- OWASP A01:2021 – Broken Access Control
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
  "grades":{"fields":["id","student","project","score","flag"],"note":"flag field accessible via GET /api/grades?student=02g7nfbtw0k83fu{id}"}
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

- **Missing Role Authorization:** The staff-only `/api/grades` endpoint accepts requests from an ordinary student account. Restricting the Staff Dashboard does not protect the API endpoint itself.
- **Missing Student-Level Authorization:** The endpoint uses the caller-supplied `student` ID to return that student's full project and grade records without checking whether the caller is allowed to view them.
- **Excessive Data Exposure:** The response expands project records and includes a sensitive `flag` field that the grades feature does not need to disclose.

## Remediation

- **Enforce the Staff Role on the API:** Check the authenticated caller's role on every `/api/grades` request and reject student requests, regardless of whether the Staff Dashboard is hidden from them.
- **Authorize Access to the Requested Student:** Before querying or returning records, verify that the caller is permitted to view the student identified by the `student` parameter. Do not treat knowledge of a student ID as permission.
- **Minimize and Filter Responses:** Return only the grade and project fields needed by authorized staff; exclude `flag` and other sensitive fields from expanded project objects.
- **Test Authorization Boundaries:** Add automated checks that visitors and students cannot retrieve another student's records by changing the `student` ID, while authorized staff can access only the records permitted by their role.
