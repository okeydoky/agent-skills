# Development notes (maintainer-facing)

How this repo is built and where v1 stands. End users want [`README.md`](README.md); the design
rationale is in [`DESIGN.md`](DESIGN.md) / [`DESIGN-NOTES.md`](DESIGN-NOTES.md) (19 locked decisions).

This repo is the **distributable**: a one-time global install (`install.sh` / `install.ps1`) puts
the shared assets at `~/.knowledge-system/` and thin front-ends into each platform's global command
location; per-repo `/knowledge-init` installs the contract + a content-only scaffold (no tooling
ever lands in a target repo).

## Layout

```
contract/knowledge-contract.md   # the always-on agent contract (installed into CLAUDE.md and/or .devin/rules/)
workflows/                       # the SHARED human-invoked procedures (knowledge-init, knowledge-materialize)
frontends/claude/                # thin slash-command pointers -> ~/.claude/commands/
frontends/windsurf/              # thin workflow pointers -> ~/.codeium/windsurf/global_workflows/
tools/build-index.mjs            # deterministic index generator (the build-artifact writer)
templates/                       # card.md, card-rationale.md, inbox-draft.md, glossary-draft.md, CONTEXT.md, CONTEXT-MAP.md
install.sh / install.ps1         # one-time global install ([claude|windsurf|all], auto-detects by default)
eval/EVAL.md                     # behavioral eval — THE first build step (dec. 19)
eval/fixture/                    # self-contained synthetic monorepo the eval runs against
```

After install, `~/.knowledge-system/` mirrors `contract/ tools/ templates/ workflows/`. The
front-ends are pointers ("read and execute `~/.knowledge-system/workflows/<name>.md`"), so the
procedures have a single source of truth across platforms and updates are install-only — target
repos carry content (contract, `.knowledge/` cards/glossaries/index), never scripts or templates.

## The two surfaces (DESIGN.md §4.1)

1. **Always-on contract** — `contract/knowledge-contract.md`, a thin trigger-table that makes the
   agent fire four reflexes: read the root TOC at task start, file-trace into a package's
   `.knowledge/` on first touch, run the **decision gate** before switching approaches, and draft
   worthy facts to a local `inbox/`. Injection point per platform: `CLAUDE.md` (Claude Code) or an
   `always_on` rule at `.devin/rules/knowledge-contract.md` (Windsurf/Devin Desktop; legacy
   `.windsurf/rules/` also read).
2. **Human-invoked workflows** — `knowledge-materialize` (the sole writer to the committed base:
   batched approval → dedup → write cards → regenerate the index via the global
   `~/.knowledge-system/tools/build-index.mjs`) and `knowledge-init` (install the contract +
   content-only scaffold into a target repo).

## v1 build order

1. **[done] Eval + minimal contract + fixture** — validated the risky behavioral bet first
   (`eval/EVAL.md`, run 2026-06-06: all 4 scenarios PASS).
2. **[done] `init` + `materialize` workflows** — now `workflows/`.
3. **[done] Global-install model** — `install.sh` / `install.ps1`.
4. **[done 2026-06-09] Platform split + content-only repos** — shared core + `frontends/claude/` +
   `frontends/windsurf/`; assets moved `~/.claude/knowledge-system/` → `~/.knowledge-system/`;
   `init` no longer copies `_tools/`/`_templates/`/commands into repos (and deletes legacy copies
   on re-run). Rationale and the fork-vs-front-end evaluation: DESIGN-NOTES.md "Increment 4".

Deferred to v2 (zero migration cost — the index/glossary are regenerated): lint, stats, index
volume-sharding, per-type machinery for `architecture`/`operational`, a standalone in-loop skill.

## Running the eval

Open a fresh session rooted at `eval/fixture/` and walk S1–S5 in [`eval/EVAL.md`](eval/EVAL.md).
Re-run after any contract edit — the contract reliably firing the reflexes is the whole v1 bet.

## Regenerating an index

```
node tools/build-index.mjs <repo-root>      # writes every .knowledge/index.md from card frontmatter
```
The index is a build artifact — never hand-edit it. The script is idempotent and reports (exit 1)
any card whose frontmatter it couldn't parse rather than silently dropping it. End users run the
installed copy: `node ~/.knowledge-system/tools/build-index.mjs .`
