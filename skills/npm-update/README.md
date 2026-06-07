# npm-update

A global, prompt-driven workflow that updates an npm repo to its newest
**compatible** dependencies — running framework migrations, resolving conflicts,
fixing breaking changes, and proving a clean fresh install + green build before
committing. Built for Nx + Angular + NestJS/Express monorepos; degrades to any
plain npm repo.

Two parts:

- **`npm-update.md`** — the workflow the agent executes (11 steps).
- **`bin/npm-update-helper.mjs`** — bundled Node helper for the deterministic
  mechanics (`scan` / `classify` / `validate` / `node-check`). Pure logic lives in
  `lib/`, the thin IO shell in `bin/`. No runtime dependencies; Node ≥ 18.

## Helper commands

```
node bin/npm-update-helper.mjs scan        [--cwd DIR]
node bin/npm-update-helper.mjs classify    [--cwd DIR] [--input scan.json] [--concurrency N]
node bin/npm-update-helper.mjs validate    [--cwd DIR]
node bin/npm-update-helper.mjs node-check  [--cwd DIR]
```

All commands print JSON to stdout. `classify` defers Angular/Nx framework versions
to `nx migrate` / `ng update` (it only *detects* framework-managed packages);
`validate` is the cheap `--package-lock-only` phase of the two-phase install gate.

## Install

### Claude Code (skill)

Copy/symlink this directory to `~/.claude/skills/npm-update/` so it contains
`SKILL.md` + `bin/` + `lib/` + `npm-update.md`. Invoke with `/npm-update`.

### Windsurf (workflow)

Place `windsurf/npm-update.md` at `~/.codeium/windsurf/workflows/npm-update.md`
(global) or `.windsurf/workflows/npm-update.md` (per-repo), and set the absolute
`HELPER` path inside it. Invoke with `/npm-update`.

## Develop / test

```
npm test          # node --test — pure-function unit tests, no network
```

## Scope (v1)

In scope: single-root-package npm repos via three migration paths — Nx
(`nx migrate`), non-Nx Angular (`ng update`), and plain npm (manual majors).

Out of scope: npm/yarn/pnpm workspaces (detected → stop), a `--safe`
within-ranges mode, yarn/pnpm. A golden-repo end-to-end test is the top deferred
item (see the design doc's TODOS).

## Design

The full design, eng-review decisions (T1 two-phase gate, T2 bounded fix loop,
T3 single-source framework versions), failure modes, and test plan live in the
gstack project notes for `npm-updater`.
