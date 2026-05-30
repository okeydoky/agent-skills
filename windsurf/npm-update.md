---
description: Update an npm repo to its newest compatible dependencies — framework migrations, conflict resolution, breaking-change fixes, verified by a clean fresh install + green build.
---

# /npm-update (Windsurf workflow)

Front-end for the npm-update workflow. The full procedure and the bundled helper
are shared with the Claude Code skill; this file is the Windsurf entry point.

## Setup

Point `HELPER` at the bundled helper by **absolute path** (Windsurf workflows have
no reliable `$0`):

```
HELPER="<absolute path>/bin/npm-update-helper.mjs"
node "$HELPER" scan --cwd "$(pwd)"
```

If you keep this repo at, say, `~/tools/npm-update/`, then
`HELPER=~/tools/npm-update/bin/npm-update-helper.mjs`.

## Procedure

Read and execute **`npm-update.md`** (sibling file, one directory up:
`../npm-update.md`) step by step. It is authoritative. Do not improvise around
the two-phase install gate, the major-version research pause, the A/B/C/D conflict
gate, or the anti-cheat guards on the breaking-change fix loop.

## Quick reference

| Step | Helper call |
|------|-------------|
| Scope | `node "$HELPER" scan --cwd REPO` |
| Classify | `node "$HELPER" classify --cwd REPO` |
| Validate (cheap) | `node "$HELPER" validate --cwd REPO` |
| @types/node | `node "$HELPER" node-check --cwd REPO` |

Real install (the ship gate) and migrations are plain `npm`/`nx`/`ng` commands —
see `npm-update.md` steps 8–9.
