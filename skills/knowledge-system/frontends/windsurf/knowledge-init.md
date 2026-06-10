---
description: Install the repo-knowledge system into the current repo — always-on contract rule + .knowledge/ scaffold. Content only; tooling stays global.
---

# /knowledge-init (Windsurf / Devin Desktop workflow)

Thin entry point, installed as a **global workflow** (`~/.codeium/windsurf/global_workflows/`).
The full procedure is shared across platforms and lives in the global assets dir installed by the
one-time install script — workflows have no assets folder of their own, so everything is referenced
by absolute path under the user's home directory.

Read and execute, step by step:

- `~/.knowledge-system/workflows/knowledge-init.md`
  (Windows: `%USERPROFILE%\.knowledge-system\workflows\knowledge-init.md`)

with `surface = windsurf`. It is authoritative — do not improvise around its idempotency rules, the
content-only rule (no scripts or templates are ever copied into the repo), or the git wiring. On
this surface the contract installs as an always-on rule file (`.devin/rules/knowledge-contract.md`,
or legacy `.windsurf/rules/`), not into `CLAUDE.md` — unless the repo also shows Claude Code use.

If the procedure file is missing, the global install hasn't been run — point the user at the
knowledge-system README's one-time install (`install.sh` / `install.ps1` from the skills repo).
