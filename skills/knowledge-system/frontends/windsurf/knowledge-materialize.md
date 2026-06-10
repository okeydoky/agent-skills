---
description: Review the pending knowledge drafts in .knowledge/inbox/ and commit the approved ones to the knowledge base, then regenerate the index.
---

# /knowledge-materialize (Windsurf / Devin Desktop workflow)

Thin entry point, installed as a **global workflow** (`~/.codeium/windsurf/global_workflows/`).
The full procedure is shared across platforms and lives in the global assets dir installed by the
one-time install script.

Read and execute, step by step:

- `~/.knowledge-system/workflows/knowledge-materialize.md`
  (Windows: `%USERPROFILE%\.knowledge-system\workflows\knowledge-materialize.md`)

It is authoritative — do not improvise around the single-batched approval, the dedup/contradiction
checks, the single-writer rule, or the index regeneration (which uses the **global**
`~/.knowledge-system/tools/build-index.mjs`; initialized repos carry no tooling).

If the procedure file is missing, the global install hasn't been run — point the user at the
knowledge-system README's one-time install (`install.sh` / `install.ps1` from the skills repo).
