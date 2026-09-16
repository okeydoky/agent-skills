---
name: plan-review-loop
description: Chains ticket-to-plan with a bounded cold-read review/revise cycle — review-plan runs in a fresh sub-agent each round, findings are patched into the plan, and the loop repeats until the review reaches SHIP or 5 iterations are exhausted.
---

# Plan Review Loop

`ticket-to-plan` produces a first-draft plan; `review-plan` grades one. Neither alone guarantees the plan that reaches execution is actually clean. This skill closes that gap: generate the plan, then run a bounded review → revise cycle, so what gets handed to `/execute-plan` has already survived repeated adversarial cold reads.

```
/plan-review-loop <TICKET>          # e.g. /plan-review-loop OASIS-561
```

---

## Step 0: Verify Prerequisites (HARD GATE)

- A Jira ticket ID must be present in the user's prompt. If missing, abort exactly as `ticket-to-plan` does — do not guess a ticket.
- `max_iterations = 5` (hard cap). This is a safety valve against infinite loops, not a target to reach — most plans should `SHIP` well before iteration 5.

---

## Step 1: Generate the Initial Plan

- Delegate to the `ticket-to-plan` skill with the ticket ID. Let it run its full procedure: fetch the ticket + related issues, set up the branch, transition the ticket, and delegate to `planner` for the discovery interview and first draft.
- Capture the resulting **plan file path** (e.g. `~/.windsurf/plans/OASIS-561-{slug}.md`) — every later step operates on this path.
- `ticket-to-plan`'s own Step 4 "Plan Quality Gate" is a sanity check, not a substitute for the cold review below. Proceed to Step 2 regardless of whether it passed.

---

## Step 2: Iterative Cold-Read Review Loop

Initialize `iteration = 1`.

### 2a. Fresh Cold-Read Review (must run with no planning context)

> **Never run `review-plan` in this session.** This session just wrote or revised the plan, so it has planning context — using it to review would rubber-stamp its own assumptions, exactly the failure `review-plan`'s Cold-Read Invariant exists to prevent.

- Invoke a **new sub-agent** (via the sub-agent/task tool) for the review. A fresh sub-agent invocation is stateless by construction, which satisfies the cold-read requirement automatically.
- Give the sub-agent a self-contained prompt that:
  1. Points it at the `review-plan` skill's instructions and tells it to follow them in full (Step 0 through Step 5).
  2. Passes the plan file path and the ticket ID (so it can use the ticket as the intent backstop in Lens C).
  3. Overrides `review-plan`'s default sibling-filename rule: instead of `{plan-filename-without-ext}-review.md`, it must write to **`{plan-filename-without-ext}-review-{iteration}.md`**. This is required so each loop iteration keeps its own historical review file instead of clobbering the previous one — the sequence of files is the audit trail proving the loop actually converged rather than being rubber-stamped.
  4. Tells it to read the plan **and** any prior `-review-{n}.md` files it can find for this plan, so it doesn't re-flag findings already fixed in a previous round.
  5. Asks it to report back, as its final message, the review file path and the verdict (`SHIP` / `REVISE` / `BLOCK`).
- Do not proceed until the sub-agent returns its final message.

### 2b. Read the Verdict

- Read the review file the sub-agent just wrote (do not just trust its chat summary — confirm against the file).
- Extract the verdict and the list of Blocker/Major findings.

### 2c. Stop condition — SHIP

- If verdict is `SHIP`: exit the loop. Go to Step 3.

### 2d. Stop condition — iteration cap

- If `iteration == max_iterations` and verdict is not `SHIP`: exit the loop. Go to Step 4.

### 2e. Address Findings and Loop

- Read the Findings section of the review file in full.
- Revise the plan file **in this session** (it already holds full ticket + planning context, so no sub-agent is needed here — only the review step must be cold):
  - **BLOCK** — treat this as license to change the plan's fundamental approach, not just patch around it, per `review-plan`'s own guidance. Re-derive the affected phases rather than layering fixes on a wrong premise.
  - **REVISE** — patch each Blocker/Major finding in place: fix the wrong assumption, add the missed consumer, cut the redundant step, resolve the vague reference, etc.
  - **Minor** findings are optional — absorb them if cheap; otherwise leave them for the implementer.
- Do not silently drop a finding. Either fix it in the plan, or add a short inline note explaining why it's deliberately not addressed (e.g. genuinely out of scope).
- Increment `iteration` and go back to 2a.

---

## Step 3: Success Hand-off (SHIP reached)

Report to the user:

- The ticket ID and final plan file path.
- The iteration number the `SHIP` verdict landed on, and the path to that iteration's review file.
- The standard fresh-session execution hand-off, same as `ticket-to-plan` Step 5: recommended model and phase-batching hint, e.g.:

  > Plan reviewed and shipped after 2 iterations (`OASIS-561-{slug}-review-2.md`). To execute: start a new session with **Sonnet 4.6** and run `/execute-plan ~/.windsurf/plans/OASIS-561-{slug}.md Phase 1`.

---

## Step 4: Exhausted Hand-off (cap reached, no SHIP)

- Do **not** keep looping past `max_iterations`.
- Tell the user plainly: the plan went through 5 revision rounds and the review still returned `{verdict}`.
- Surface the remaining Blocker/Major findings from the latest review file verbatim.
- Recommend one of: manually inspecting the plan, relaxing scope and re-running, or taking over planning by hand — do not silently execute an unshipped plan.

---

## Important

- Every iteration produces its own `-review-{n}.md` file — never overwrite a prior iteration's review.
- The review step must always run in a fresh sub-agent, never in this session — that is the entire point of the loop.
- If `ticket-to-plan` aborts in Step 1 (missing ticket, Jira fetch failure), stop immediately — do not start a review loop against a plan that doesn't exist.
- At any point, if you're uncertain how to interpret a finding, stop and ask the user rather than guessing.
