Commit the pending knowledge drafts in `.knowledge/inbox/` to the committed knowledge base, then
regenerate the indexes. This is the **management workflow** and the **single writer to the committed
base** (DESIGN.md §4): the ambient capture reflex only ever stages drafts to `inbox/`; this workflow
is where a human deliberately reviews and persists them.

Run it at the end of a session, or whenever drafts have accumulated.

## Steps

1. **Collect drafts.** Find every `.knowledge/inbox/*.md` across the repo (root and per-package).
   If there are none, say so and stop.

2. **One batched approval** (never per-item nagging). Print a single table — one row per draft:

   | # | kind | topic / term | summary / definition | why it's worthy | → store |
   |---|------|--------------|----------------------|-----------------|---------|

   `kind` is the card `type` (`gotcha`/`rationale`/…) or `glossary`. For cards "why it's worthy" is
   the `justification` (Hidden×Costly); for glossary drafts it's the scope rule (unique to this
   repo). The "→ store" is where it lands, decided by `refs`/`context` (step 4). Then ask once:
   > `[a]ll keep · [n]one · or per-item: k <#>… keep, d <#>… drop, e <#> edit`

   Apply the user's choice. Dropped drafts are deleted from `inbox/`. Edits are applied to the
   draft before materializing.

3. **Dedup / contradiction check** (per approved draft):
   - **Cards** (against the target store's `index.md`):
     - **Same claim + new evidence** (same summary intent AND same primary `ref`) → **UPDATE** the
       existing card (merge refs, bump `updated`, raise `confidence` if confirmed). Do not create.
     - **Genuinely new** → **CREATE** (step 4).
     - **Contradicts an existing card** → **surface now**, don't guess:
       > Draft contradicts `<card-id>` ("<its summary>"). Reconcile, supersede it, or drop?
       Act on the answer (supersede → set the old card `status: superseded`, new card
       `supersedes: <old-id>`).
   - **Glossary drafts** (`kind: glossary`, against the target `CONTEXT.md`'s existing terms):
     - **Term already defined** → **SHARPEN** the existing line (merge in a better definition / new
       `avoid` synonyms), don't add a second entry. This is grill-with-docs's "challenge against the
       glossary."
     - **Conflicts with a defined term** (same word, different meaning) → **surface now**:
       > Glossary draft "<term>" conflicts with the existing definition ("<current>"). Reconcile or drop?
     - **New term** → append (step 4).

4. **Materialize each approved draft.** First **branch by kind**: a `kind: glossary` draft is a
   TERM → go to (b); everything else is a fact → a card, (a).

   **(a) Cards:**
   - **Route by refs** (DESIGN.md §2.4): a card lives in the package its `refs` point into. Refs
     spanning >1 package → it's cross-cutting → root `.knowledge/cards/`. Create the target
     package's `.knowledge/{cards/,inbox/}` + `CONTEXT.md` lazily if it doesn't exist yet (and add
     the package to the root `CONTEXT-MAP.md`).
   - **Fill auto-derived fields:** `id` = kebab slug of the title (= filename); `created`/`updated`
     = today; `status: active`; keep the draft's `refs`/`source`/`confidence`/`type`/`topic`/`tags`.
     Enforce the confidence floor (`< ~5` → hold, don't write; tell the user).
   - **Drop `justification`** (it was only for the approval UI).
   - Write `cards/<id>.md` using the body shape (`templates/card.md`, or `card-rationale.md` for
     `type: rationale` → Decision / Rejected / Valid-while).

   **(b) Glossary drafts** (`kind: glossary` — a term, not a fact; they get NO card and NO index line):
   - **Route**, in order: `package:` if set → else the package whose `.knowledge/inbox/` the draft
     sits in → else by `refs`. A term that spans >1 package (or routes nowhere) is cross-cutting →
     the **root** `.knowledge/CONTEXT.md`.
   - Create that `CONTEXT.md` lazily from `_templates/CONTEXT.md` if absent, and register the
     package in the root `CONTEXT-MAP.md` (under `## Contexts`) the first time it gets a term.
   - **Append one line** rendered from the draft's `term` + `definition` (+ `avoid`); drop the
     routing/provenance fields (`kind`/`package`/`refs`/`source`):
     ```
     **<term>** — <definition>. _Avoid:_ <avoid synonyms, if any>
     ```
     If the term already exists, SHARPEN that line in place (step 3) rather than appending.
   - Keep `CONTEXT.md` glossary-only: if a "glossary" draft is really implementation detail or a
     decision, it's a **card** — reclassify it, don't pollute the glossary.

5. **Regenerate the index** (the build artifact — never hand-edit it):
   ```
   node .knowledge/_tools/build-index.mjs
   ```
   This rewrites every `.knowledge/index.md` (local + root aggregator) from card frontmatter.
   If it reports skipped cards, fix their frontmatter and re-run. Glossary-only runs still benefit
   (the index footer links to `CONTEXT.md`), but `CONTEXT.md`/`CONTEXT-MAP.md` are **not** generated
   — you wrote them directly in step 4(b); the index never touches them.

6. **Clean up.** Delete the materialized drafts from `inbox/`.

7. **Report:** what was created, updated, superseded, skipped (and why), plus any contradictions
   surfaced. Keep it to a tight summary.

## Rules

- **Never write a committed card from outside this workflow.** The base has exactly one writer.
- **A bad card is worse than no card** — when a draft is borderline, drop it; the rubric already
  filtered, the human is the cheap final backstop against bloat.
- **Update, don't duplicate** — duplicates are the #1 bloat source; always dedup before CREATE.
- Lint / staleness / sharding are **v2** — do not attempt them here.
