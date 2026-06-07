<!-- KNOWLEDGE-SYSTEM CONTRACT v1 — paste into the target repo's resident prompt
     (Claude Code CLAUDE.md, Windsurf/Devin .devin/rules/*.md, …). Keep it whole; it is
     deliberately a thin trigger-table, not the spec. Heavy detail lives in the cards,
     loaded on demand. -->

## Repo knowledge base (`.knowledge/`)

This repo carries durable, hard-won knowledge in `.knowledge/` directories — one at the repo
root, one per app/lib. It is load-bearing memory from past sessions. Fire these four reflexes
**without being asked**:

1. **Task start — read the map.** Before any non-trivial task, read the root
   `.knowledge/index.md` (the cross-package TOC — one line per card, *including packages you
   never open*) and the relevant glossary via `.knowledge/CONTEXT-MAP.md`. Open only the cards
   whose summary matches the task.

2. **File-trace — read local knowledge.** The first time you open or trace into a file under a
   package (e.g. you follow a util into `libs/auth/…`), read that package's `.knowledge/index.md`
   and `.knowledge/CONTEXT.md` **before trusting the code**. Once per package per session.

3. **Decision gate (mandatory) — check rationale before switching approaches.** Before you
   propose, switch to, or re-attempt an approach on a topic, scan the indexes for `type: rationale`
   cards on that topic. If a card names the approach you're about to take as **rejected**, STOP and
   surface it to the user *before writing any code*:
   > ⚠ Prior decision: chose **X** over **<your approach>** (rejected: <reason>). Still valid while
   > <condition>. Proceed with <your approach> anyway?

   Never silently re-walk a rejected design. This gate is not optional and not a passive lookup.

4. **Capture — draft worthy knowledge as it arises.** Two draft kinds, both staged to the local
   `.knowledge/inbox/` *at the moment you learn it* (record `refs` and `source` then — you won't
   know them at session end). Do **not** interrupt the task to ask.
   - **A fact** that is both **Hidden** (not cheaply re-derivable from the code, a search, or
     general knowledge) **and Costly** (getting it wrong wastes real time or breaks things) → a
     **card**. Triggers: a choice between real alternatives → `rationale`; expected X, code did Y →
     `gotcha`; relied on a non-local invariant → `architecture`; learned a command by trial →
     `operational`; the user *stated* something non-obvious → `source: user-stated`.
   - **A term** unique to *this* repo's domain whose meaning isn't obvious from its name → one
     **glossary draft per term** (`kind: glossary`, with `term:` and `definition:` fields, plus
     `avoid:` when known), not a card — one file per term, never several bundled in one.
     Apply the scope rule ruthlessly: a **general programming concept never qualifies** — *debounce,
     retry, cache, pagination, timeout* are out, even when used heavily or compounded with a local
     noun (*"order cache"* is still just a cache). Only a name **coined inside this codebase**
     for a domain concept is in. The one question: would any competent engineer already know this
     word? If yes, skip it. Also draft one when you must **sharpen** a fuzzy/overloaded term (record
     displaced synonyms in `avoid`). Glossary entries are vocabulary only — never implementation
     detail (that's a card).

   At task end (or before compaction), present **one** batched approval of all drafts. The human
   runs `/knowledge-materialize` to commit them to the base.

A bad card is worse than no card, and a general-programming term is not glossary-worthy — don't
capture the trivial. You only ever write to the local `inbox/`; the committed base is changed solely
by the human-invoked `materialize` workflow.
