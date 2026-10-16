---
name: planner
description: Draft a grounded implementation plan for a task or Jira ticket. Use when planning changes, clarifying consequential requirements, or preparing a fresh-session handoff. Adapts depth to risk and preserves decisions, scope, and executable acceptance checks.
---

# Planner Skill

Produce a plan that reduces implementation uncertainty, not a longer task list. Planning does not authorize implementation, commits, or external updates.

## Output and Compatibility

- Write the plan to `~/.windsurf/plans/` (Windows: `$env:USERPROFILE\.windsurf\plans\`). This is the shared location used by companion skills; it does not require the Windsurf editor.
- Use `{jira_ticket_id}-{short-descriptive}.md`, or a kebab-case slug when no ticket is associated. Report the actual path in chat.
- Use the host's available file-editing tools; do not assume tools named `write_to_file`, `edit`, or `skill` exist.
- Retain `## User's Intent`, `## Context for Implementer`, `## Scope Boundary`, `## Plan`, `## Assumptions & Risks`, and `### Phase N: Name` headings in both modes. Companion skills use these sections and phase completion markers. Include `## Design Decisions` and `## Q&A Log` only when they contain useful information.
- Read a matching existing plan before updating it. Preserve completed phases, implementation notes, user decisions, and unresolved work. Never silently overwrite execution history. If multiple plans match, ask which one to update.
- Existing plans need not be reformatted wholesale. Apply the checks below to the affected remaining work and retain historical sections.

## Step 1: Ground the Request and Choose Depth

1. Read the request, applicable repository instructions, and the named files or controlling implementation. Follow the host's instruction-discovery rules, not only `.windsurf/rules/`.
2. Read relevant root/app `CONTEXT.md` files if present. Respect recorded decisions and flag conflicts; missing context files are not blockers and need not be scaffolded.
3. Inspect the nearest relevant tests, callers, and project commands. Identify what controls the requested behavior and how to verify it. Expand investigation only for a specific unresolved dependency or risk.
4. Locate the existing plan by ticket prefix or task slug, and choose its filename before writing.
5. Choose a mode and briefly state why:

| Mode             | Use when                                                                                                            | Required depth                                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Lightweight**  | Localized, well-understood work with established patterns and readily verifiable behavior                           | Concise required sections, normally one phase; no interview unless a consequential uncertainty remains         |
| **Full handoff** | Cross-cutting changes, migrations, ambiguous behavior, subtle correctness risks, or execution across fresh sessions | Explicit dependencies, interface contracts, evidence, risks, and enough context for each phase to start safely |

Honor an explicit user preference for depth, but do not omit consequential scope or safety checks. Full handoff does not automatically mean multiple phases. Escalate depth when investigation reveals greater risk; explain why.

## Step 2: Record Intent and Planning State

Create or update the plan using the host's file tools. Start with `## User's Intent`: summarize the goal, scope, constraints, and observable acceptance criteria without prescribing implementation.

Record concise metadata:

- Mode and status: `Draft`, `Ready`, `In progress`, or `Blocked`.
- Repository identity/root, branch, inspected commit (if available), and date.
- Relevant uncommitted changes, if any. A commit alone does not describe a dirty worktree.
- Ticket/reference and the scope of this revision, if updating a plan.

Mark a plan awaiting answers as `Draft` or `Blocked`, never `Ready`. Do not claim repository evidence you have not inspected.

## Step 3: Resolve Consequential Uncertainty

### 3a. Investigate Dependencies and Blast Radius

- Follow existing patterns and inspect shared interfaces and downstream callers relevant to the change.
- For data-model changes, search consumers of the changed field and any analogous existing field. Inspect both write and read paths: services, queries, templates, detail/search views, reports, exports, and comparison/review screens.
- Classify each identified consumer as in scope or explicitly out of scope with a short rationale. Record search boundaries and any unresolved dynamic or external consumers; do not claim exhaustive coverage without evidence.
- For other changes, scale consumer analysis to the affected contract and risk rather than mapping the whole repository.

### 3b. Challenge the Approach

Evaluate the strongest material objection and the simplest alternative. Present pushback when it changes scope, correctness, or cost, with a recommendation grounded in code or requirements. Record consequential resolved trade-offs under `## Design Decisions`.

If the approach is sound, proceed. Do not manufacture objections or require a ceremonial all-clear block.

### 3c. Apply the Uncertainty Gate

Ask only questions whose answers materially change behavior, scope, compatibility, safety, acceptance criteria, or an expensive-to-reverse decision.

- First resolve factual questions from code, tests, instructions, and context files.
- For each remaining user decision, give a concrete scenario, a recommended answer with rationale, and the consequence of choosing differently.
- Batch related questions concisely. There is no minimum question count or category quota.
- If a decision blocks a safe plan, ask and wait. Keep the plan `Draft` or `Blocked` until resolved. A follow-up round is warranted only for a newly exposed consequential ambiguity.
- For reversible implementation details that do not affect the user contract, select the existing pattern and record an unconfirmed default as an assumption when it matters. Do not interrupt the user for routine choices.
- If no blocking questions remain, proceed without an interview. Do not invent user approval.

Record actual questions, answers, and their effects in `## Q&A Log`. Keep it brief and reference decision entries rather than copying their rationale.

## Step 4: Define Verifiable Phases

- Use one phase for small tasks. Split larger work into cohesive, independently verifiable increments ordered by dependencies, not automatically by frontend/backend layers.
- Keep tightly coupled changes together. A required shared-contract change and its consumers should not leave the repository broken between phases.
- Size phases by coupling, uncertainty, validation cost, and context needed, not a fixed number of steps.
- Name prerequisite phases and exact interfaces/artifacts they provide. Independent phases may be marked independent; do not assume concurrent execution is authorized.
- Default to a buildable, testable repository at each phase boundary. If an intermediate state must be non-deployable, flag it, explain why, and mark the coupled phases as a required batch before implementation handoff.
- Suggest batching only when dependencies, shared files, and validation support it. Session boundaries are optional, not a claim of guaranteed token savings.

## Step 5: Complete the Plan

Keep these sections concise; expand only where it prevents a likely implementation mistake.

### Context for Implementer

Under `## Context for Implementer`, provide:

- Specific relevant files/symbols and their roles, including nearby tests and existing patterns.
- Architectural/compatibility constraints and non-obvious domain terms.
- Verified facts with source paths/symbols; separate these from user decisions and unverified assumptions.
- Exact interface contracts required by downstream phases where relevant.
- A short preflight: verify repository identity, branch, relevant worktree changes, target files/contracts, and validation commands against the recorded snapshot before editing. A changed commit is a signal to inspect relevant differences, not automatic proof the plan is invalid.

This is a starting map, not a substitute for checking the code. Do not copy large snippets or promise that implementation needs no investigation.

### Scope Boundary

Under `## Scope Boundary`, partition in-scope and out-of-scope behavior and consumers with reasons. Include every consumer identified in Step 3a. State unresolved external boundaries explicitly.

### Plan and Phase Completion Contracts

Under `## Plan`, write ordered, actionable steps referencing concrete files/modules and explaining non-obvious approaches. Tag genuine critical-path steps `[critical]`.

Each phase must include a completion contract:

```markdown
### Phase 1: Name

> Complexity: Straightforward | Moderate | Complex | Highly Complex - brief rationale.
> Dependencies: None, or prerequisite phases and required interfaces/artifacts.
> Batching hint: Optional; mark required batches explicitly.

1. Concrete implementation step with target files and approach.
2. Relevant regression coverage and validation.

**Completion contract**

- Observable result: Specific behavior or artifact that satisfies the linked acceptance criterion.
- Validation: Exact commands, working directory, and expected outcomes; identify relevant test scenarios.
- Boundary state: Buildable/testable, or explicitly non-deployable until a named required batch completes.
- Handoff: Interfaces, deviations, or unresolved constraints the next phase needs; omit when not applicable.
```

Use real repository commands, not guessed targets. Cover meaningful behavior and affected consumers, not only lint. For exported TypeScript contracts consumed by Angular apps, include `nx build <affected-app>` alongside appropriate library checks; library lint/tests alone may miss consumer type errors.

If a required check needs unavailable tools, credentials, or external infrastructure, name the blocker, provide a concrete manual/deferred check, and state who must verify it. Do not imply it passed. Planning-time checks may verify existing behavior or command availability; do not run deployments or mutating workflows merely to validate a plan.

Acceptance criteria must map to a phase result and a check. Validation belongs with the phase, not solely in a final testing phase.

### Assumptions, Risks, and Decisions

- Under `## Assumptions & Risks`, distinguish unverified assumptions from known risks. Use a table with ID, type, statement, evidence/verification needed, impact, and response if wrong. Write `None identified` when appropriate rather than filling the section with generic risks.
- Pause and re-plan for invalidated assumptions that alter scope, user behavior, safety, or compatibility. Resolve minor reversible implementation details locally and record downstream-relevant deviations.
- Under `## Design Decisions`, record only consequential choices, rationale, and meaningful rejected alternatives. Link Q&A entries where relevant rather than repeating them.
- For full-handoff plans with multiple phases, add a `#### Phase Complexity Summary` table with phase, classification, and rationale. Classify by coupling, novelty, decision density, blast radius, and failure subtlety, not file count alone.
- Do not copy generic model-selection advice into every plan or require a per-phase model recommendation. When asked, suggest capabilities based on complexity and demonstrated repository performance. Use the lowest-cost option that reliably meets the same checks; account for retries and review, not token price alone.

Complexity labels describe the work, independently of model choice:

| Label           | Meaning                                                                         |
| --------------- | ------------------------------------------------------------------------------- |
| Straightforward | Mechanical or pattern-following work with readily verifiable results            |
| Moderate        | Bounded multi-file changes with some local judgment and established patterns    |
| Complex         | Interacting contracts or subtle failures requiring cross-file reasoning         |
| Highly Complex  | Consequential architectural choices, novel patterns, or broad correctness risks |

## Step 6: Handoff Readiness Gate

Before marking the plan `Ready`, verify:

- [ ] Goal, acceptance criteria, scope exclusions, and consequential user decisions are explicit.
- [ ] A fresh session can start safely from named files, patterns, dependencies, and interface contracts without guessing product requirements.
- [ ] Verified facts have evidence; assumptions are clearly labeled with a response if invalidated.
- [ ] Changed contracts and identified read/write consumers are accounted for, including unresolved external boundaries.
- [ ] Each phase has an observable result and exact validation commands with expected outcomes, or an explicit blocked/manual check.
- [ ] Dependencies are ordered and intermediate states are safe or explicitly required to be batched.
- [ ] Failure modes relevant to the task are addressed rather than delegated as vague "handle edge cases" steps.
- [ ] Preflight explains when to adapt locally versus stop and re-plan.
- [ ] Existing completion markers, implementation notes, and approved decisions remain intact.
- [ ] The plan contains no unnecessary phases, duplicate rationale, or invented certainty.

Revise failures before handoff. If unresolved requirements prevent readiness, keep the status `Blocked` and report the specific decision needed. An unavailable execution check may remain explicitly deferred; it must not be treated as a completed phase check.

## Step 7: Close and Propose Durable Context

Report the plan path, selected mode, readiness, first phase, and any blocking/deferred checks. A fresh session is useful when context isolation helps; it is not mandatory for each phase. Do not implement the plan unless the user separately asks.

Propose `CONTEXT.md` updates only for non-obvious repo terms or durable decisions that are hard to reverse, surprising without context, and the result of a genuine trade-off. Propose corrections to outdated entries. Apply only user-approved updates; otherwise leave context files untouched. Omit an empty proposal section.

## Evaluate This Workflow

When the user requests evaluation, compare native planning and this skill on representative, similarly scoped tasks with the same model/tool setup. Track missed requirements, clarification rounds, rework, total elapsed time/cost, and fresh-session handoff success. Treat these as observed outcomes, not guarantees. Do not add evaluation bookkeeping to ordinary plans.
