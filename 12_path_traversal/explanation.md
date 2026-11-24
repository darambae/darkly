# Path Traversal: Backup Exclusion Reveals a File Path

## Category

- OWASP A01:2021 – Broken Access Control
- CWE-22 – Improper Limitation of a Pathname to a Restricted Directory

## Location

- Clue: `GET http://localhost:4942/backup`
- File download to test: `GET http://localhost:4942/projects/download?file=...`

## Discovery

1. Open `http://localhost:4942/robots.txt` and try the endpoints listed there.
2. Request `/backup`. Its empty response body is accompanied by backup-related headers, including:

   ```text
   x-backup-agent: rsync/3.2.7
   x-backup-dest: localhost:/opt/pocketbase/pb_data
   x-backup-exclude: data/private_notes.txt
   x-backup-schedule: daily@03:00
   x-last-backup: 2024-12-01T03:00:00Z
   ```

3. `x-backup-exclude` identifies `data/private_notes.txt` as a file excluded from backups. The relative path suggests a file within the application's data directory; the header alone does not prove that the file is reachable through HTTP.
4. Because `/projects/download` accepts a file name through the `file` parameter, use the disclosed path as a target for a path traversal test. A `../` segment asks the server to move up one directory before resolving `data/private_notes.txt`.

## Steps to Reproduce

1. Sign in with a test account and request `GET /backup`; inspect `x-backup-exclude` for `data/private_notes.txt`.
2. From this directory, run `./exploit.sh` with the test account cookie jar configured in the script. It tries `../` prefixes against `/projects/download?file=...`.
3. Observe the response containing `private_notes.txt` and the recovery flag.

## Flag

`FLAG{d0t_d0t_sl4sh_4ll_th3_w4y_d0wn}`

## Impact

The documented traversal test reached an internal note and its recovery flag. The backup header also discloses an internal path.

## Cause

If the download endpoint joins the untrusted `file` parameter to a directory without verifying the resolved path remains inside the permitted directory, `../` can escape that directory and expose files.

## Remediation

- Allow downloads only by server-controlled file identifiers or an explicit allowlist.
- If file paths are required, resolve the final path and verify it remains within the intended download directory before opening it.
- Do not expose internal file paths and backup configuration in public response headers.

## Evidence

* `private_notes.txt`
  ```
  # 42 Network — internal ops note (NOT for the public webroot) — wil
  # reminder: rotate the pb_admin password after the security audit. (we won't.)
  # emilie keeps saying /projects/download joins paths without sanitizing. it's fine.
  recovery_flag=FLAG{d0t_d0t_sl4sh_4ll_th3_w4y_d0wn}
  ```
- [exploit.sh](exploit.sh)

