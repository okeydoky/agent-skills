---
name: planner
description: Draft a structured, self-sufficient implementation plan for a task. Conducts a discovery interview, organizes work into phases, and produces a detailed plan that can be executed phase-by-phase in fresh agent sessions.
---

# Planner Skill

When this skill is invoked, follow the steps below **in order**. Do not skip steps.

> **IMPORTANT — Output Target**: All structured output (User's Intent and the final Plan) **MUST be written to a file** in the global plans directory `~/.windsurf/plans/` using the `write_to_file` or `edit` tool. Do **not** output these sections only in the chat window. A short status message in chat (e.g., "Plan written to `~/.windsurf/plans/PROJ-123-add-auth.md`.") is fine, but the full content belongs in the file.
>
> **File Naming Convention**: **`{jira_ticket_id}-{short-descriptive}.md`** (e.g., `PROJ-123-add-auth.md`, `OASIS-511-stepper-refactor.md`). If no Jira ticket is associated, fall back to a kebab-case slug (e.g., `fix-login-bug.md`). Determine the filename in Step 1 and use it consistently for all file operations in subsequent steps.

---

## Step 1: Understand the Request

- Read the user's request carefully.
- Gather context: inspect relevant files, project structure, existing code, and workspace rules/conventions as needed.
- If the request references specific files, components, or features, read them before proceeding.
- **Check for existing plan files**: List `~/.windsurf/plans/` and look for files that share the same Jira ticket ID prefix (e.g., if the current task is `PROJ-123`, look for `PROJ-123-*`). If a matching plan exists from a previous session, read it for context.

## Step 2: Write "User's Intent" to the Plan File

Using the filename derived in Step 1, create (or overwrite) the plan file in `~/.windsurf/plans/`. Start the file with:

```
## User's Intent
```

In this section, write a concise summary (3–6 sentences) of what the user is trying to achieve. Cover:

- **Goal** — what end result the user wants.
- **Scope** — which parts of the codebase / system are affected.
- **Constraints** — any explicit or implied constraints (tech stack, conventions, backward compatibility, etc.).

Do NOT list implementation steps here — only the _what_ and _why_.

Write this section to the file using `write_to_file`. Do NOT only print it in chat. Remember to write to `~/.windsurf/plans/{filename}` using the filename you determined in Step 1.

## Step 3: Discovery Interview (Mandatory)

> **This step is NOT optional.** Even if the request seems clear, you MUST generate and ask probing questions before planning. Vague tickets and "obvious" tasks are where missed nuances cause the most rework downstream.

The goal of this step is to surface hidden requirements, edge cases, and constraints that would otherwise only emerge during implementation. The plan will be handed off to a fresh agent session without conversational context — every nuance must be captured now or it will be lost.

### 3a. Investigate the Codebase

Before asking questions, do your homework:

- Read the files/modules most likely affected by this task.
- Identify existing patterns, abstractions, and conventions relevant to the work.
- Note potential integration points, shared interfaces, and downstream consumers.
- **Blast-radius analysis (mandatory for data-model changes):** If the task introduces or modifies a data field, column, or entity property, systematically search for all consumers of the _analogous existing field_ (e.g., if adding `secondaryReasons`, grep for every consumer of `primaryReason` or `dispositionReasonId`). List every component, pipe, service, query, and template that touches the equivalent data. This surfaces read-side consumers (search results, detail views, reports, review screens) that are easy to overlook when focused on the write path. Classify each consumer as **in-scope** or **explicitly out-of-scope** with a one-line rationale.

### 3b. Generate Probing Questions

Produce **3–8 focused questions** (not more) across these categories. Skip categories that are genuinely irrelevant, but you must cover at least 3 categories:

| Category                        | What to probe                                                                                                                                                                                                   |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Scope boundaries**            | What is explicitly out of scope? What adjacent code/features should NOT be touched?                                                                                                                             |
| **Data lifecycle (read path)**  | If this feature persists new data: where is it displayed after save? (Search results, detail views, reports, exports, review/QR screens, dashboards.) Which read-only or comparison views must also be updated? |
| **Edge cases & error handling** | What happens on failure, empty states, concurrent access, invalid inputs? Should errors be silent, logged, or surfaced to the user?                                                                             |
| **Integration contracts**       | What does the interface between this work and existing code look like? Are there consumers that depend on current behavior?                                                                                     |
| **Acceptance criteria gaps**    | For each AC, is the "how to verify" clear? Are there implicit ACs not stated in the ticket?                                                                                                                     |
| **Non-functional requirements** | Performance targets, backward compatibility, migration path, feature flags, rollback strategy?                                                                                                                  |
| **Testing expectations**        | Unit tests? Integration tests? What level of coverage? Any specific scenarios to test?                                                                                                                          |
| **Ambiguity & trade-offs**      | Where are there multiple valid approaches? What trade-offs should the user weigh in on?                                                                                                                         |

### 3c. Ask and Wait

- Present questions as a concise numbered list, grouped by category.
- Briefly explain _why_ each question matters (one sentence) so the user understands the impact of their answer.
- **STOP and wait for the user's answers.** Do NOT proceed to Step 4 until you have responses.
- If the user's answers reveal further ambiguity, ask follow-up questions (but keep it to one additional round max).

## Step 4: Organize into Phases

All plans — regardless of size — must be organized into **phases**. Phases group related steps that belong to the same layer or logical unit of work. Each phase will be implemented in a **separate agent session** for optimal token efficiency and implementation quality.

### 4a. Identify Phases

Group the planned work into phases based on:

- **Layer/domain boundaries** (e.g., shared interfaces, backend, frontend facade, frontend UI, cleanup, testing).
- **Dependency order** — earlier phases should not depend on later ones.
- **Cohesion** — steps within a phase should modify related files and serve a single purpose.

Each phase should be **small enough to implement in one focused session** (roughly 3–6 actionable steps). If a phase has more than 6 steps, split it further.

### 4b. Determine Phase Batching Hints

Evaluate which adjacent phases could be **implemented together in a single session** to save the overhead of a new session. Two phases can be batched if:

- They modify the **same files** (e.g., shared interfaces + the backend that consumes them).
- Their combined step count is **≤ 6 steps**.
- One is trivially small (1–2 steps) and logically depends on the other.

Record batching hints — these are **suggestions**, not requirements. The user decides whether to batch or separate.

Proceed to Step 5.

## Step 5: Draft the Plan

**Append** the following sections to the plan file. This plan must be **self-sufficient** — a fresh agent session with a less powerful model should be able to execute it without asking clarifying questions or rediscovering context.

### 5a. Context for Implementer

Append a `## Context for Implementer` section containing:

- **Relevant files & modules** — list the key files the implementer will need to read or modify, with a one-line description of each file's role.
- **Existing patterns to follow** — describe any established patterns, abstractions, or conventions in the codebase that this work should align with. Include brief code snippets if helpful.
- **Architectural constraints** — note any system boundaries, performance considerations, or compatibility requirements.
- **Key terminology** — define any domain-specific terms the implementer needs to understand.

This section replaces the need for the implementer to "explore and understand" — give them the understanding directly.

### 5b. Q&A Log

Append a `## Q&A Log` section that records every question asked during the Discovery Interview (Step 3) along with the user's answer. This preserves nuance that would otherwise be lost when the plan is handed off to a new session.

Format:

```markdown
## Q&A Log

1. **Q:** [question asked]
   **A:** [user's answer]
   **Impact on plan:** [how this answer shaped a specific plan decision]
```

### 5c. Scope Boundary

Append a `## Scope Boundary` section that explicitly partitions what is **in scope** and **out of scope** for this plan. This section should be written early in the plan file (before detailed steps) so reviewers can catch omissions before investing in the full plan.

Format:

```markdown
## Scope Boundary

### In Scope

- [component / feature / screen] — [reason it's included]
- ...

### Out of Scope

- [component / feature / screen] — [reason it's excluded]
- ...
```

Populate this using the blast-radius analysis from Step 3a and answers from the discovery interview. Every consumer identified in the blast-radius analysis must appear in one of the two lists.

### 5d. Plan Steps (Organized by Phase)

Append a `## Plan` section. Organize steps under phase headings:

```markdown
## Plan

### Phase 1: [Name] (e.g., "Shared Interfaces")

> **Batching hint:** Can be combined with Phase 2 (same files, 5 total steps).

1. [step]
2. [step]
3. [step]

### Phase 2: [Name] (e.g., "Backend API")

4. [step]
5. [step]
```

Each step should be:

- **Actionable** — a single, concrete step (not a vague category).
- **Ordered** — listed in the sequence they should be executed.
- **Scoped** — reference specific files or modules where possible.
- **Detailed enough to execute** — include the _what_ and _how_, not just the _what_. If a step involves a non-obvious approach, briefly explain the approach.

Mark critical-path steps with a `[critical]` tag.

Each phase heading should include a **batching hint** (as a blockquote) if it can be combined with an adjacent phase. If a phase must be implemented alone, omit the hint.

> **Why phases matter:** The user will start a new agent session for each phase (or batch). The session receives only this plan file — the phase heading tells the implementer exactly which steps to execute and which files are in scope.

### 5e. Assumptions & Risks

Append a `## Assumptions & Risks` section listing:

- **Assumptions** — things the plan takes as true that were not explicitly confirmed. If any assumption is wrong, the implementer should stop and re-plan.
- **Risks** — areas where the plan is most likely to need adjustment during implementation.

Format:

```markdown
## Assumptions & Risks

| #   | Type       | Statement                                                       | Impact if wrong                                  |
| --- | ---------- | --------------------------------------------------------------- | ------------------------------------------------ |
| 1   | Assumption | The `UserService` already handles token refresh                 | Would need to add refresh logic, adding ~3 steps |
| 2   | Risk       | The DB migration may conflict with team X's in-flight migration | Coordinate with team X before executing step 4   |
```

### 5f. Phase Complexity Assessment

After all steps and assumptions are written, assess the **implementation complexity** of each phase. This classification helps the user select the most token-efficient model for each phase's execution session while maintaining correctness.

#### Complexity Tiers

| Tier | Label               | Description                                                                                                                                | Model Guidance                |
| ---- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------- |
| 1    | **Straightforward** | Clear instructions, mechanical changes, single-file or pattern-following. A basic model can execute without issues.                        | Haiku / basic model           |
| 2    | **Moderate**        | Multi-file or some decision-making required, but scope is well-defined and patterns exist to follow.                                       | Sonnet / Opus (standard)      |
| 3    | **Complex**         | Cross-cutting concerns, multiple interacting files/systems, requires reasoning to understand the full picture for optimal results.         | Sonnet with extended thinking |
| 4    | **Highly Complex**  | Architectural decisions, novel patterns, large blast radius, or subtle correctness requirements. Needs the best model with deep reasoning. | Opus with extended thinking   |

#### How to Assess

For each phase, consider:

- **Number of files and their interdependencies** — more files with tight coupling = higher complexity.
- **Novelty** — following an existing pattern (lower) vs. creating a new abstraction (higher).
- **Decision density** — steps that say "do X" (lower) vs. steps that require judgment calls (higher).
- **Blast radius** — isolated changes (lower) vs. changes with many downstream consumers (higher).
- **Error subtlety** — obvious failures like compile errors (lower) vs. silent behavioral regressions (higher).

#### Output Format

Embed the classification directly in each phase heading:

```markdown
### Phase 1: Shared Interfaces — ⚡ Straightforward

> **Batching hint:** Can be combined with Phase 2.
> **Complexity:** Straightforward — mechanical type additions following existing pattern in `models/`.
```

Also append a summary table at the end of the `## Plan` section:

```markdown
#### Phase Complexity Summary

| Phase | Classification  | Recommended Model | Rationale                                                 |
| ----- | --------------- | ----------------- | --------------------------------------------------------- |
| 1     | Straightforward | Haiku / basic     | Mechanical type additions, single file                    |
| 2     | Moderate        | Sonnet            | Multi-file but follows existing pattern                   |
| 3     | Complex         | Sonnet + thinking | Novel integration across 4 services                       |
| 4     | Highly Complex  | Opus + thinking   | New architectural pattern, subtle correctness constraints |
```

> **Note:** These are recommendations, not requirements. If in doubt, err toward one tier higher — the cost of a slightly more powerful model is lower than the cost of a failed implementation attempt that needs to be redone.

Use the `edit` tool to append to the existing plan file created in Step 2. Only post a brief one-line summary in chat pointing the user to the file (e.g., "Plan written to `~/.windsurf/plans/PROJ-123-add-auth.md`.").

## Step 6: Record Design Decisions

After drafting the plan, **append** a `## Design Decisions` section to the plan file. This section captures every meaningful choice made during planning — both decisions driven by your own analysis and decisions made collaboratively with the user (e.g., answers from Step 3 or sub-module confirmations from Step 4).

For each decision, record:

- **Decision** — what was decided (e.g., "Use optimistic UI updates instead of refetching").
- **Rationale** — why this choice was made (constraints, trade-offs, user preference, existing patterns, etc.).
- **Alternatives considered** _(optional)_ — briefly note any rejected alternatives if relevant.

Format as a numbered list. Example:

```markdown
## Design Decisions

1. **Use existing `AuthService` rather than creating a new one.**
   Rationale: The service already handles token storage and refresh logic; extending it avoids duplication and aligns with the existing pattern in `libs/shared/angular/auth`.

2. **Scope changes to the `user-profile` feature lib only.**
   Rationale: User confirmed that the change should not affect the admin portal; isolating it to the feature lib prevents unintended side effects.
```

If no significant decisions were made (trivial tasks), you may omit this section or write "No significant design decisions."

## Step 7: Self-Sufficiency Check (Quality Gate)

Before presenting to the user, critically evaluate the plan against this checklist:

- [ ] Could a new agent session execute this plan **without asking clarifying questions**?
- [ ] Are all file paths and module references **specific** (no "the relevant file" or "the appropriate module")?
- [ ] Does the plan capture **why** each approach was chosen, not just **what** to do?
- [ ] Are edge cases and error handling addressed in the steps (not left for the implementer to figure out)?
- [ ] Would someone unfamiliar with the conversational context understand the full scope from the plan file alone?
- [ ] If new data is persisted, does the plan cover **both the write path AND all read-path consumers** (display views, search results, exports, review screens)?

If any answer is "no," revise the plan before proceeding. Add missing specificity, context, or rationale.

## Step 8: Confirm with User

End your response by asking the user to review the plan and confirm before execution begins. For example:

> Does this plan look good? Let me know if you'd like to adjust anything before I start.

---

## General Rules

- **Always follow workspace rules and conventions** defined in `.windsurf/rules/` and `guidelines.md`.
- **Never assume** — if uncertain, ask.
- **Keep plans lean** — avoid unnecessary steps. Each step should move the task forward meaningfully.
- **Reference existing patterns** — when the codebase already has a pattern for what's being built, call it out and follow it.
