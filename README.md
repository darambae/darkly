# Darkly

This repository documents a security assessment of the local Darkly web application, covering authentication, access control, injection, data exposure, and other web security issues.

The numbered directories (`01_...` through `16_...`) each document one finding. For example:

```text
12_path_traversal/
├── explanation.md   # Finding, reproduction steps, impact, and remediation
├── exploit.sh       # Script to reproduce the finding
├── FLAG             # Challenge flag, when one was found
└── Resources/       # Supporting evidence or test files
```

Every finding has an `explanation.md`; scripts, flags, and resource folders are included where applicable. Read a finding's explanation before running its script against the local lab.

To run the scripts, `curl` and `jq` commands should be installed.
Run `./pre-requisite.sh` to check if the two commands are installed, otherwise this script will install them.

The [walkthrough](walkthrough.md) summarizes the findings and results in one place. [`reconnaissance/`](reconnaissance/reconnaissance_notes.txt) contains initial observations and leads, while [`en.subject.pdf`](en.subject.pdf) is the project brief.
