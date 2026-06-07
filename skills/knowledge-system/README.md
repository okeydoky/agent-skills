# Repo Knowledge System

Give your coding agent a **memory that lives in your repo**. It captures hard-won facts — why a
design was rejected, a function that returns `undefined` instead of throwing, a deploy step you only
learn by breaking it — as small markdown cards under `.knowledge/`, and surfaces them automatically
in future sessions. No database, no embeddings: just markdown your agent reads.

The headline feature is the **decision gate**: before your agent re-attempts an approach someone
already rejected, it stops and tells you why it was rejected — *before* writing the code.

Works with **Claude Code** (and any agent that loads a resident prompt, e.g. Windsurf).

---

## Requirements

- **Node.js** (any recent version) — used to regenerate the knowledge index. Check: `node -v`.
- A coding agent that loads a per-repo instruction file (Claude Code reads `CLAUDE.md`).

## Install (one time, global)

Clone this repo, then from inside it run the installer for your OS:

```bash
# macOS / Linux
sh install.sh
```
```powershell
# Windows (PowerShell)
./install.ps1
```

This makes `/knowledge-init` and `/knowledge-materialize` available in **every** repo (it copies the
slash commands to `~/.claude/commands/` and the assets to `~/.claude/knowledge-system/`). Re-run it
anytime to update to a newer clone.

> **Not on Claude Code?** The install is just file copies. Put `contract/knowledge-contract.md` into
> your agent's resident prompt manually, and run the steps in `skill/commands/*.md` by hand. See
> [Other environments](#other-environments).

## Set up a repo

Inside any repo you want to give a memory:

```
/knowledge-init
```

That installs the always-on **contract** into the repo's `CLAUDE.md`, scaffolds a `.knowledge/`
folder, copies in the index tool, and adds the inbox to `.gitignore`. Commit the result so your
teammates get the same memory. (Run it once per repo; it's safe to re-run.)

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
the index. That's the whole loop — your repo's knowledge compounds every session.

## What gets created in your repo

```
.knowledge/
  CONTEXT-MAP.md          # routes to each package's glossary
  index.md                # the cross-package TOC (generated — never hand-edit)
  cards/                  # cross-cutting fact cards
  inbox/                  # local drafts, pre-approval (gitignored)
  _tools/build-index.mjs  # the index generator
apps/web/.knowledge/      # per-package knowledge is created lazily, as cards are added
libs/auth/.knowledge/
CLAUDE.md                 # now contains the knowledge contract
```

A card is one markdown file with a little frontmatter and a `Fact / Why it matters / How to apply`
body. See `templates/` for the shapes.

## Other environments

The contract (`contract/knowledge-contract.md`) is plain markdown — only *where you paste it*
differs:

- **Claude Code** — `/knowledge-init` puts it in `CLAUDE.md` (handled for you).
- **Windsurf / Devin Desktop** (Windsurf became Devin Desktop in June 2026) — if you also run
  Claude Code, `/knowledge-init` installs the contract as an always-on rule file under
  `.devin/rules/` (or `.windsurf/rules/` for older installs) — both are read by Devin Desktop.
  Otherwise drop `contract/knowledge-contract.md` into `.devin/rules/knowledge-contract.md`
  yourself with `--- trigger: always_on ---` frontmatter. Run the `skill/commands/*.md` steps
  manually for now.
- **Anything else** — paste it into whatever file your agent always loads.

## Want the why?

[`DESIGN.md`](DESIGN.md) is the full spec; maintainer/build notes live in
[`DEVELOPMENT.md`](DEVELOPMENT.md).
