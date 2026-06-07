# Development notes (maintainer-facing)

How this repo is built and where v1 stands. End users want [`README.md`](README.md); the design
rationale is in [`DESIGN.md`](DESIGN.md) / [`DESIGN-NOTES.md`](DESIGN-NOTES.md) (19 locked decisions).

This repo is the **distributable**: a one-time global install (`install.sh` / `install.ps1`) makes
the workflows available everywhere, and per-repo `/knowledge-init` installs the contract + scaffold.

## Layout

```
contract/knowledge-contract.md   # the always-on agent contract (installed into CLAUDE.md and/or .devin/rules/)
skill/commands/                  # the human-invoked workflows (knowledge-init, knowledge-materialize)
tools/build-index.mjs            # deterministic index generator (the build-artifact writer)
templates/                       # card.md, card-rationale.md, inbox-draft.md, glossary-draft.md, CONTEXT.md, CONTEXT-MAP.md
install.sh / install.ps1         # one-time global install
eval/EVAL.md                     # behavioral eval — THE first build step (dec. 19)
eval/fixture/                    # self-contained synthetic monorepo the eval runs against
```

## The two surfaces (DESIGN.md §4.1)

1. **Always-on contract** — `contract/knowledge-contract.md`, a thin trigger-table that makes the
   agent fire four reflexes: read the root TOC at task start, file-trace into a package's
   `.knowledge/` on first touch, run the **decision gate** before switching approaches, and draft
   worthy facts to a local `inbox/`.
2. **Human-invoked workflows** — `knowledge-materialize` (the sole writer to the committed base:
   batched approval → dedup → write cards → regenerate the index via `build-index.mjs`) and
   `knowledge-init` (install the contract + scaffold `.knowledge/` into a target repo). LLM workflow
   prompts in the second-brain `.claude/commands/*.md` style.

## v1 build order

1. **[done] Eval + minimal contract + fixture** — validated the risky behavioral bet first
   (`eval/EVAL.md`, run 2026-06-06: all 4 scenarios PASS).
2. **[done] `init` + `materialize` workflows** — `skill/commands/`.
3. **[done] Global-install model** — `install.sh` / `install.ps1`; `init` defaults its asset source
   to `~/.claude/knowledge-system/`.

Deferred to v2 (zero migration cost — the index/glossary are regenerated): lint, stats, index
volume-sharding, per-type machinery for `architecture`/`operational`, a standalone in-loop skill.

## Running the eval

Open a fresh session rooted at `eval/fixture/` and walk S1–S4 in [`eval/EVAL.md`](eval/EVAL.md).
Re-run after any contract edit — the contract reliably firing the reflexes is the whole v1 bet.

## Regenerating an index

```
node tools/build-index.mjs <repo-root>      # writes every .knowledge/index.md from card frontmatter
```
The index is a build artifact — never hand-edit it. The script is idempotent and reports (exit 1)
any card whose frontmatter it couldn't parse rather than silently dropping it.
