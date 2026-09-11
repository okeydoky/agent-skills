---
name: draft-jira
description: Turn a rough idea into a sprint/planning-ready Jira ticket. Interviews the user, grounds scope in the codebase, then creates a new ticket or enriches an existing one via jira-manager.
---

# Draft Jira

Produces a Jira ticket good enough that `ticket-to-plan` can turn it into an implementation plan **without another round of clarifying questions**. Everything below is in service of that bar — treat "would `ticket-to-plan`'s planner have to ask this?" as the test for what belongs in the ticket.

## Step 0: Identify the Target (HARD GATE)

> **⛔ DO NOT PROCEED past this step until a project ID or ticket ID is confirmed.**

- **Project ID** (e.g., `OASIS`) → this workflow will **create** a new ticket.
- **Ticket ID** (e.g., `OASIS-559`) → this workflow will **update/enrich** the existing ticket.
- If the user's prompt contains neither, **stop and ask**: "Which project should this ticket be created in (e.g., `OASIS`), or is there an existing ticket ID to update (e.g., `OASIS-559`)?" Do not guess a project key from repo names or prior conversation.
- If both are given, the ticket ID wins (update flow) — but verify the ticket actually belongs to the given project once fetched in Step 2; flag a mismatch to the user instead of silently proceeding.

## Step 1: Capture the Raw Ask

Record, verbatim or close to it, what the user said this ticket is about. This is the seed for everything else — do not lose nuance by paraphrasing too early.

## Step 2: Existing Ticket Context (Conditional — update flow only)

If a ticket ID was provided:

- Use the `jira-manager` skill to fetch the ticket: `summary, description, issuetype, status, parent, subtasks, issuelinks, customfield_10777` (Acceptance Criteria), plus any project-specific fields already in `jira-manager`'s field mappings.
- Treat existing content as authoritative unless the user's new ask explicitly contradicts it. Your job is to **enrich** (fill gaps, sharpen AC, add technical context) — not to blow away what's already there.
- Note the current `issuetype` and `status`; don't change either unless the user asks or the scope has clearly grown (e.g., a Bug that turned out to need a Story).

## Step 3: Codebase Discovery (Mandatory)

Before drafting anything, ground the ticket in reality:

- Search the codebase for the files, modules, and existing patterns most relevant to the ask.
- Identify the likely blast radius: what would change, what consumes it, what's adjacent but probably out of scope.
- Look for prior art: similar past tickets referenced in commit messages/`git log`, related open tickets, or existing abstractions that should be reused rather than reinvented.
- Note anything that looks like a hidden dependency (e.g., "this needs a migration first", "this touches a shared library used by X").

Use this pass to inform Step 4's questions and Step 5's draft — do not present raw findings to the user, translate them into specific questions and ticket content.

## Step 4: Scoping Interview (Mandatory)

Even for a "simple" ask, ask targeted questions before drafting. Skip a category only if Steps 1–3 already answered it unambiguously.

| Category                  | What to probe                                                                                                                |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Issue type & sizing**   | Story, Bug, Task, or Epic? Does this fit in one sprint, or does it need to be split into an Epic + sub-tasks/stories?        |
| **Scope boundaries**      | What's explicitly out of scope? What adjacent code should NOT be touched?                                                    |
| **Acceptance criteria**   | What are the concrete, verifiable conditions for "done"? For a bug: what's the expected vs. actual behavior?                 |
| **Dependencies & links**  | Does this depend on or block other tickets? Is there a parent Epic? Anything discovered in Step 3 that should be linked?     |
| **Technical constraints** | Any known approach constraints, non-functional requirements (perf, backward compat), or feature-flag/rollout considerations? |

Rules for the questions:

- Attach a **recommended answer** to each question, based on Step 3's findings, so the user can reply "all recommended except #2."
- Keep it to **3–6 questions** — this is a lighter interview than `planner`'s (that one runs later, against a confirmed ticket, with far more room to dig).
- **STOP and wait** for the user's answers before drafting.

## Step 5: Draft Ticket Content

Compose the following, optimized for a fresh `ticket-to-plan` session with zero conversational context:

### Summary

Concise, action-oriented, imperative mood (e.g., "Add retry logic to upstart sync job"). No ticket ID or type prefix — Jira/the project convention handles that.

### Description

Structured with these sections (omit a section only if genuinely empty):

```markdown
h3. Background
{Why this work exists — the problem or opportunity, 2-4 sentences.}

h3. Goal
{What "done" looks like from a user/system-behavior perspective, not an implementation prescription.}

h3. Technical Notes
{Files/modules/patterns found in Step 3 that ground the scope — e.g., "Touches libs/sync/upstart-client.ts; follows the retry pattern already used in libs/sync/downstart-client.ts."}

h3. Out of Scope
{Explicit exclusions surfaced in Step 4 — bullet list.}
```

Use Jira wiki markup (`h3.`, `*bold*`, bullet `*`) per `references/schema-guide.md` in `jira-manager`, not raw Markdown headers, since this goes through the Jira API as plain text/wiki markup.

### Acceptance Criteria (`customfield_10777`)

A bullet list of specific, independently verifiable conditions — not a restatement of the goal. Each bullet should be checkable by someone with no other context. This field is what `ticket-to-plan` reads first for scope — invest the most care here.

### Issue Type, Links, Parent

- Set `issuetype` per Step 4's answer.
- If a parent Epic was identified or confirmed, set the Epic Link field.
- If related tickets were confirmed in Step 4, prepare `issuelinks` entries (e.g., "relates to", "is blocked by").

## Step 6: Present Draft for Confirmation

Show the full draft (summary, description, acceptance criteria, issue type, links) to the user in chat before writing anything to Jira. Explicitly ask for confirmation or edits.

> **Do not skip this.** A bad ticket is more expensive to fix after `ticket-to-plan` has already built a plan on top of it than it is to catch here.

## Step 7: Create or Update via `jira-manager`

- **Create flow** (project ID only): use the `jira-manager` skill to create the issue with the fields drafted in Step 5. Refer to its `references/creator-payloads.md` for payload shape.
- **Update flow** (ticket ID given): use the `jira-manager` skill to update the issue, merging drafted content with what was fetched in Step 2 (don't overwrite fields the user didn't ask to change). Refer to its `references/updater-payloads.md`.
- Report the resulting ticket key and, if available, its URL.

## Step 8: Optional Planning-Readiness Touches

Ask the user (do not assume) whether to also:

- Move the ticket to a "ready for planning/grooming" status or backlog column, if such a transition exists for the project.
- Set story points, sprint, or labels.

If the user declines or these aren't applicable, skip silently — this step is optional polish, not a gate.

## Step 9: Hand Off

Close by pointing the user at the ticket and the natural next step:

> Ticket `OASIS-559` created/updated: {URL}. Ready to run `ticket-to-plan` on it whenever you'd like to turn this into an implementation plan.

---

## Ticket Quality Bar (Self-Check Before Step 6)

Before presenting the draft, verify:

- [ ] Acceptance criteria are specific and independently verifiable — not a paraphrase of the goal.
- [ ] Description gives a fresh reader (no chat context) enough "why" and "what" to understand the ticket alone.
- [ ] Scope boundaries are explicit, not implied.
- [ ] Technical Notes ground the ticket in real files/modules found in Step 3, not generic advice.
- [ ] Issue type matches the actual size/shape of the work (a multi-week effort should be an Epic with sub-tasks, not one Story).

If any box is unchecked, revise before showing the draft to the user.

---

## Rules

- Never fabricate acceptance criteria, file paths, or related tickets — only include what Steps 2–4 actually surfaced or the user confirmed.
- Never silently overwrite existing ticket content in the update flow.
- At any point, if uncertain, stop and ask — do not guess project keys, issue types, or scope.
