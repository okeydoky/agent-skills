# npm-update — workflow

Bring an npm repo to its newest **compatible** dependencies, run all framework
migrations, fix the resulting breaking changes, and prove the result is clean
before committing. Optimized for Nx + Angular + NestJS/Express monorepos;
degrades gracefully to any plain npm repo.

This is the procedure the agent follows. The deterministic mechanics live in the
bundled helper `bin/npm-update-helper.mjs` (referenced below as `HELPER`); the
judgment, research, and code-fixing are the agent's job. Set:

```
HELPER="<absolute path to>/bin/npm-update-helper.mjs"   # e.g. ~/.claude/skills/npm-update/bin/npm-update-helper.mjs
node "$HELPER" <command> [--cwd REPO] [...]
```

All helper commands print JSON to stdout. Run them from (or point `--cwd` at) the
repo root.

---

## Operating principles (read first)

- **Two sources of truth, kept separate (T3).** For Angular/Nx packages, the
  migration tool (`nx migrate` / `ng update`) decides versions — never the agent,
  never the helper. The helper only *tags* those packages so you know to defer
  them. The agent hand-resolves only the plain "manual world".
- **Two-phase gate (T1).** The cheap `--package-lock-only` check (`validate`) is
  for *iterating* conflict resolution. The real ship gate is a fresh
  `npm install` of the **final, post-migration** manifest. Re-validate after
  migrations if they touched dependencies. Commit the lockfile npm generates.
- **Build is the only blocking gate.** `lint` and `test` run but are non-blocking
  (reported as warnings). Older repos often lack a clean test setup.
- **Never force green.** The fix loop (step 10) is bounded and guarded. If it
  can't reach a clean build honestly, it stops and surfaces — it does not
  downgrade, delete, or stub its way to green.
- **Checkpoint commits** after steps 4, 8, and 9 so a killed run resumes from the
  last green phase (git is the state store).
- **Surface, don't swallow.** Every unresolved conflict goes to the user as
  A) downgrade · B) override · C) abort · D) discuss.

---

## Step 1 — Preflight

1. Confirm a clean git working tree (`git status`). If dirty, ask the user to
   stash/commit first.
2. If this is a git repo, create a branch: `chore/dep-update-<YYYYMMDD>`. If it is
   **not** a git repo, WARN that there is no branch isolation and ask to proceed.
3. Record `node --version` and `npm --version` for the summary.

## Step 2 — Scope

```
node "$HELPER" scan --cwd REPO
```

- If `stop` is true (`stopReason` mentions workspaces/multiple package.json),
  **STOP**: multi-package-json / workspaces is out of scope for v1.
- Read `migrationPath` (`nx` | `ng` | `plain`) — it selects the migration path in
  step 4.
- Note `outdated[]`: `isMajor` entries feed step 3; `type` and names feed
  classification.

```
node "$HELPER" classify --cwd REPO
```

- `packages[]` tags each outdated dep: `framework-managed` (defer its version to
  the migrate tool), `peer-pinned` (typescript/zone.js/rxjs — do NOT blind-bump),
  or `manual` (the agent/helper resolves it).
- `frameworkGroups[]` shows which carrier pulls which siblings (for the summary).

## Step 2b — Prune stale overrides

If `package.json` has an `overrides` section, for **each** entry: remove it, run
`validate` (step 6 mechanics), and if the tree still resolves clean, leave it
removed (it was stale). Keep only overrides that are still load-bearing. Record
what was pruned for the step-7 summary.

## Step 3 — Research majors (pause gate)

For each `isMajor` package the user cares about:

1. Read its changelog / migration guide (web search as backup).
2. Assess the code impact in this repo.
3. Present findings and get an explicit **go / no-go per package**. A "no-go"
   means that package stays at its current major (success-criterion reason (b)).

Do this *before* touching the manifest.

## Step 4 — Framework migrate (path-dependent)

- `migrationPath === 'nx'`: run **one** `nx migrate latest`. Do NOT run a second
  `nx migrate @angular/cli` — it overwrites `migrations.json`. Save the generated
  `migrations.json` aside.
- `migrationPath === 'ng'`: run `ng update` for the Angular set (it applies
  migrations inline).
- `migrationPath === 'plain'`: skip — no schematics.

**Abort gate (Issue 2):** if `nx migrate` pins a main package (Angular / a Nest
plugin) **below its newest major** and that block is what prevents reaching the
newest major the user approved in step 3 → **WARN and ABORT**. Do not silently
settle for the old major. (A patch/minor lag *within* the latest major that Nx
chose is acceptable — that's reason (a), not a block.)

Do **not** install yet. **Checkpoint-commit** the clean migrate.

## Step 5 — Manual-world bumps

For `manual`-tagged packages only:

- Bump to the newest version the user approved (majors gated by step 3).
- **Exclude `peer-pinned`** (typescript, zone.js, rxjs) — the framework migration
  sets those.
- Handle `@types/node` via `node "$HELPER" node-check --cwd REPO`; bump only to
  match the local node major unless the user opts out.

## Step 6 — Cheap conflict loop (gate phase 1, T1)

```
node "$HELPER" validate --cwd REPO
```

(The helper moves the lockfile aside, runs `npm install --package-lock-only`,
parses ERESOLVE, and restores the lockfile.)

- `clean: true` → proceed to step 7.
- `clean: false` → present the parsed `conflict` to the user as **A) downgrade ·
  B) add override · C) abort · D) discuss**. Apply the choice and re-run
  `validate`. Loop until clean. This is cheap iteration, *not* the ship gate.

## Step 7 — Summary + confirm

Present, and get final approval:

- Packages that could **not** reach latest, each with its reason: (a) framework
  compatibility block, or (b) user chose to keep it.
- Overrides **added** this run, and overrides **pruned** in step 2b.
- The node/npm versions and migration path used.

## Step 8 — Real install (gate phase 2 — the actual ship gate, T1)

```
rm -rf node_modules package-lock.json   # delete both for a fresh resolve
npm install --cwd REPO                   # or: (cd REPO && npm install)
```

- If this throws **ERESOLVE**, the cheap projection lied — go back to step 6 with
  the real error and resolve it for real.
- On success, the generated `package-lock.json` is the committed, reproducible
  artifact. **Checkpoint-commit** the green install.

## Step 9 — Run migrations + re-validate (T1)

- `nx`: `nx migrate --run-migrations=migrations.json`.
- `ng`: migrations were already applied by `ng update` in step 4.
- `plain`: none.

**If migrations changed any dependency** (check `git diff package.json
package-lock.json`), re-run the real install (step 8 mechanics) so the committed
lockfile reflects the post-migration manifest. **Checkpoint-commit** after
migrations.

## Step 10 — Fix breaking changes (bounded loop, T2)

Iterate until `build` is green, under a **fixed cycle budget** (default: 6
build→fix cycles; adjust by repo size, state it up front).

Each cycle: run the build → parse the errors → make targeted source fixes →
rebuild.

**Hard anti-cheat guards — violating any of these is a STOP, never a pass:**

- Never **downgrade** a dependency the workflow just bumped.
- Never **delete or stub** failing code/call-sites to make errors disappear.
- Never **weaken** tsconfig / type declarations / lint configs to hide errors.

If the build is green within budget → proceed. If the **budget is exhausted**,
**STOP** and surface the remaining breakages with a diagnosis and suggested
direction for the user to decide. Do not force green.

## Step 11 — Verify

- **Blocking:** `build` must be green (`nx affected -t build` / `nx run-many -t
  build`, or `npm run build`).
- **Non-blocking:** run `lint` and `test`; report failures as **warnings**, do not
  block on them.
- Final `node "$HELPER" scan` sanity check: `outdated` should be near-empty;
  anything left must map to reason (a) or (b) from step 7.
- Commit. Summarize the run on the branch/PR description: what moved, what stayed
  and why, overrides added/pruned, migrations run, gate results.

---

## Success criteria (what "done" means)

1. A fresh `npm install` (node_modules + lockfile deleted) throws **no** dependency
   conflict errors. *(Guaranteed by the step-8 real-install gate.)*
2. `npm outdated` is near-empty; every remaining entry is reason (a) framework
   block or (b) user choice.
3. All migration scripts collected during the run were executed (step 9).
4. Breaking changes are fixed and the repo **builds** green — honestly, within the
   step-10 guards.
