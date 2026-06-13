---
description: Cold-read adversarial review of a finished implementation plan. Runs in a fresh session with no planning context, verifies the plan's claims against the actual codebase, and produces a verdict (SHIP / REVISE / BLOCK) with evidence-backed findings written to a sibling review file. Findings-only — it never edits the plan.
---

# Review Plan

A finished implementation plan is the highest-leverage artifact in the workflow — a flawed assumption or a redundant step there multiplies across every execution phase. This skill is an **adversarial cold read** of that plan: it pokes holes the author could not see, and it confirms the plan is actually self-sufficient before any execution session is spent on it.

It is the complement to the planner's own `3b Pushback` step — not a replacement:

- **`3b Pushback`** runs inside the planner, **before the plan exists**, interactively, against the **ticket/requirements** (the input). It kills bad premises cheaply, before the plan is built on them.
- **This skill** runs **after the plan is finished**, coldly, against the **plan** (the output). It catches emergent flaws — redundant steps, inefficiency, wrong assumptions — that only become visible once the whole plan is on the page.

Keep both. Each catches a failure class the other structurally cannot.

---

## ⛔ The Cold-Read Invariant (read first)

**This skill's entire value is being a context that has NOT seen the planning conversation.** A reviewer that helped write the plan will rubber-stamp its own assumptions — that is just the planner's Step 7 self-check again, which is the weak link this skill exists to replace.

- This skill is meant to be invoked **manually, in a fresh session**, after `ticket-to-plan` or `planner` has finished.
- If you detect that this same session produced or revised the plan under review, **STOP** and tell the user: _"Plan review must run in a fresh session — the current session has planning context, which defeats the cold read. Please re-run `/review-plan` from a new session."_ Do not proceed.

---

## Step 0: Locate Inputs & Gate

### 0a. Resolve the plan file (required)

```
/review-plan <path-to-plan-file>            # cold read of plan + repo
/review-plan <path-to-plan-file> <TICKET>   # + cross-check intent against the raw ticket (optional)
```

- The user must provide a plan file path (typically in `~/.windsurf/plans/`).
- If no path is given, list `~/.windsurf/plans/` and ask which plan to review. Do NOT guess.
- Read the plan file **in full** before doing anything else.

### 0b. Note the optional ticket

- If the user passed a Jira ticket ID, you may fetch it via the `jira-manager` skill in Step 4 (the intent backstop) to check for drift between what was asked and what was planned.
- If no ticket is provided, that is the normal case. Review **purely against the plan's own `## User's Intent` section** — and treat any place the intent is unclear as itself a finding.

### 0c. Derive the review file path

- The review is written to a **sibling file** next to the plan: `{plan-filename-without-ext}-review.md` in the same directory.
  - e.g. plan `~/.windsurf/plans/OASIS-495-sync-upstart.md` → review `~/.windsurf/plans/OASIS-495-sync-upstart-review.md`.
- The plan file itself is **never modified by this skill** (findings-only).

---

## Step 1: Ground the Review in Reality

A review that only reads the plan is a vibe check. Before judging anything, build an independent picture of the actual code:

- Read the root `CONTEXT.md` and, in a monorepo, the `apps/<app>/CONTEXT.md` for the app this plan touches. These are the authoritative glossary and durable-decision record.
- Read the files the plan's own **`## Context for Implementer`** section names. Judge the plan against the *real* code, not against the plan's description of the code.
- Skim the broader area the plan touches enough to reason about consumers and integration points the plan may have missed.

You now have two pictures: what the plan **says** is true, and what the repo **actually** is. The review lives in the gap between them.

---

## Step 2: Lens A — Correctness

**Verify, don't vibe.** This is what separates this skill from review theater. Every Major-or-worse finding must be backed by a concrete repo fact (`file:line`), not an impression.

Work through:

- **Factual claims** — every claim the plan makes about the codebase ("the facade already exposes X", "`UserService` handles token refresh"). Grep/read to confirm or refute each one. A refuted claim is a finding with `file:line` evidence.
- **Assumptions & Risks table** — treat each assumption as a hypothesis to falsify. Can you find evidence it is wrong? An assumption the plan relies on but that the code contradicts is at least a Major.
- **Blast-radius re-check (mandatory for data-model changes)** — if the plan adds or changes a field/column/entity property, independently grep for consumers of the *analogous existing field* and confirm the plan's Scope Boundary actually accounts for every one. Read-path consumers (search results, detail views, exports, reports, review screens) are the classic miss.
- **Sequencing** — does any phase or step depend on something a later phase produces? Flag ordering inversions.
- **Handoff-readiness, judged concretely** — you ARE the cold session the plan claims to support. Where did you have to **guess**, re-discover context, or resolve a vague reference ("the relevant service", "update as needed")? Each such spot is a finding. If you couldn't execute a step without asking a question, the plan failed its core promise.

---

## Step 3: Lens B — Necessity / Efficiency

Correctness asks "is the plan right?" This lens asks "is the plan **lean**?" — and it only works here, because it needs the whole finished plan in view at once. For each step and phase, ask:

- **Redundant?** Is this step made unnecessary by another step, or by the approach a different phase takes?
- **Already satisfied?** Does the current codebase already do this, making the step a no-op?
- **Leaner path?** Is there a materially simpler way to reach the same intent than what the plan prescribes?
- **Over-phased?** Is the work split into more phases/sessions than the dependencies justify (wasted session overhead), or batched in a way that hurts focus?

A single eliminable step is a legitimate Major finding — removing dead work is as valuable as fixing wrong work.

---

## Step 4: Lens C — Intent Backstop (secondary)

The planner's `3b` owns requirement-challenging, interactively and earlier. This lens is only a **safety net** for premises that slipped through:

- Compare the plan's approach against its `## User's Intent` (and the raw ticket, if one was passed).
- Is the prescribed approach the right one? Over-scoped? Under-scoped? Does it conflict with a `CONTEXT.md` decision?
- **Raise only if material.** Do not re-litigate requirements `3b` already settled, and do not manufacture an objection to fill this section.

---

## Step 5: Verdict & Findings

### 5a. Severity & verdict

Classify each finding by severity, then map to a single verdict:

| Severity   | Meaning                                                            |
| ---------- | ----------------------------------------------------------------- |
| **Blocker**| The plan's approach or a load-bearing premise is wrong — patching won't fix it. |
| **Major**  | A real flaw (wrong assumption, missed consumer, redundant/eliminable step, un-executable vagueness) that should be fixed before execution. |
| **Minor**  | A nit or improvement that the implementer can absorb without re-planning. |

| Verdict     | Trigger                          | Means                                                        |
| ----------- | -------------------------------- | ------------------------------------------------------------ |
| **SHIP**    | no Blocker and no Major          | Execute as-is. Minors are noted for the implementer.         |
| **REVISE**  | ≥1 Major, all fixable in place   | Hand findings to a **fresh planner session** for one revision round, then execute. |
| **BLOCK**   | ≥1 Blocker                       | Re-plan — do not patch around a wrong approach.              |

### 5b. Anti-theater guardrails (mandatory)

- **A clean pass is a valid, expected outcome.** If, after genuine verification, you find no Major-or-worse issue, the verdict is **SHIP**. Do NOT inflate Minor nits into a REVISE to justify having run.
- **No evidence → not a Major.** Every Blocker/Major must cite a concrete repo fact (`file:line`) or a specific un-executable passage in the plan. If you can't back it, downgrade it to Minor or drop it.
- **Findings-only.** This skill never edits the plan file. It produces the review; the planner (or the user in their editor) applies fixes. This preserves the cold, adversarial stance — a reviewer that also rewrites re-imports author bias.
- **One pass.** Review the plan once. Do not loop-review your own re-reviews.

### 5c. Write the review file

Write the sibling review file (from Step 0c) with this structure. Post only a one-line summary in chat pointing to it plus the verdict.

```markdown
# Plan Review — {plan filename}

**Reviewed:** YYYY-MM-DD
**Plan:** `~/.windsurf/plans/{plan}.md`
**Verdict:** SHIP | REVISE | BLOCK

## Summary

<2–3 sentences: overall judgement and the single most important takeaway.>

## Findings

### [Blocker | Major | Minor] · [Correctness | Efficiency | Intent] — <short title>

- **Claim / step:** <what the plan says or does>
- **Evidence:** <file:line or the specific plan passage>
- **Fix:** <concrete recommendation>

<repeat per finding, ordered Blocker → Major → Minor>

## Clean checks

<one line each for the high-value things you verified that held up — e.g. "Blast radius: all 6 consumers of `primaryReason` are accounted for in Scope Boundary." This shows the review was real, not skipped.>
```

If there are no findings at all, still write the file with an empty Findings section, a SHIP verdict, and a populated **Clean checks** list — an evidence-backed all-clear is a real result.

### 5d. Hand off

Close in chat with the verdict and the next action:

- **SHIP** → _"Review: SHIP. `…-review.md` written. Plan is good to execute — start a new session with the recommended model and run `/execute-plan`."_
- **REVISE** → _"Review: REVISE — N Major findings in `…-review.md`. Recommend a fresh planner session to address them (one round), then execute."_
- **BLOCK** → _"Review: BLOCK — the approach has a fundamental issue (see `…-review.md`). Recommend re-planning rather than patching."_

---

## Important

- **Run cold.** If this session has planning context, abort (see the Cold-Read Invariant).
- **Verify against the repo, always.** Unsubstantiated criticism is worse than no review.
- **Never edit the plan.** Findings-only, by design.
- At any point, if the plan file is missing, malformed, or you cannot access the repo, **stop and tell the user** rather than reviewing blind.
- Follow all workspace rules and conventions defined in `.windsurf/rules/`.
