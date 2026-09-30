---
name: execute-review-correct
description: Executes an implementation plan via `execute-plan`, runs a cold sub-agent code review of the resulting diff, then invokes `resolve-code-review` to triage and fix whatever the review surfaces — a single execute → review → self-correct pass.
---

# Execute, Review, Correct

Chains three existing skills into one guarded pass: `execute-plan` implements the phase(s), a **fresh, cold sub-agent** reviews the resulting diff for issues with none of the implementation session's bias, and `resolve-code-review` triages and fixes what the review surfaces. This catches the implementing session's own blind spots without the user having to manually run and paste a review.

```
/execute-review-correct <plan-file-path> [Phase N | Phase N-M | next phase]
```

Same invocation form as `/execute-plan` — this skill is a drop-in wrapper around it.

---

## Step 0: Verify Prerequisites (HARD GATE)

- The user must supply the same information `/execute-plan` requires: a plan file path (or enough context to locate one) and which phase(s) to run. If missing, resolve it exactly as `execute-plan`'s own Step 0 does (list `~/.windsurf/plans/`, ask which plan/phase) — do not guess.
- Capture the **pre-implementation git state** (e.g. `git rev-parse HEAD` and `git status --porcelain`) before Step 1 starts. Step 2 needs this to diff exactly what this run changed, not the whole working tree.

---

## Step 1: Execute the Plan

- Delegate to the `execute-plan` skill with the plan file path and target phase(s) exactly as given/resolved in Step 0. Let it run its full procedure: implement steps sequentially, run tests, and update the plan file with implementation notes.
- Run this **in this session**, not a sub-agent — implementation needs the full plan and repo context that a cold read would just have to rediscover.
- If `execute-plan` stops to ask the user a question, or aborts because tests fail and it can't resolve them, stop here too — do not review a half-finished or aborted implementation.

---

## Step 2: Cold-Read Code Review (fresh sub-agent, mandatory)

> **Never run this review in this session.** This session just wrote the code, so it has full implementation context — reviewing here would just rubber-stamp its own decisions. The value of this step is a reviewer that saw none of the reasoning, only the result.

### 2a. Compute the diff

- Diff the working tree against the pre-implementation state captured in Step 0 (`git diff <captured-ref>`, or `git status --porcelain` plus per-file diffs if uncommitted). This exact diff is the sub-agent's review scope — not the whole repo.

### 2b. Invoke a fresh sub-agent

Give the sub-agent a single self-contained prompt (it has no access to this session's reasoning) instructing it to:

1. Review **only** the diff from 2a (paste it, or point to the commit range/file list) — not the entire codebase.
2. Read the plan file's target phase(s) for **intent** — what the change was supposed to accomplish — but treat the diff itself, not the plan's narrative, as the source of truth for what actually happened.
3. Check for real, evidence-backed issues, in this order, citing `file:line` for each:
   - **Correctness** — logic errors, wrong assumptions, missed edge cases, broken call sites, type mismatches.
   - **Security** — anything touching input handling, auth, secrets, or injection surfaces (OWASP Top 10 class issues).
   - **Consistency** — deviations from patterns already established elsewhere in the touched files/modules.
   - **Test coverage** — new logic without a corresponding test, or a test that doesn't actually exercise the change.
   - Do **not** flag style/formatting nits a linter would catch, and do not invent issues to justify having run — a clean diff is a valid, expected outcome.
4. Report back, as its **final message only**, a numbered list of findings, each self-contained with `file:line` and a one-line description of the problem — do not prescribe the fix as gospel, `resolve-code-review` judges that independently. If there are zero findings, the final message must say so explicitly.

### 2c. Do not proceed until the sub-agent returns its final message.

---

## Step 3: Self-Correct via `resolve-code-review`

### 3a. No findings

- If the sub-agent reported zero findings, skip straight to Step 4 — there is nothing to resolve.

### 3b. Findings present

- Delegate to the `resolve-code-review` skill **in this session**, passing:
  - The sub-agent's numbered findings list verbatim — do not summarize or pre-filter it, that triage is `resolve-code-review`'s own Step 1 job.
  - The plan file path as its optional implementation-plan input, so findings get weighed against recorded design decisions instead of being treated context-free.
- Let it run its full procedure: verify each finding against the actual code, classify Accept / Accept (modified) / Reject / Needs input, fix what holds up, and produce its resolution report.
- If it surfaces any **Needs input** findings, stop and ask the user — do not guess on its behalf.

### 3c. Re-verify after fixes

- If any finding was accepted and fixed, re-run the tests `execute-plan` ran in Step 1 for the affected phase(s). A fix that breaks a test is not done.

---

## Step 4: Report Back

Summarize for the user in one pass:

- Which phase(s) were executed (Step 1).
- The cold review's outcome: N findings, or "clean, no findings" (Step 2).
- If findings existed, the `resolve-code-review` resolution summary (Accept/Reject/Needs-input counts) — point to its report rather than re-pasting it in full.
- Final test status after any corrections.
- The plan file path, so the user knows where implementation notes and phase status now live.

---

## Important

- The review in Step 2 must always run in a fresh sub-agent — that is the entire point of this skill over just running `/execute-plan` alone.
- This is a single execute → review → correct pass, not a bounded loop like `plan-review-loop`. If the user wants another review round after correction, re-invoke this skill or run the review step manually.
- Never let `resolve-code-review` apply a fix it can't verify — its own "Needs input" escape hatch still applies here.
- At any point, if a prerequisite is missing or a step aborts, stop and tell the user rather than pushing through with a guess.
