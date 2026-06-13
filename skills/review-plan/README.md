# review-plan

Adversarial **cold read** of a finished implementation plan. Run it manually in a fresh session after `ticket-to-plan` or `planner`, before spending an execution session on the plan.

A finished plan is the highest-leverage artifact in the workflow — one bad assumption or redundant step multiplies across every execution phase. The author of a plan is the worst-positioned party to red-team it. This skill is a context that has *not* seen the planning conversation: it verifies the plan's claims against the real codebase and reports where the plan is wrong, wasteful, or not actually executable.

## Relationship to the planner's `3b Pushback`

These are complementary, not redundant — each catches a failure class the other structurally cannot:

| | planner `3b Pushback` | review-plan |
|---|---|---|
| Target | the **ticket / requirements** (input) | the **finished plan** (output) |
| Timing | before the plan exists, during discovery | after the plan is drafted |
| Mode | interactive — grills you, folds answers into the plan | cold read — only the plan file + repo |
| Catches | bad premises, wrong/over-specified requirements | emergent redundancy, inefficiency, wrong assumptions, un-executable vagueness |

Keep both.

## What it does

1. **Cold-read gate** — refuses to run in a session that produced the plan (that's just self-review again).
2. **Grounds in reality** — reads `CONTEXT.md` and the files the plan names, building an independent picture of the code.
3. **Lens A — Correctness** — verifies every factual claim and assumption against the repo (`file:line` evidence required), re-checks blast radius for data-model changes, checks sequencing, and judges handoff-readiness by actually being the cold session.
4. **Lens B — Necessity / Efficiency** — hunts for steps made redundant by other steps, work the codebase already does, leaner paths, and over-phasing.
5. **Lens C — Intent backstop** — secondary net for bad premises that slipped past `3b` (raise only if material).
6. **Verdict** — `SHIP` / `REVISE` / `BLOCK`, severity-gated, with anti-theater guardrails (a clean pass is a valid result; no evidence → not a Major). **Findings-only — it never edits the plan.**

## Usage

```
/review-plan <path-to-plan-file>            # cold read of plan + repo
/review-plan <path-to-plan-file> <TICKET>   # + cross-check intent against the raw Jira ticket (optional)
```

Output is written to a **sibling review file** next to the plan: `{plan}-review.md`. The plan file is never modified.

- **SHIP** → execute as-is.
- **REVISE** → hand findings to a fresh planner session for one revision round, then execute.
- **BLOCK** → re-plan; don't patch around a wrong approach.

**Recommended model:** Sonnet 4.6 + thinking. The value is the cold context plus verification against the repo, not raw horsepower — so this costs well below a planning run.

## Install

No tooling — pure workflow document. Install `review-plan.md` into your platform's skill/command location (or invoke it directly as the `review-plan` skill).
