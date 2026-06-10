---
description: Install the repo-knowledge system into the current repo — always-on contract + .knowledge/ scaffold. Content only; tooling stays global.
---

# /knowledge-init (Claude Code front-end)

Thin entry point. The full procedure is shared across platforms and lives in the global assets
dir installed by the one-time install script.

Read and execute, step by step:

- `~/.knowledge-system/workflows/knowledge-init.md`
  (Windows: `%USERPROFILE%\.knowledge-system\workflows\knowledge-init.md`)

with `surface = claude` and `$ARGUMENTS` passed through ($ARGUMENTS). It is authoritative — do not
improvise around its idempotency markers, the content-only rule (no scripts or templates are ever
copied into the repo), or the git wiring.

If the procedure file is missing, the global install hasn't been run — point the user at the
knowledge-system README's one-time install (`install.sh` / `install.ps1` from the skills repo).
