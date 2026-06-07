---
name: npm-update
description: >-
  Update an npm repo to its newest compatible dependencies: scan/classify deps,
  run framework migrations (nx migrate / ng update), resolve conflicts, fix
  breaking changes, and prove a clean fresh install + green build before
  committing. Use for Nx/Angular/NestJS monorepos or any npm repo when the user
  asks to update, upgrade, or bump dependencies to latest.
---

# npm-update

This skill brings an npm repo to its newest **compatible** dependencies the
careful way: framework migrations are run, conflicts are surfaced (not swallowed),
breaking changes are fixed under anti-cheat guards, and the result must pass a
fresh `npm install` + `build` before anything is committed.

## How to run it

1. The deterministic mechanics live in the bundled helper. Set its absolute path:

   ```
   HELPER="$(dirname "$0")/bin/npm-update-helper.mjs"
   # When installed as a Claude skill this is:
   #   ~/.claude/skills/npm-update/bin/npm-update-helper.mjs
   ```

2. Follow the full procedure in **[`npm-update.md`](./npm-update.md)** — read it
   now and execute its 11 steps in order. It defines every helper call, the
   two-phase install gate, the major-version research pause, the conflict
   A/B/C/D decision gate, the bounded breaking-change fix loop with anti-cheat
   guards, and the checkpoint-commit points.

## Non-negotiables (summary — `npm-update.md` is authoritative)

- **Framework versions** are decided by `nx migrate` / `ng update`, never by you.
  The helper only *tags* framework-managed packages so you defer them.
- **Ship gate** is a fresh `npm install` of the final, post-migration manifest —
  not the cheap dry-run. Re-validate after migrations touch deps. Commit the
  generated lockfile.
- **Build is the only blocking gate**; lint/test are non-blocking warnings.
- **Never force a green build** by downgrading bumped deps, deleting/stubbing
  code, or weakening configs. If you can't fix it honestly within the budget,
  stop and surface it.
- **Out of scope (v1):** multi-package-json / npm workspaces — detect and stop.
