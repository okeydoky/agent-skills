---
description: One-time interview that seeds a repo's CONTEXT.md files (glossary + durable decisions). The agent explores the codebase, drafts candidates, and grills the user to confirm — the user ratifies, the agent proposes.
---

# Bootstrap Context

Seed the `CONTEXT.md` files that the `planner` and `execute-plan` workflows read. Run this **once per scope** (the repo root, or one app in a monorepo). It is safe to re-run later — re-runs operate in update mode.

> **Where to run:** This workflow has no Jira/branch chores and its only deliverable is markdown files — run it on a cheap or free model pool (e.g., Claude Code or VSCode) rather than spending premium workflow credits. A mid-tier model is sufficient; the user's confirmation pass is what makes the result trustworthy, not the model's exploration.

## What a CONTEXT.md is (and is not)

A `CONTEXT.md` is a **small, authoritative glossary + durable-decision record** for one bounded scope. Every entry must pass both filters:

- **Hidden** — not cheaply re-derivable from the code, a search, or general knowledge.
- **Costly** — getting it wrong wastes real time or breaks things.

It is NOT a wiki, an architecture overview, or a file map. File layout, obvious type shapes, and anything an agent can learn by reading the code for 30 seconds are noise — noise goes stale, and a stale entry is worse than no entry. **A 50-line file the agent trusts beats a 500-line wiki it skims.**

### File placement

| Repo shape | Files |
|---|---|
| Single app | One `CONTEXT.md` at the repo root |
| Monorepo (e.g., Nx) with multiple unrelated apps | Root `CONTEXT.md` for workspace-wide content (shared-lib terms, cross-cutting decisions, conventions) **plus** one `apps/<app>/CONTEXT.md` per app for that app's domain |

App-scoped libs (e.g., `libs/<app>/...`) belong to that app's file; truly shared libs belong to the root file. Do **not** create per-lib files — split further only if a file outgrows usefulness.

---

## Step 0: Determine Scope

1. Ask the user which scope to bootstrap if not stated: the repo root, or a specific app. In an Nx monorepo, list `apps/` to enumerate the candidates.
2. Check whether a `CONTEXT.md` already exists for that scope:
   - **Exists** → run in **update mode**: read it, treat existing entries as confirmed, and focus the interview on gaps and entries that look outdated.
   - **Missing** → **create mode**.
3. One scope per run. If the user wants root + two apps, that is three runs (they can be back-to-back in one session).

## Step 1: Explore and Draft Candidates

Do your homework before asking anything:

- Read the scope's entry points, core domain models/entities, and main services — collect recurring names that look domain-specific.
- Read the scope's `README` and any docs that exist.
- Scan recent history for vocabulary and decisions: `git log --oneline -50 -- <scope-path>` and skim a few substantive commit messages; Jira ticket summaries are fair game if available.
- For the **root** scope: focus on shared libs, workspace conventions, and anything both apps depend on — not app domain terms.

Build two candidate lists:

1. **Glossary candidates** — terms that look coined inside this codebase, plus any term you found used with multiple meanings (flag the collision).
2. **Decision candidates** — choices visible in the code that look deliberate and non-obvious (an unusual pattern, a conspicuously avoided library, a structure that only makes sense with backstory).

## Step 2: Apply the Inclusion Filter

Cut the candidate lists ruthlessly before showing them to the user:

- **Glossary**: only names **coined inside this codebase** for a domain concept. The one question: *would any competent engineer already know this word?* If yes, drop it. General programming concepts never qualify — *debounce, retry, cache, pagination, stepper* are out, even compounded with a local noun ("order cache" is still just a cache).
- **Decisions**: only candidates that plausibly pass **all three** tests — hard to reverse, AND surprising without context, AND the result of a genuine trade-off. When in doubt, ask the user in Step 3 rather than silently including.
- Definitions and rationales are **vocabulary and why only** — never implementation detail.

Expect to end with roughly 5–15 glossary candidates and 0–5 decision candidates. More than that usually means the filter was too loose.

## Step 3: Grill the User

Present everything in **one batched message** (one round; max one follow-up round):

- A numbered list of glossary candidates, each with a **recommended definition** drafted from your exploration. Where you found a collision or fuzziness, pose it as a concrete question: *"`Disposition` appears as both the entity and its status field — which is canonical, and what should the other be called?"*
- A numbered list of decision candidates, each with the **recommended rationale** as you inferred it, asking the user to confirm, correct, or kill it: *"The upload pipeline writes to a staging table before the main table — deliberate (and why), or historical accident?"*
- An open question at the end: *"What terms or past decisions do new developers (or agents) most often get wrong here that I didn't list?"* — the user's answer to this is often the highest-value content in the file.

**STOP and wait for answers.** The user's confirmation is what makes the file authoritative — never write entries the user has not ratified.

## Step 4: Write the Files

Write (or update) the scope's `CONTEXT.md` using this format:

```markdown
# Context — <scope name>

> Glossary and durable decisions for <scope>. Read by planning and execution
> workflows before touching this code. Every entry is (a) not derivable from
> the code and (b) costly to get wrong. Keep it small.

## Glossary

- **Term** — definition. _Avoid:_ displaced synonym(s), when relevant.

## Durable Decisions

- **Decision statement** — rationale; what was rejected and why. _(ticket/date if known)_
```

The **root** file in a monorepo additionally starts with a routing section so agents can find the app files:

```markdown
## App Contexts

- `apps/<a>/CONTEXT.md` — <one-line domain description>
- `apps/<b>/CONTEXT.md` — <one-line domain description>
```

Commit the file(s) — they are team-visible, shared memory.

## Step 5: Hand Off to Maintenance

This workflow only seeds. Ongoing upkeep happens automatically through the `planner` skill, which:

- reads the relevant `CONTEXT.md` before every discovery interview (and never re-asks what it answers), and
- proposes additions **and removals** at plan confirmation, applying the same filters as Step 2.

Tell the user the seed is complete and which file(s) were written. If other scopes remain un-bootstrapped, list them.

---

## Rules

- The agent proposes; the user ratifies. Nothing enters a `CONTEXT.md` without explicit approval.
- Never pad the file to look thorough — proposing few or zero entries for a scope with little hidden knowledge is a correct outcome.
- Keep each entry to 1–3 lines. If an entry needs a paragraph, it is probably implementation detail that belongs in code comments or the plan, not here.
