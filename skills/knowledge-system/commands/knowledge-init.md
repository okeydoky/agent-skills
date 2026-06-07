Install the repo-knowledge system into the current repo (the **target**): the always-on contract,
the root `.knowledge/` scaffold, and the regen tool. Run once per repo. Idempotent — safe to re-run;
it skips anything already in place.

This command is meant to be **installed globally** (`~/.claude/commands/`) so you can run
`/knowledge-init` inside any repo (see the one-time global install in the README). The *commands*
are global; the *contract, scaffold, and tool* this installs are per-repo so they travel with the
repo for teammates.

`$ARGUMENTS` = path to the knowledge-system assets (a dir holding `contract/`, `tools/`,
`templates/`, `commands/`). **Defaults to the global install at `~/.claude/knowledge-system/`**
(Windows: `%USERPROFILE%\.claude\knowledge-system\`). Pass a path to override (e.g. a fresh clone).

## Steps

1. **Locate sources.** Resolve the assets path from `$ARGUMENTS`, else default to
   `~/.claude/knowledge-system/`. Confirm it has `contract/knowledge-contract.md`,
   `tools/build-index.mjs`, and `templates/`. If it's missing, tell the user to run the one-time
   global install (README) or pass a clone path. The **target** is the current working directory.

2. **Install the always-on contract** into the target's resident prompt. Do the **Claude Code**
   surface by default; also do the **Windsurf / Devin** surface when the repo shows it's used there
   (a `.devin/` or `.windsurf/` directory already exists) or the user asks.

   **Claude Code** → append `contract/knowledge-contract.md` to the target's `CLAUDE.md` (create it
   if missing), wrapped in markers so re-runs are idempotent:
   ```
   <!-- BEGIN knowledge-contract v1 -->
   …contents of contract/knowledge-contract.md…
   <!-- END knowledge-contract v1 -->
   ```
   If the BEGIN marker already exists, replace the block (don't duplicate).

   **Windsurf / Devin Desktop** (Windsurf rebranded to Devin Desktop on 2026-06-02; both read the
   same rule files) → install the contract as its own **always-on rule file**. Pick the directory:
   - `.devin/rules/` if a `.devin/` dir already exists, else `.windsurf/rules/` if a `.windsurf/`
     dir exists, else default to **`.devin/rules/`** — the current preferred location, which Devin
     Desktop reads natively. (`.windsurf/rules/` is the legacy fallback that older Windsurf installs
     still read; Devin Desktop reads it too, with `.devin/` taking precedence on conflicts.)
   - Create the dir if needed and write `knowledge-contract.md` there, with always-on frontmatter
     prepended so it loads on every message:
     ```
     ---
     trigger: always_on
     ---
     …contents of contract/knowledge-contract.md…
     ```
     The valid `trigger` values are `always_on` / `model_decision` / `glob` / `manual`; we need
     `always_on`. The file is dedicated to the contract, so re-runs just overwrite it (no markers
     needed). Workspace rule files are capped at 12,000 chars — the contract is well under.

3. **Make the workflows available to the repo.** If the commands are already installed globally
   (`~/.claude/commands/`), they work here already — but also copy `commands/*.md` into the
   target's `.claude/commands/` so teammates **without** the global install can run
   `/knowledge-materialize`. (Skip only if the user says this repo is solo.) Source them from the
   assets dir's `commands/`, or from the global `~/.claude/commands/` if the assets dir
   doesn't carry them.

4. **Scaffold the root `.knowledge/` store:**
   ```
   .knowledge/
     CONTEXT-MAP.md          # from templates/ (stub: lists packages as they appear)
     cards/.gitkeep          # cross-cutting cards land here
     inbox/.gitkeep          # local drafts (gitignored)
     _tools/build-index.mjs  # copied from the distributable's tools/
     _templates/             # copied from the distributable's templates/
   ```
   Do **not** pre-create per-package `.knowledge/` dirs — they're created lazily by `materialize`
   when the first card routes into a package (anti-bloat / lazy file creation).

5. **Generate the initial index:**
   ```
   node .knowledge/_tools/build-index.mjs
   ```
   (writes an empty-but-valid root `.knowledge/index.md`).

6. **Wire git.**
   - `.gitignore` — ensure this line exists in the target's `.gitignore`:
     ```
     **/.knowledge/inbox/
     ```
     (Drafts are local and pre-approval — never committed. The committed base has one writer:
     `materialize`.)
   - `.gitattributes` — ensure this line exists so the regenerated index has stable line endings:
     ```
     **/.knowledge/** text eol=lf
     ```
     `build-index.mjs` writes LF; without this, repos with `core.autocrlf=true` show EOL-only churn
     on every `materialize`. (If the repo already has knowledge files, run
     `git add --renormalize .knowledge/` once after adding the rule.)

7. **Report:** which surfaces were installed, where the contract landed, and the one next action —
   *"start a session; the contract will fire the four reflexes; run `/knowledge-materialize` at
   session end to persist captures."*

## Notes

- The contract is environment-agnostic markdown; only the injection point in step 2 differs per env.
- `node` is required at the target for index regeneration (the index is a deterministic build
  artifact). If Node isn't available, say so — it's a hard dependency for `materialize`.
- Verify by reading `eval/EVAL.md` in the distributable: the installed contract is the same one that
  passed the behavioral eval.
