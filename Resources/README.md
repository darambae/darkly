# Darkly endpoint curl collection

Generated from the user-provided Burp Suite XML export (40 recorded requests, **23 unique method/path pairs**). No HTTP requests were sent to Darkly during generation.

## Setup

- Put real Netscape-format session-cookie files at `Resources/student-cookie.txt`, `Resources/cadet-cookie.txt`, `Resources/staff-cookie.txt`, and `Resources/god-cookie.txt` (or use the files generated earlier).
- The supplied `Resources/users.json` maps each role to the **first** matching user in the array.
- Run scripts from any working directory; paths resolve relative to the project.
- `ROLE=guest` avoids a session cookie. Otherwise the default role is `student`.
- `BASE_URL` is restricted to localhost:4942 / 127.0.0.1:4942.

## One endpoint

```bash
ROLE=student ./requests/get_api_docs_internal.sh
ROLE=staff ./requests/get_staff_dashboard.sh
ROLE=god ./requests/get_profile_z4p1cnx47mfy50f.sh
```

`get_profile_z4p1cnx47mfy50f.sh` dynamically substitutes the first user ID for the selected role from users.json; the filename reflects the exported capture.

## Compare access by role (GET only)

```bash
./run_get_matrix.sh
```

Responses are saved in `results/` (possibly containing private app data). Do not commit them.

## POST requests (explicit opt-in)

POST requests can alter account data, create records, or upload files. They are intentionally blocked unless `ALLOW_WRITE=1` is passed. Example:

```bash
ROLE=student ALLOW_WRITE=1 ./requests/post_profile_me_settings.sh
ROLE=student ALLOW_WRITE=1 ./requests/post_agenda_import.sh
ROLE=student ALLOW_WRITE=1 UPLOAD_FILE=Resources/agenda.xml ./requests/post_agenda_import.sh
ROLE=student ALLOW_WRITE=1 LOGIN_PASSWORD='your-test-password' ./requests/post_login.sh
```

Sample inputs are **benign**. The XML file deliberately contains no external entities; the avatar is a tiny PNG. Login credentials are not inferred from users.json. The POST login template uses the selected user's email and a separately supplied `LOGIN_PASSWORD`.

## Interpreting results

HTTP 200 alone does not establish authorization bypass; check the response body. A 302 to login indicates authentication is required. Tokens generated from a known signing secret are not equivalent to sessions obtained via legitimate sign-in, so record that limitation when reporting access-control results.

## Captured endpoint table

See `endpoints.tsv` for methods and mappings. Duplicated request captures were consolidated. Telemetry heartbeat has a minimal JSON fixture, not a replay of its original timestamp. `profile/me/settings` uses harmless sample fields but still changes profile data.

## Security

Protect `Resources/*-cookie.txt`, passwords, and `results/` with appropriate file permissions and `.gitignore`. Never upload authentication tokens to reports.
