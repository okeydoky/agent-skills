---
description: Execute one or more phases from an implementation plan, then update the plan with completion status and implementation notes for downstream sessions.
---

# Execute Plan

## Step 0: Identify the Plan and Target Phases

### 0a. Locate the Plan File

- The user must provide or reference a plan file (from `~/.windsurf/plans/`).
- If the plan file path is not explicit in the prompt, list `~/.windsurf/plans/` and ask the user which plan to execute.
- Read the plan file in full before proceeding.

### 0b. Determine Which Phases to Implement

- If the user specifies phases (e.g., "implement Phase 3", "do Phases 1-2"), execute only those.
- If the user says "next phase", find the first phase not yet marked ✅ and execute it.
- If no phase is specified, ask the user which phase(s) to implement.
- Check for **batching hints** on the target phase — inform the user if adjacent phases are recommended for batching and ask if they'd like to include them.

### 0c. Read Implementation Notes from Prior Phases

- If earlier phases have implementation notes (marked ✅ with notes), read them carefully. These contain deviations, discoveries, and context that may affect your work.
- Treat implementation notes as **authoritative** — they override the original plan steps if there's a conflict (the notes reflect what actually happened).

### 0d. Read Repo Context

- If the repo has a root `CONTEXT.md` (and, in a monorepo, an `apps/<app>/CONTEXT.md` for the app this plan touches), read them before implementing. They are the authoritative glossary and durable-decision record.
- If a plan step would contradict a decision recorded in `CONTEXT.md`, **stop and flag it to the user** before implementing — do not silently follow either source.
- If no `CONTEXT.md` exists, proceed without it.

---

## Step 1: Implement the Target Phase(s)

- Execute each step within the target phase(s) **sequentially**.
- Reference the `## Context for Implementer` section for file locations, patterns, and architectural constraints.
- After completing each step, mentally verify it against the plan's intent — don't just mechanically follow instructions if something doesn't make sense in context.
- If any step is ambiguous, contradicts implementation notes from a prior phase, or requires a decision not covered by the plan's Design Decisions section — **stop and ask the user**. Do NOT guess.
- **Verify before declaring done:** run the tests relevant to the changed code (at minimum, the affected projects' unit tests). A phase with failing tests is NOT complete — fix the failures, or stop and ask the user if the failures are pre-existing or out of scope. The result becomes the "Test status" line in the implementation notes (Step 2c).

---

## Step 2: Update the Plan File

> **This step is critical.** The plan file is a living document shared across sessions. Updating it ensures downstream phases have accurate context.

### 2a. Mark Phase(s) as Complete

For each completed phase, update its heading in the plan file:

```markdown
### Phase 2: Backend API ✅
```

Add a completion timestamp as a blockquote below the heading:

```markdown
> Completed: YYYY-MM-DD
```

### 2b. Mark Individual Steps

Mark each completed step with a checkbox:

```markdown
4. [critical] Extend `processUploadJob` to create disposition reasons in-transaction ✅
5. Update backend tests ✅
```

### 2c. Write Implementation Notes

Append an **`> Implementation Notes:`** block under the completed phase heading. This is a **handoff brief for the next session**, NOT a journal of what you did.

#### What to include (downstream-focused):

- **Interface actuals** — exact function names, signal names, method signatures, or API shapes that downstream phases will consume. The next session should be able to bind/call these without reading the source.
- **Deviations that affect downstream** — anything done differently from the plan that changes how a later phase should work. If the deviation is internal and no later phase interacts with it, omit it.
- **Discoveries that affect downstream** — unexpected findings that change later steps (e.g., "the existing service already handles X, so Phase 4 step 2 can be simplified").
- **New files that downstream phases need** — files created that weren't in the original plan, only if a later phase imports from or modifies them.
- **Warnings** — things the next session should watch out for (e.g., "don't import from X, use Y instead — discovered a circular dependency").
- **Complexity adjustment** — if the actual implementation complexity differed significantly from the plan's classification (e.g., classified as Straightforward but required cross-file reasoning), note it so the user can recalibrate model selection for similarly-classified remaining phases.
- **Test status** — a single line: "All N tests pass" or "Tests pass with known skip: [reason]".

#### What NOT to include:

- **Restating what the plan already says** — if the plan said "add X to the facade" and you did exactly that, don't note it. Only note deviations or additions.
- **Internal implementation details** — refactoring decisions, variable names, or patterns that no downstream phase interacts with.
- **Test coverage details** — don't list describe blocks, test names, or fixtures. Just confirm tests pass.
- **History/narrative** — "I first tried X, then switched to Y" is irrelevant to the next session.

**The filter (apply to every bullet before writing it):** "If I remove this note, will the next session make a mistake, duplicate work, or waste tokens re-discovering this?" If no → omit it.

Example:

```markdown
### Phase 3: Frontend — Facade Refactor ✅

> Completed: 2026-05-20
>
> **Implementation Notes:**
>
> - Facade exposes `step1Complete`, `step2Complete`, `step3Complete`, `step4Complete` computeds — Phase 4 stepper should bind `[completed]` to these directly.
> - Disposition reason mutation API: `addDispositionReason(reason)`, `removeDispositionReason(index)`, `updateDispositionReason(index, patch)`.
> - `isValid` now delegates to step1–step4 computeds — Phase 4 does not need to touch it.
> - All 78 tests pass.
```

### 2d. Update Assumptions (if applicable)

If an assumption from the `## Assumptions & Risks` table was **validated or invalidated** during implementation, update its row:

```markdown
| 1 | ~~Assumption~~ | ~~The `UserService` already handles token refresh~~ | ✅ Confirmed in Phase 1 |
```

Or if invalidated:

```markdown
| 1 | ~~Assumption~~ | ~~The `UserService` already handles token refresh~~ | ❌ Wrong — added refresh logic in Phase 2, see impl notes |
```

---

## Important

- At **any point** during this workflow, if you need clarification or are uncertain, **stop and ask the user**. Do NOT hallucinate or assume.
- Follow all workspace rules and conventions defined in `.windsurf/rules/`.
- Keep changes minimal and focused. Prefer small, targeted edits over large rewrites.
- **The plan file is the source of truth** for multi-session implementation. Always leave it in a state that helps the next session succeed.
