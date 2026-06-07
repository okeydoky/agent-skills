# Behavioral eval — does the contract make the agent fire its reflexes?

This is the **first thing v1 builds and measures** (DESIGN.md dec. 19). The whole system rests on
one risky, *behavioral* bet: an always-loaded contract (`/contract/knowledge-contract.md`) can make
a coding agent reliably fire four reflexes **without being told to**. That can't be unit-tested — it
has to be observed. Pass this eval before building the rest of v1 (`init`, `materialize`, etc.).

## What's under test

The four contract reflexes, against the seeded fixture monorepo in [`fixture/`](fixture/):

| # | Reflex | The scenario that exercises it |
|---|---|---|
| 1 | Task-start → read root TOC (breadth) | **S3** (relevant card is in an *untouched* package) |
| 2 | File-trace → read a package's local `.knowledge/` (depth) | **S2** |
| 3 | Decision gate → surface a rejected approach *before* acting (flagship) | **S1**, **S3** |
| 4 | Capture → draft a worthy **fact** (card) or **term** (glossary), skip the trivial | **S4** (card), **S5** (glossary) |

The fixture seeds three cards: a per-package `rationale` (polling-over-websockets, `apps/web`), a
`gotcha` (`validateCookie` returns `undefined`, `libs/auth`), and a **cross-cutting** `rationale`
(managed-auth-over-custom, root) that is reachable *only* via the root TOC. It also seeds one
glossary term ("Live order updates", `apps/web/.knowledge/CONTEXT.md`) so S5 can exercise dedup.

## How to run

1. Open a **fresh** agent session (no carried context) with the working directory set to
   `eval/fixture/` so its `CLAUDE.md` (the verbatim v1 contract) loads as the resident prompt.
2. For each scenario, paste the **prompt** exactly. Do not hint about `.knowledge/`.
3. Observe the agent's **first substantive response** and score it against the criteria.
4. Record results in the scorecard. Re-run after any contract edit.

> Run scenarios in separate sessions (or reset between them): S2/S3 depend on a clean
> "first time this session" state for the file-trace and task-start reflexes.

---

## S1 — Decision gate, per-package rationale (flagship)

**Prompt:**
> Add websocket support for live order updates in `apps/web` so the order screen feels instant.

**Expected:** Before writing any code, the agent surfaces the prior decision
(`orders-live-updates-poll-not-websocket`) and asks whether to proceed — roughly:
> ⚠ Prior decision: chose polling over **websockets** (rejected: corp proxy buffers them). Still
> valid while clients sit behind the corp proxy. Proceed with websockets anyway?

- **PASS** — surfaces the rejected-websockets rationale *and* its Valid-while condition, and asks
  before implementing.
- **PARTIAL** — mentions the card but only *after* starting to write websocket code.
- **FAIL** — silently begins implementing websockets.

## S2 — File-trace, gotcha depth

**Prompt:**
> Expired sessions seem to be silently treated as logged-out. Take a look at
> `libs/auth/src/session.ts` and tell me what's going on.

**Expected:** On opening the file the agent reads `libs/auth/.knowledge/`, finds the gotcha, and
explains that `validateCookie()` returns `undefined` (does not throw) so callers must null-check —
citing the card rather than only re-deriving it from the code.

- **PASS** — references the `auth-session-swallows-cookie-errors` knowledge (returns `undefined`,
  not throws; callers must distinguish "no session") and signals it read the package's `.knowledge/`.
- **PARTIAL** — reaches the same conclusion purely from the code, never consulting `.knowledge/`.
- **FAIL** — misdiagnoses, or assumes the function throws.

## S3 — Root-TOC breadth + gate on a cross-cutting rationale

**Prompt:**
> We want tighter control over login, so let's start building our own auth service from scratch in a
> new `libs/identity` package. Scaffold it.

**Expected:** Via the root TOC (no existing package file is opened) the agent surfaces
`auth-managed-provider-not-custom` and the decision gate fires before scaffolding:
> ⚠ Prior decision: chose the managed provider (Auth0) over rolling our own (rejected: SOC2 scope +
> token-rotation maintenance). Still valid while we're a small team under SOC2. Proceed anyway?

- **PASS** — surfaces the managed-vs-custom rationale and asks before scaffolding, **without** being
  pointed at `libs/auth`.
- **PARTIAL** — finds it only after exploring `libs/auth` on its own.
- **FAIL** — scaffolds `libs/identity` with no mention of the prior decision.

## S4 — Capture (write reflex) + anti-bloat

**Prompt (two parts, same session):**
> (a) Heads-up for later: the staging deploy ships stale assets unless you run `pnpm -w build`
> *before* `pnpm deploy:staging` — nothing enforces the order, I learned it the hard way.
> (b) Also note the `Order` type has a `status` field with a `pending` value.

**Expected:** (a) is Hidden×Costly → the agent drafts an `operational` card into
`.knowledge/inbox/` (with a `source: user-stated` and any `refs`), and at task end presents **one**
batched approval. (b) is grep-able / not Hidden → **no** card.

- **PASS** — exactly one draft appears in `inbox/` for (a) with `type: operational`, and (b) is not
  captured; approval is batched, not a mid-task nag.
- **PARTIAL** — captures (a) but also (b), or interrupts mid-task to ask.
- **FAIL** — captures nothing, or captures the trivial (b) while missing (a).

## S5 — Glossary capture (write reflex) + scope filter

**Prompt (one message, in `apps/web`):**
> Vocabulary for the order screen so we're consistent: we call one 5-second poll cycle a **"tick"**,
> and the queue of ticks waiting to paint the **"tick backlog"**. We also debounce the render so a
> burst of ticks doesn't thrash React. Note these down.

**Expected:** "tick" and "tick backlog" are vocabulary unique to this repo → the agent drafts
**glossary** entries (`kind: glossary`, `context: apps/web`) into `.knowledge/inbox/`, *not* cards.
"debounce" is a general programming concept → **no** entry (scope filter). At task end the drafts
join the **one** batched approval; `/knowledge-materialize` later appends them to
`apps/web/.knowledge/CONTEXT.md` (near the existing "Live order updates" term) — no card, no index line.

- **PASS** — one or two `kind: glossary` drafts for the repo-specific terms appear in `inbox/`;
  "debounce" is not captured; the drafts are glossary kind (not cards) and approval is batched.
- **PARTIAL** — captures the terms but as **cards** (wrong kind), or also captures "debounce".
- **FAIL** — captures nothing, captures only "debounce", or writes `CONTEXT.md` directly (violating
  the single-writer invariant — glossary must go through `inbox/` → `materialize`).

> **Materialize half (deterministic, no fresh session needed):** drop a `kind: glossary` draft into
> a throwaway copy's `inbox/` and run the `materialize` glossary branch — confirm the term lands as
> one line in the right `CONTEXT.md`, the package is registered in `CONTEXT-MAP.md`, and
> `build-index.mjs` leaves `CONTEXT.md` untouched (it is not a build artifact).

---

## Scorecard

### Run 2026-06-06 — contract v1, fresh session rooted at `eval/fixture/`

| Scenario | Reflex | Result (PASS / PARTIAL / FAIL) | Notes |
|---|---|---|---|
| S1 | decision gate (local) | **PASS** | |
| S2 | file-trace | **PASS** | |
| S3 | root-TOC breadth + gate | **PASS** | |
| S4 | capture + anti-bloat | **PASS** | |

**Result: exit bar met** (S1 + S3 PASS, S2 ≥ PARTIAL). The risky behavioral bet holds — the
always-on contract fires all four reflexes unprompted. Cleared to build increment 2
(`init` + `materialize`). Re-run this eval after any contract edit.

### Re-run 2026-06-06 — contract v1.1 (glossary capture added to reflex 4)

The contract's reflex 4 was extended to capture **glossary terms** (`kind: glossary`) alongside
fact cards (gaps closed: capture trigger, draft shape, `CONTEXT-MAP.md` template). The change is
purely additive — reflexes 1–3 and the card half of reflex 4 are untouched. `fixture/CLAUDE.md`
re-synced to the new contract (verified byte-identical from the `## Repo knowledge base` heading).

| Scenario | What | Result | Notes |
|---|---|---|---|
| S1–S4 | unchanged reflexes | **not re-run** (behavioral) | edit is additive; needs a fresh-session re-run to re-confirm |
| S5 | glossary capture (behavioral half) | **PENDING** | needs a fresh agent session rooted at `eval/fixture/` |
| S5 | glossary **materialize** (deterministic half) | **PASS** | dogfooded on a throwaway fixture copy ↓ |

Deterministic materialize dogfood (run here, not a fresh session): a `kind: glossary` draft in
`apps/web/.knowledge/inbox/` materialized to one line in `apps/web/.knowledge/CONTEXT.md` next to
the existing term; a cross-cutting draft lazily created the **root** `CONTEXT.md` and registered it
in `CONTEXT-MAP.md`; `build-index.mjs` left every `CONTEXT.md` byte-identical (md5 unchanged) and
exited 0. The single-writer invariant holds — nothing wrote `CONTEXT.md` outside `materialize`.

> **Still owed (human):** a fresh-session run of **S5** (does the contract make the agent draft a
> `kind: glossary` entry for a repo-specific term and skip a general one?) and a quick re-confirm of
> S1–S4. The behavioral bet for the glossary trigger is unproven until that run.

### Re-run 2026-06-06 (b) — S5 behavioral, fresh session → PARTIAL → contract v1.2

S1–S4 re-confirmed **PASS**. **S5 = PARTIAL.** The agent did draft a `kind: glossary` entry, but:
1. **Scope filter leaked** — it captured "debounce" (as "tick debounce"); a general programming
   concept the scope rule should reject.
2. **Shape drift** — it bundled all terms into one file with no `term:` field (and an extra
   `status: draft`), instead of one draft per term per `templates/glossary-draft.md`.

**Fix (contract v1.2):** reflex 4's glossary bullet sharpened — (a) the scope rule now names the
excludes explicitly ("a general programming concept never qualifies — debounce/retry/cache/… — even
compounded with a local noun") with the test "would any competent engineer already know this word?";
(b) pins the shape: "one glossary draft **per term**, with a `term:` field, one file per term." The
illustrative exclude in the contract is *"order cache"*, deliberately **not** the eval's terms, so
S5 stays an independent check (no teaching-to-the-test). Re-synced into `fixture/CLAUDE.md`.

### Re-run 2026-06-06 (c) — S5 behavioral, fresh session against v1.2 → PASS

**S5 = PASS.** The agent produced exactly two drafts in `apps/web/.knowledge/inbox/` —
`glossary-tick.md` and `glossary-tick-backlog.md` — each `kind: glossary` with its own `term:`, and
**"debounce" was not captured** (scope filter held). One file per term, no card, no bundling.

The drafts also revealed a cleaner schema than the v1 template: the agent put the **definition in
frontmatter** (`definition:`) and read `context:` as usage notes. We adopted its structure —
`templates/glossary-draft.md` now uses `term:`/`definition:`/`avoid:` with `package:` (not the
overloaded `context:`) as the route hint; `knowledge-materialize.md` (b) routes by
`package:` → inbox location → `refs`, and renders the line from `term`+`definition`+`avoid`.

Dogfooded `materialize` against the **real** S5 drafts (throwaway copy): both routed to `apps/web`
by inbox location, rendered into `CONTEXT.md` beside "Live order updates", `build-index.mjs` left
every `CONTEXT.md` byte-identical, inbox emptied. **Glossary lifecycle (capture → materialize →
retrieve) is proven end to end.**

**Exit bar for v1:** S1 and S3 (the flagship decision gate) **PASS**, and S2 at least PARTIAL.
If the gate doesn't fire reliably, fix the **contract wording** before building anything else —
that is exactly what this eval exists to catch.
