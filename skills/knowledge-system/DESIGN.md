# Repo Knowledge System — Design

A system that lets a coding agent accumulate durable, hard-won knowledge about a repo
*inside* that repo, so it gets better every session, and retrieve that knowledge
token-efficiently while working.

> Status: design complete (office-hours output) + scoped for build (eng review). No code yet.
> This document synthesizes 19 locked decisions; the running decision log with rationale lives
> in `DESIGN-NOTES.md`. The "v1 Scope" section below marks what ships first vs. the full design.

---

## 1. Problem & north star

A coding agent re-derives the same hard-won facts every session: a function that returns
`undefined` instead of throwing, a cross-cutting invariant invisible from any single file,
the deploy sequence learned by trial — and, most expensively, *why a past design was
rejected*. Code records what was built, never what was considered and discarded. That
knowledge evaporates when the session ends or memory fades.

**North star: compounding recall.** The win is the agent visibly recalling a hard-won fact
from an earlier session and acting on it. Everything is measured against that.

**Hard constraint: retrieval efficiency.** The consumer is an agent mid-task, on a token
budget. Knowledge that can't be surfaced cheaply and selectively is dead weight. So the
design optimizes for *point queries that return the smallest complete answer*, not for
human browsing.

**Flagship use case: decision rationale.** The highest-value knowledge is *why design B was
rejected in favor of A* — the one class of fact that leaves zero trace in the code and is
unrecoverable once memory fades. The system must surface a prior decision and alert the user
*before* the agent silently re-attempts a rejected approach. This is the headline demo, and
several design choices exist specifically to serve it.

---

## v1 Scope — what ships first

The full design is scale-ready. v1 ships the smallest system that proves the north star
(compounding recall, especially rationale recall) and validates the one risky bet: **does the
always-on contract reliably make the agent fire its reflexes?** Everything deferred is a build
artifact or a scale/hygiene feature that adds **zero migration cost** later (the index and
glossary are regenerated, so adding sharding/lint after the fact rewrites nothing).

| Ships in v1 | Deferred to v2 | Why deferred |
|---|---|---|
| Atomic cards + frontmatter schema | Card-index volume-sharding (~150/topic) | won't hit the threshold early |
| Flat per-package index + root aggregator | Root-TOC → per-package-digest slimming | only needed when root TOC gets heavy |
| Retrieve + **rationale decision-gate** | — | this is the flagship |
| **Dual retrieval: root TOC + file-trace** | — | both needed for monorepo recall |
| Always-on contract (gate + triggers) | Standalone in-loop skill | contract covers the reflexes (dec. 16) |
| Full capture loop (draft→inbox→batch→materialize) | Rich per-item edit UX | "approve all / drop which" suffices |
| Glossary **incl. CONTEXT-MAP sharding** | — | the monorepo needs per-package contexts day one |
| **Hierarchical per-package layout** | — | matches the first real use case |
| `rationale` + `gotcha` machinery | Per-type machinery for `architecture`/`operational` | those stay plain tags in v1 |
| One management skill | The two-skill packaging split | keep the single-writer *principle*, not two packages |
| — | **Entire lint** (§3.4) | verified decoupled from capture/retrieve; nothing to clean at v1 volume |
| — | Stats / hit-tracking add-on (§3.4) | nothing to measure yet |

**v1 risk to watch:** with lint deferred, v1 has no correctness-decay protection — stale `refs`
accumulate silently. Acceptable at low volume (the `refs` are in the card, so a reading agent
notices a miss), but revisit lint the moment card count or staleness complaints rise. And because
the always-on contract's reliability is behavioral, not unit-testable, **the first thing to build
and measure is an eval: does the agent actually fire the decision-gate and the file-trace
trigger?** Validate that before building anything else.

---

## 2. Data model

Two artifact shapes, because access pattern decides the unit.

### 2.1 Atomic fact card (point-query target)

One card = one `.md` file = the **largest fact still retrieved, trusted, and invalidated as
a single unit**. "Atomic" means *indivisible without losing a consumer*, not *minimal*.

```markdown
---
id: auth-session-swallows-cookie-errors      # kebab slug = filename
title: Session validation swallows expired-cookie errors
summary: validateCookie() returns undefined (not throw) on expired cookies; callers must null-check.
type: gotcha            # gotcha | rationale | architecture | operational  (locked enum)
topic: auth             # ONE primary topic = shard key
tags: [session, error-handling, cookies]
confidence: 8           # 1–10; below ~5 → don't write
status: active          # active | stale | superseded | deprecated  (lint-managed)
created: 2026-05-31
updated: 2026-05-31
source: observed        # observed | user-stated | session | commit:<sha> | pr:<n> | ticket:<id>
refs:                   # load-bearing for staleness; zero refs = lint warning
  - src/auth/session.ts:47
  - sym:validateCookie
related: [auth-login-redirect-flow]
supersedes: null
---
**Fact.** ...
**Why it matters.** ...
**How to apply.** ...
```

Notes:
- `summary` is the **index router line** — it must be near-lossless, because retrieval routes
  on it without opening the card. `title` is the human label; kept separate on purpose.
- `refs` is load-bearing: it's how lint detects staleness (resolve each ref against the working
  tree). A `sym:` ref is symbol-anchored and survives line moves better than `file:line`.
- `source` is single-valued = the single richest origin to consult to re-establish the fact, and
  is **never** lint-resolved (unlike `refs`). Discovery modes (`observed`/`user-stated`/`session`)
  are the fallback; an artifact pointer wins when present, priority
  `ticket > pr > commit > user-stated > observed > session`. `ticket:<id>` is vendor-neutral
  (Jira `ticket:PROJ-1234`, Linear, issue trackers) and is especially valuable on `rationale`
  cards, where the ticket carries the surrounding discussion a human needs to refresh context.
- Only six fields need judgment (`title`, `summary`, `type`, `topic`, `confidence`, optionally
  `tags`/`related`); the rest are auto-derived at capture time.

**The four types** (enum is locked; chosen because each marks a distinct *Hidden* shape):

| type | Hidden when… | Costly when… |
|---|---|---|
| `gotcha` | code reads like X but does Y / has a non-local effect | a caller trusting the obvious reading ships a bug |
| `rationale` | the rejected option + its trade-off left no trace in code | the agent silently re-tries a rejected design |
| `architecture` | an emergent cross-cutting invariant visible from no single file | violating it breaks things non-locally |
| `operational` | a command/sequence undiscoverable by reading code (runbook/env/tribal) | getting it wrong burns time or breaks an environment |

`convention` is **not** a type: a convention is usually grep-able (not Hidden), so it folds
into the glossary or — if genuinely undiscoverable and costly — an `architecture` card.

**Granularity / "is this one card or two?"** — fork into separate cards if any of the three
core operations would fork:

- **retrieve:** would a point query ever want one claim *without* the other? → `summary`
- **trust:** do the parts have different certainty/origin? → `confidence` / `source`
- **lint:** would the parts go stale at *different* times? → `refs` / `status`

Fast tell: write `summary` as one sentence. An **"and"** joining two independently-useful
claims → two cards. A single claim plus its **consequence** ("…so callers must null-check")
→ one card; never split a fact from its own fix. **Default to split** (a too-small pair still
retrieves together via its shard, and lint can merge later; a too-fat card needs a rewrite to
split and breaks the near-lossless summary), with a **floor**: every card must be useful and
intelligible retrieved *alone*.

### 2.2 Glossary (read-whole ambient resource)

Project vocabulary is not a point-query target — you pull the whole vocabulary when entering a
domain. So it is **one flat `CONTEXT.md`** per context: `term → tight definition + _Avoid_:
synonyms`, no per-term frontmatter (confidence/refs/status are meaningless for a definitional
fiat). Scope rule: only terms *specific to this repo*; general programming concepts don't
belong. Cards link terms via `[[term]]`; the canonical home is `CONTEXT.md`. Past a few dozen
terms, lint splits it into per-topic `CONTEXT.md` files under a `CONTEXT-MAP.md`.

### 2.3 Generated index (the retrieval substrate)

An `index.md` of one-line summaries, **generated from card frontmatter** — never hand-maintained.
It's a build artifact: regenerated on capture (materialize, §3.2). In a monorepo (§2.4) each
package has its own local index, and the root has an **aggregator index** that carries the
cross-cutting cards plus every package's card summaries — the always-on cross-package TOC that
makes recall complete (§3.3). Flat while small (perfect recall); volume-sharding one package's
index by topic once it crosses ~150 cards is a **v2** feature (it's a build artifact, so adding it
later has **zero migration cost**).

This is why the card `summary` must be near-lossless (§2.1) and why **no embeddings or vector
store is needed**: the index is cheap markdown the LLM reads and routes semantically.

### 2.4 File layout — hierarchical per-package (monorepo)

The system lives under namespaced `.knowledge/` roots. The first real deployment is a monorepo, so
the layout is **hierarchical: knowledge is colocated with the code it describes.** Each app/lib has
its own `.knowledge/`, and a root `.knowledge/` holds the cross-cutting facts plus the aggregators.

```
<repo root>/.knowledge/
  CONTEXT-MAP.md        # routes to every package's glossary                (committed)
  index.md              # ROOT AGGREGATOR: cross-cutting card summaries +    (committed)
                        #   every package's card summaries (cross-package TOC)
  cards/                # cross-cutting / monorepo-wide cards only           (committed)
  inbox/                # pre-approval drafts for root-level cards   (LOCAL, gitignored)

apps/web/.knowledge/
  CONTEXT.md            # this package's glossary                            (committed)
  index.md              # this package's local card summaries                (committed)
  cards/                # this package's atomic cards, flat, filename = id   (committed)
  inbox/                # pre-approval drafts for this package        (LOCAL, gitignored)

libs/auth/.knowledge/
  CONTEXT.md   index.md   cards/   inbox/      …same shape per package
```

```gitignore
**/.knowledge/inbox/
# v2 (local-only when added): **/.knowledge/retrieval-log.jsonl, **/.knowledge/STATS.md
```

Rules that make the hierarchy work:
- **A card lives in the package its `refs` point into.** Refs spanning multiple packages → the
  card is cross-cutting → it lives at the root. Capture (§3.2) routes by this rule.
- **The glossary mirrors the same shape:** per-package `CONTEXT.md` under a root `CONTEXT-MAP.md`
  (the monorepo needs this on day one — it is *not* deferred).
- **Single-writer invariant holds per store:** each `.knowledge/` has its own gitignored `inbox/`;
  in-loop only stages there, materialize is the sole writer to that store's committed base (§4).
- **Locality payoff:** a package's cards, refs, and glossary travel with it — extract or move the
  lib and its knowledge moves too; refs stay in-package.
- **Cards stay flat in each `cards/`.** When v2 volume-sharding arrives it reshuffles only the
  *generated* index, never card files (`refs`/`related` point by `id`, not path) — zero migration.
The `.knowledge/` name is a convention; nothing references it by content, so it can be renamed.

---

## 3. The four operations

### 3.1 Capture-worthiness — the rubric every write passes first

A bad card is worse than no card: it dilutes signal and erodes trust until the agent
re-verifies everything (net-negative). The bar is **"no" by default**.

**Core test — capture iff Hidden AND Costly:**
- **Hidden** — can a future agent cheaply re-derive this from the working tree, a search, or
  general knowledge? If yes, skip.
- **Costly** — if the agent doesn't know it, does it waste real time or take a wrong path? If
  low-stakes, skip.

The other quadrants self-reject: Hidden+cheap = trivia; not-Hidden+Costly = the code already
says it (a code comment beats a card). Per-type operationalization is the table in §2.1.

**Mechanics:** dedup before write (UPDATE/supersede, never duplicate — duplicates are the #1
bloat source); a confidence floor (worthy-but-unconfirmed → *hold*, don't write below ~5/10);
and "cards pay rent" (the mindset is *earn ongoing retrieval*, not *get in once*).

### 3.2 Capture — draft inline, approve in one batch, materialize

Three stages, mirroring retrieve:

1. **Inline draft** (in-loop). Fires on type-shaped trigger moments — a choice between real
   alternatives → `rationale`; expected X, code did Y → `gotcha`; relied on a non-local
   invariant → `architecture`; learned a command by trial → `operational`; the user *stated*
   something non-obvious → `source: user-stated`. Drafts persist to a **local, gitignored
   `.knowledge/inbox/`** (survives compaction/crash; pre-approval, so out of the committed
   base). `refs` and `source` are captured **at the moment**, because the agent knows the line
   then and won't at session end.
2. **End-of-session batch** (the approval gate). Fires at a task-completion boundary, an
   explicit command, or a pre-compaction safety flush — never a mid-task nag. **One** interaction
   for N drafts: `[a]ll / [n]one / per-item [k]eep [d]rop [e]dit`. Each row shows summary + type
   + topic + the one-line Hidden×Costly justification. The rubric does the heavy filtering; the
   user is the cheap final backstop against bloat.
3. **Materialize.** Fill auto-derivable fields, **dedup against the index** (same claim + new
   evidence → UPDATE; genuinely new → CREATE; **contradicts existing → surface now**: "contradicts
   card X; reconcile or supersede?"), then regenerate the affected index shard.

### 3.3 Retrieve — the LLM routes a markdown index

Routing is the LLM's job, not a vector DB's. No embeddings, no infra: the agent reads the cheap
index and judges relevance semantically.

- **Stage 0 — trigger.** Four shapes: task-start (big pull), decision-check (the loud rationale
  gate, §5), on-demand point query (~1 card), and **file-trace** (monorepo) — opening or tracing
  into a file under a package's subtree loads that package's `.knowledge/` (local index +
  `CONTEXT.md`) before trusting the code, once per package per session.
- **Stage 1 — glossary.** Load the relevant `CONTEXT.md` whole (via the root `CONTEXT-MAP.md`);
  in the monorepo this is the current package's context, plus others as file-trace pulls them in.
- **Stage 2 — route the index.** Read the **root aggregator index always** (the complete
  cross-package TOC — this is the breadth safety net that catches relevant facts in packages the
  agent never opens, e.g. "we abandoned `libs/legacy-auth`"). Then route: candidate card ids by
  `summary`/`topic`/`tags`; only selected cards open. File-trace adds local depth on top.
- **Stage 3 — load under budget.** Ranked `relevance > confidence > status (active>stale, never
  deprecated unless asked) > recency`, with **current-package cards preferred** over siblings at
  equal relevance.

> **Monorepo recall = two complementary triggers.** The root TOC gives *breadth* (you always see a
> one-line summary of every card, even in untouched packages); file-trace gives *depth where you're
> working* (the moment you follow a util into `libs/auth`, you pull its knowledge — no
> dependency-graph parser, it piggybacks on reading the file). Trace alone misses untouched-but-
> relevant packages; root TOC alone lacks local depth; together they cover both. At scale, file-
> trace is what later lets the root TOC slim to per-package *digests* (a v2 optimization).

**Budget** = "the smallest set that answers the task," a soft top-K cap (~5–7 cards), not a hard
token count. **Rationale cards are exempt from the cap** — a rationale matching the current
approach gets a reserved slot, surfaced even over budget (missing one is the system's most
expensive failure). **Guardrail:** hit-count never feeds retrieval ranking (avoids
rich-get-richer / new-card starvation).

### 3.4 Lint — prune by wrongness, not coldness  *(entirely v2 — see v1 Scope)*

> **Deferred to v2.** Lint is verified decoupled from the two live flows: capture owns dedup,
> contradiction-surfacing, and index regeneration *at write time* (§3.2), and retrieve only reads.
> So v1 ships with no lint and the loops still work — the cost is no correctness-decay protection
> (stale `refs` accumulate silently), acceptable at low volume. The full design below is the v2
> target.

Lint is hit-free: its power is *correctness signals*, not usage. A cold-but-correct card costs
~one index line and zero retrieval budget — "rarely used" is a weak eviction reason. The cards
that hurt are *wrong* ones, all caught structurally:

- **Staleness via ref-resolution** (primary): resolve each `ref` against the working tree;
  gone/moved code → flag. Targets wrong cards, not quiet ones.
- **Contradiction sweep:** the LLM reads a topic-shard and flags mutually exclusive claims.
- **Dedup/merge:** catch near-duplicates that capture-time dedup missed.
- **Status hygiene:** `superseded`/`deprecated` → archive.
- **Confidence + age review:** old + low-confidence + never-confirmed → re-examine.
- **Rationale-staleness:** surface each rationale's `Valid while` line for human
  re-confirmation (constraint-driven, human-in-loop — unlike ref-staleness, which auto-resolves).
- **Sharding:** count cards per topic, split the index at threshold.
- **Orphan/connectivity:** zero `refs` + no `related` + unlinked → flag.

**Optional hit-tracking add-on** (off by default; lint never depends on it): retrieve buffers
events and flushes at session end to a **local, gitignored** `.knowledge/retrieval-log.jsonl`;
a `stats` view aggregates into a local `STATS.md`. Surfaces hot cards (the compounding-recall
meter), empty-retrieves-by-topic (a knowledge-gap finder), and rationale-gate fire count
(flagship-value meter). Local-only = zero merge risk in a team.

---

## 4. Architecture — two skills, one invariant

The four operations sort by consumer and invocation model into two skills:

| | **In-loop skill** (the interface) | **Management skill** (the companion) |
|---|---|---|
| Consumer | the coding agent, mid-task | the human, maintaining the base |
| Invocation | **ambient** (fires on §3.3/§3.2 triggers) | **deliberate** (user-invoked) |
| Owns | `retrieve` + capture-draft (stage 1) | `materialize` + `lint` + `stats` + `init` |
| Weight | lightweight, on a token budget | heavy; LLM sweeps the whole base |

**Organizing invariant — single writer to the committed base:**

- The in-loop skill **reads** the committed base (retrieve) and **writes only to the local,
  gitignored inbox** (capture stage 1). It never mutates a committed card. So the reflex that
  fires constantly through every session carries **zero merge risk and cannot corrupt the
  shared base**.
- The management skill is the **only** mutator of the committed base (materialize, dedup, shard,
  status, index regen, lint). Every base mutation goes through one deliberate, reviewable gate.

The inbox is the staging area *between* the two skills; the end-of-session batch approval (§3.2)
is the **handoff**: drafts accumulate → user approves → management materializes. (The companion
is modeled on the user's `second-brain` project.)

> **v1 packaging.** v1 ships this as **one management skill + the always-on contract**, not two
> standalone skill packages. The in-loop reflexes live entirely in the contract (§4.1); the
> invoked workflows (`materialize`, later `lint`/`stats`) are the single skill. The single-writer
> invariant is kept as a *rule*, not enforced by a package boundary. Splitting into a separate
> standalone in-loop skill is a v2 packaging choice (dec. 16 already called the wiring an impl
> detail). With lint and stats deferred (§3.4), the v1 skill is just `init` + `materialize`.

### 4.1 Delivery model — two surfaces

The two skills reach the agent through two distinct delivery surfaces:

1. **An always-loaded agent contract** — a snippet in the environment's resident prompt
   (`CLAUDE.md`, Windsurf `guideline.md`, etc.).
2. **Human-invoked workflows** — `materialize`, `lint`, `stats`, `init`.

**Allocation rule (proactive ⇒ contract):** a behavior that must fire *reflexively* cannot be an
opt-in skill, because the agent might not invoke it. The decision-check gate (§3.3) is
**mandatory** — "before switching approaches, surface any rationale first" — so it, along with
retrieve-on-task-start, the **file-trace trigger** (§3.3 — read a package's `.knowledge/` when you
open its code), and the type-shaped capture-draft triggers, **must live in the always-on
contract**. The deliberate operations the human chooses to run (`materialize`/`lint`/`stats`) are
invoked workflows. This is the §4 ambient-vs-deliberate split pinned to the delivery layer.

**The resident contract must stay minimal.** It costs tokens every session, so it is a thin
*trigger-table*, not the spec: "a knowledge base lives at `.knowledge/`; read the index at
task-start; run the rationale gate before switching approaches; draft a capture on these
moments." All heavy detail lives in the index and cards, loaded on demand — consistent with the
retrieval-efficiency north star.

**Portability.** The contract is environment-agnostic markdown; only the injection point differs
per environment. An `init` workflow installs both surfaces (writes the snippet, scaffolds
`.knowledge/`).

*Deferred to implementation* (none of it feeds back into the data model or operations — it's
packaging): the exact wording of the snippet, per-environment skill/workflow file formats and
command names, and the install mechanics of `init`.

---

## 5. Flagship walkthrough — surfacing a rejected design

**Rationale card body** specializes the generic `Fact / Why / How` triad. Design A is in the
code (not Hidden); B and *why it lost* leave no trace (maximally Hidden) — so the body spends
its weight on the irrecoverable part and does **not** re-document A:

- **Decision.** (= Fact) One line: the question + the chosen option *named, not elaborated*.
- **Rejected.** (= Why) Each rejected option + the *specific* reason it lost. The payload.
- **Valid while.** (= How) The condition(s) that keep the rejection binding; when they change,
  B is back on the table.

`summary` + `tags` must **name the rejected option(s)** so a future "let's try B" query routes
here even though B has no code to anchor to.

```markdown
---
summary: Chose 5s polling over websockets for live order updates; websockets
         rejected — corp proxy buffers them, breaking realtime.
type: rationale
tags: [websockets, polling, realtime, proxy]
---
**Decision.** Live order updates use 5s server-side polling, not websockets.
**Rejected.** Websockets: the corp egress proxy buffers long-lived connections —
  push latency spiked to 30–60s in staging, worse than polling and undebuggable
  from our side. SSE: same proxy-buffering problem.
**Valid while.** All clients sit behind the corp proxy. If we ship a direct-internet
  client or the proxy is replaced, re-evaluate — websockets would win on latency/load.
```

**The loop:**

1. Months later, a feature tempts the agent toward websockets for live updates.
2. **Decision-check is a mandatory pre-action gate** (not a passive lookup): before proposing
   or switching an approach on topic T, the agent filters the index to `type: rationale` on T.
   Any hit is surfaced **before** proceeding, exempt from the budget cap.
3. The surface shows three lines the body dictates — Decision + the Rejected reason *for the
   tempted option* + Valid-while — then asks:

   > ⚠ Prior decision: chose polling over **websockets** (rejected: corp proxy buffers them).
   > Still valid while behind the corp proxy. Proceed with websockets anyway?

4. The user decides with full context instead of silently re-walking a known dead end. If the
   `Valid while` constraint has since changed, that's exactly the signal to reopen B — and
   lint's rationale-staleness pass would already have flagged it for re-confirmation.

This is the compounding-recall north star made concrete: a fact captured once, months ago,
changes what the agent does today.

---

## 6. Prior art & what we add

**grill-with-docs** (Matt Pocock) is independent convergence on the core bet — durable repo
knowledge as in-repo markdown, token economy as the payoff. We adopt three things from it:

1. **The ADR three-gate test** (hard to reverse · surprising without context · real trade-off)
   is the backbone of our capture-worthiness rubric — generalized into the Hidden×Costly axes
   across all four types.
2. **The glossary scope rule** ("only terms specific to this context") is our non-Hidden filter.
3. **Capture inline at the moment of resolution + lazy file creation** (write a file only when
   there's something to write = anti-bloat by construction).

**What we add: a retrieval layer.** grill-with-docs scales to "read the whole `CONTEXT.md` +
the whole `adr/` dir" — no generated index, no sharding, no point queries under budget, no
lint/staleness/contradiction sweep across a large base. This system is the version that
survives 300 facts.

---

## Appendix — design decisions

The full decision log, with the reasoning and rejected alternatives behind each choice, is in
`DESIGN-NOTES.md` (13 locked decisions). This document is the synthesized spec; that one is the
"why."
