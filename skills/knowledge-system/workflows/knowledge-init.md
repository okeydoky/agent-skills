Install the repo-knowledge system into the current repo (the **target**): the always-on contract
and the root `.knowledge/` scaffold. Run once per repo. Idempotent — safe to re-run; it skips
anything already in place and cleans up artifacts from older versions.

This is the **shared procedure**; you normally reach it through a thin platform front-end
(`/knowledge-init` in Claude Code or in Windsurf/Devin Desktop — see the one-time global install in
the README). The front-end tells you which `surface` you're on.

**The repo gets content only — never scripts or templates.** Tooling (`build-index.mjs`),
templates, and these procedures live in the **global assets dir** and stay there, so updating the
skill never requires touching initialized repos:

- `ASSETS` = `~/.knowledge-system/` (Windows: `%USERPROFILE%\.knowledge-system\`),
  overridable via `$ARGUMENTS` (e.g. a fresh clone's `skills/knowledge-system/`).

## Steps

1. **Locate sources.** Resolve `ASSETS` from `$ARGUMENTS`, else the default above. Confirm it has
   `contract/knowledge-contract.md`, `tools/build-index.mjs`, and `templates/`. If missing, tell
   the user to run the one-time global install (README) or pass a clone path. The **target** is the
   current working directory.

2. **Install the always-on contract** into the target's resident prompt. Do the surface the
   front-end named; *also* do the other surface when the repo shows it's used there (a `CLAUDE.md`,
   `.devin/`, or `.windsurf/` already exists) or the user asks.

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
     dir exists, else default to **`.devin/rules/`** — the preferred location per current Devin
     Desktop docs (`.windsurf/rules/` is the legacy fallback; both are read, `.devin/` wins on
     conflicts).
   - Create the dir if needed and write `knowledge-contract.md` there, with always-on frontmatter
     prepended so it loads on every message:
     ```
     ---
     trigger: always_on
     ---
     …contents of contract/knowledge-contract.md…
     ```
     Valid `trigger` values are `always_on` / `model_decision` / `glob` / `manual`; we need
     `always_on`. The file is dedicated to the contract, so re-runs just overwrite it (no markers
     needed). Workspace rule files are capped at 12,000 chars — the contract is well under.

3. **Scaffold the root `.knowledge/` store** (content only):
   ```
   .knowledge/
     CONTEXT-MAP.md          # from ASSETS/templates/ (stub: lists packages as they appear)
     cards/.gitkeep          # cross-cutting cards land here
     inbox/.gitkeep          # local drafts (gitignored)
   ```
   Do **not** copy `tools/`, `templates/`, or any workflow file into the repo — they stay global.
   Do **not** pre-create per-package `.knowledge/` dirs — they're created lazily by `materialize`
   when the first card routes into a package (anti-bloat / lazy file creation).

   **Legacy cleanup:** if `.knowledge/_tools/` or `.knowledge/_templates/` exist (installed by a
   pre-v1.3 init), delete them — the global assets replace them. Mention it in the report.

4. **Generate the initial index** with the global tool:
   ```
   node ~/.knowledge-system/tools/build-index.mjs .
   ```
   (Windows: `node "$env:USERPROFILE\.knowledge-system\tools\build-index.mjs" .`)
   Writes an empty-but-valid root `.knowledge/index.md`.

5. **Wire git.**
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

6. **Report:** which surfaces were installed, where the contract landed, any legacy files cleaned
   up, and the one next action — *"start a session; the contract will fire the four reflexes; run
   `/knowledge-materialize` at session end to persist captures."* Remind the user that teammates
   need the same one-time global install to run the workflows (the repo itself carries only the
   contract and the knowledge content — both committed, so the *reading* reflexes work for any
   agent that loads the resident prompt, install or not).

## Notes

- The contract is environment-agnostic markdown; only the injection point in step 2 differs per env.
- `node` is required at the target for index regeneration (the index is a deterministic build
  artifact). If Node isn't available, say so — it's a hard dependency for `materialize`.
- Verify by reading `eval/EVAL.md` in the distributable: the installed contract is the same one that
  passed the behavioral eval.
