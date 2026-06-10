# Repo Knowledge System

Give your coding agent a **memory that lives in your repo**. It captures hard-won facts — why a
design was rejected, a function that returns `undefined` instead of throwing, a deploy step you only
learn by breaking it — as small markdown cards under `.knowledge/`, and surfaces them automatically
in future sessions. No database, no embeddings: just markdown your agent reads.

The headline feature is the **decision gate**: before your agent re-attempts an approach someone
already rejected, it stops and tells you why it was rejected — *before* writing the code.

Works with **Claude Code** and **Windsurf / Devin Desktop** via thin per-platform front-ends over
one shared core. Repos initialized with it carry **content only** (the contract and the knowledge
itself) — all tooling, templates, and procedures stay in one global folder, so updating the skill
never touches your repos.

---

## Requirements

- **Node.js** (any recent version) — used to regenerate the knowledge index. Check: `node -v`.
- A coding agent that loads a per-repo instruction file (Claude Code reads `CLAUDE.md`;
  Windsurf/Devin Desktop reads `.devin/rules/` / `.windsurf/rules/`).

## Install (one time, global)

Clone this repo, then from `skills/knowledge-system/` run the installer for your OS:

```bash
# macOS / Linux
sh install.sh            # auto-detects Claude Code and/or Windsurf; or: sh install.sh claude|windsurf|all
```
```powershell
# Windows (PowerShell)
./install.ps1            # same auto-detection; or: ./install.ps1 claude|windsurf|all
```

This puts everything in **user scope** — nothing per-repo yet:

| What | Where | Why |
|---|---|---|
| Shared assets (contract, index tool, templates, the two workflow procedures) | `~/.knowledge-system/` | single source of truth both platforms reference |
| Claude Code front-ends | `~/.claude/commands/` | `/knowledge-init`, `/knowledge-materialize` in every repo |
| Windsurf/Devin Desktop front-ends | `~/.codeium/windsurf/global_workflows/` | same two workflows in every workspace |

Re-run it anytime to update — initialized repos never need touching. (It also removes the legacy
`~/.claude/knowledge-system/` asset dir from older installs.)

## Set up a repo

Inside any repo you want to give a memory, run:

```
/knowledge-init
```

(in either Claude Code or Windsurf/Devin Desktop — it's the same procedure.) It installs the
always-on **contract** into the repo's resident prompt (`CLAUDE.md`, and/or an `always_on` rule in
`.devin/rules/`), scaffolds a `.knowledge/` folder, and adds the inbox to `.gitignore`. **No
scripts or templates are copied into the repo.** Commit the result so your teammates get the same
memory. (Run it once per repo; it's safe to re-run — re-runs also clean up the `_tools/` /
`_templates/` folders that older versions placed in repos.)

## Daily use

You don't invoke anything during work — the contract makes the agent do four things on its own:

| Reflex | What you'll see |
|---|---|
| **Read the map** at task start | it consults `.knowledge/` before diving in |
| **File-trace** | opening a package's code pulls that package's knowledge |
| **Decision gate** | ⚠ it surfaces a prior rejected approach before re-trying it |
| **Capture** | it drafts worthy new facts as they come up (to a local `inbox/`) |

At the **end of a session**, persist what it captured:

```
/knowledge-materialize
```

It shows everything drafted in one batch, you approve/drop, and it writes the cards and regenerates
the index (using the global tool at `~/.knowledge-system/tools/build-index.mjs`). That's the whole
loop — your repo's knowledge compounds every session.

## What gets created in your repo

```
.knowledge/
  CONTEXT-MAP.md          # routes to each package's glossary
  index.md                # the cross-package TOC (generated — never hand-edit)
  cards/                  # cross-cutting fact cards
  inbox/                  # local drafts, pre-approval (gitignored)
apps/web/.knowledge/      # per-package knowledge is created lazily, as cards are added
libs/auth/.knowledge/
CLAUDE.md                 # now contains the knowledge contract (Claude Code surface)
.devin/rules/knowledge-contract.md   # always-on rule (Windsurf/Devin surface, when used)
```

Content only — no tools, no templates. A card is one markdown file with a little frontmatter and a
`Fact / Why it matters / How to apply` body. See `templates/` (in this repo, or installed at
`~/.knowledge-system/templates/`) for the shapes.

**Teammates:** the committed contract + cards mean the *reading* reflexes work for anyone whose
agent loads the resident prompt — no install needed. To run `/knowledge-init` or
`/knowledge-materialize` themselves, they do the same one-time global install.

## How the platform split works

```
skills/knowledge-system/
  contract/   tools/   templates/   workflows/    # the shared, platform-agnostic core
  frontends/claude/                               # 4-line pointer commands → ~/.claude/commands/
  frontends/windsurf/                             # 4-line pointer workflows → global_workflows/
```

The front-ends only say *"read and execute `~/.knowledge-system/workflows/<name>.md`"* — Windsurf
workflows have no assets folder of their own, so everything is referenced by absolute path from the
neutral global dir. One core, two entry points, zero drift.

**Anything else** (another agent that loads a resident prompt): paste
`contract/knowledge-contract.md` into whatever file your agent always loads, and run the steps in
`workflows/*.md` by hand.

## Want the why?

[`DESIGN.md`](DESIGN.md) is the full spec; maintainer/build notes live in
[`DEVELOPMENT.md`](DEVELOPMENT.md).
