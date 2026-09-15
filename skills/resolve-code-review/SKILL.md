---
name: resolve-code-review
description: Triage code review findings (pasted by the user, optionally alongside an implementation plan) — evaluate each finding's validity against the actual code before acting, fix the ones that hold up (using a better implementation than the suggestion if one exists), and give an evidence-based rationale for the ones rejected.
---

# Resolve Code Review

Code review comments are **claims to verify, not instructions to obey**. A reviewer (human or AI) can be wrong, working from stale context, or suggesting a fix that's technically valid but not the best one available. This skill's job is to sit between "finding received" and "code changed" and force a real judgment call at every step — never a blind apply.

---

## ⛔ The Core Invariant (read first)

**Never patch code solely because a finding says to.** For every finding, independently confirm the problem exists in the actual codebase before touching anything. If you cannot verify the claim, that itself is the finding: say so and ask, don't guess.

**Never accept the suggested fix as-is by default either.** Once a finding is confirmed valid, treat the reviewer's suggested change as one candidate, not the answer. Check the surrounding code, existing patterns, and simpler/safer alternatives before implementing. If your own approach is better, use it and say why.

---

## Step 0: Gather Inputs

### 0a. Collect the findings

- The user pastes one or more code review findings directly in chat, or references a file/PR containing them.
- If findings reference a GitHub PR review (e.g., "resolve the comments on PR #42"), use the `github-manager` skill to fetch the review comments (`GET /repos/{owner}/{repo}/pulls/{number}/comments`) rather than asking the user to re-type them.
- Normalize the input into a numbered list of discrete findings. Split multi-issue comments into separate findings — each should be independently triageable. Preserve the file/line the finding points at, if given.
- If a finding is too vague to locate in the codebase (no file, no symbol, no quoted code), ask the user to clarify that specific finding rather than guessing at scope. Do not block the rest of the batch on it.

### 0b. Collect the optional implementation plan

- If the user references a plan file (e.g., from `~/.windsurf/plans/`), read it in full. It provides intent and design decisions that inform whether a finding is actually a deviation from the agreed approach or a legitimate new issue.
- If no plan is provided, proceed without one — it's optional context, not a gate.

### 0c. Read repo context

- If the repo has a `CONTEXT.md` (root, and app-level in a monorepo), read it. A finding that contradicts a recorded durable decision needs that decision weighed explicitly in the rationale, not silently overridden.

---

## Step 1: Triage Each Finding

Work through findings **one at a time**. For each, do independent verification before forming an opinion:

1. **Locate the code** the finding refers to. Read the actual file/function/lines — not just the diff hunk quoted in the finding, but enough surrounding context (callers, related tests, the pattern used elsewhere in the file) to judge it properly.
2. **Verify the claim.** Is the described problem real? Reproduce the reasoning yourself: trace the code path, check the type, run the relevant test if one exists. A finding is only "confirmed" when you can point to concrete evidence (`file:line` or behavior), not because the reviewer sounded confident.
3. **Weigh against intent.** If a plan or `CONTEXT.md` is available, check whether the finding conflicts with an already-agreed decision. If it does, that's a factor in the rationale either way — either the decision needs revisiting (say so) or the finding misunderstands the intent (say why).
4. **Classify the verdict**:

   | Verdict | Meaning |
   | --- | --- |
   | **Accept** | The problem is real and worth fixing as raised. |
   | **Accept (modified)** | The problem is real, but the suggested fix isn't the best option — you'll implement a different fix. |
   | **Reject** | The finding does not hold up — not a real problem, already handled elsewhere, out of scope, or based on a misreading of the code. |
   | **Needs input** | You cannot confirm or refute the finding without more information from the user (ambiguous intent, missing context, a genuine tradeoff call that isn't yours to make unilaterally). |

Do not skip straight to fixing. Form and record the verdict for every finding before writing any code.

---

## Step 2: Act on the Verdicts

### 2a. Accept / Accept (modified)

- Before writing the fix, briefly check for a better implementation than the one suggested: does the codebase already have a helper/pattern for this? Is there a simpler fix that addresses the root cause rather than the symptom? Does the suggested fix introduce its own issue (e.g., swallowing an error, over-broad type, missed edge case)?
- If your implementation differs from the suggestion, that's expected and fine — note *why* in the summary (Step 3). Don't silently diverge without explanation.
- Make the code change. Keep it scoped to the finding — don't use this as an opportunity for unrelated refactoring.
- If the finding revealed a pattern likely repeated elsewhere (e.g., the same bug in a sibling file), check for other occurrences and flag them even if not explicitly raised — but confirm with the user before fixing instances outside the original scope.

### 2b. Reject

- Do not change the code.
- Prepare a concrete rationale for Step 3 — this must cite evidence (`file:line`, test output, or a quoted `CONTEXT.md` decision), not just "I disagree."

### 2c. Needs input

- Do not guess. Collect these and ask the user together at the end of triage (or immediately if it blocks other findings), rather than interrupting one at a time.

### 2d. Verify

- After implementing all accepted fixes, run the relevant tests/linter for the touched files. A finding is not resolved if the fix breaks something else.

---

## Step 3: Report Back

Summarize every finding with its verdict and outcome, in the original order. Keep each entry tight — this is a decision log, not an essay.

```markdown
## Code Review Resolution

1. **[Accept]** <one-line finding summary> — `file:line`
   Fixed: <what changed and why>

2. **[Accept (modified)]** <one-line finding summary> — `file:line`
   Suggested fix: <short paraphrase>. Implemented instead: <what and why it's better>.

3. **[Reject]** <one-line finding summary> — `file:line`
   Rationale: <concrete evidence for why this doesn't hold up>

4. **[Needs input]** <one-line finding summary>
   Question: <what you need from the user>
```

Close with a one-line overall status: how many accepted, modified, rejected, and pending user input.

---

## Rules

- Never modify code for a **Reject** or unresolved **Needs input** finding.
- Never apply a suggested fix verbatim without checking it's actually the best approach — the reviewer's proposed code is a hint, not a spec.
- Every Accept or Reject verdict must be backed by something you checked in the code (or a test you ran), not just plausibility.
- Keep fixes scoped to the finding. Don't bundle unrelated cleanup into the same change.
- If a finding is itself ambiguous or contradicts recorded intent (plan / `CONTEXT.md`), surface that conflict explicitly rather than picking a side silently.
- At any point, if you're not confident enough to verify a finding one way or the other, say so and ask — don't fabricate certainty.
