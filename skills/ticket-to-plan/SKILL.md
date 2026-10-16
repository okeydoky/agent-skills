---
name: ticket-to-plan
description: Retrieve a Jira ticket, set up a development branch, and draft an implementation plan.
---

# Ticket to Plan

## Step 0: Verify Prerequisites (HARD GATE)

> **⛔ DO NOT PROCEED past this step until both checks pass.**

### 0a. Confirm Ticket ID

- A Jira ticket ID (e.g., `OASIS-495`) **must** be present in the user's prompt.
- If no ticket ID was provided: **ABORT this workflow entirely.** Tell the user: _"Please re-run `/ticket-to-plan` with a Jira ticket ID (e.g., `OASIS-495`)."_ Do NOT continue under any circumstances.

---

## Step 1: Retrieve Jira Ticket & Related Context

### 1a. Fetch the Primary Ticket

- Use the `jira-manager` skill to retrieve the Jira ticket for the provided ticket ID.
- Request the following fields at minimum: `summary, description, issuetype, status, parent, subtasks, issuelinks, customfield_10777` (Acceptance Criteria).
- If the retrieval fails, verify that you are invoking the `jira-manager` skill correctly and retry.
- Read and understand the ticket summary, description, acceptance criteria, and issue type.

### 1b. Fetch Related Issues for Broader Context

After retrieving the primary ticket, inspect it for related issues and fetch each one:

1. **Parent issue** — If the ticket has a `parent` field (i.e., it is a sub-task), retrieve the parent issue to understand the broader objective this sub-task contributes to.
2. **Sub-tasks** — If the ticket has a `subtasks` array, retrieve each sub-task to understand sibling work items, their statuses, and how the current ticket fits into the whole.
3. **Linked issues** — If the ticket has an `issuelinks` array (e.g., "is blocked by", "relates to", "is part of"), retrieve each linked issue to capture dependencies, related requirements, or prior decisions.

For every related issue fetched, record:

- **Key**, **summary**, **status**, and **issue type**.
- The **relationship** to the primary ticket (e.g., "parent of", "blocked by", "relates to").
- Any relevant **acceptance criteria** or **description details** that add context.

### 1c. Synthesize Context

Before proceeding to Step 2, compile a concise context summary that includes:

- The primary ticket's full details.
- How it relates to its parent (if any) and what the parent's overall goal is.
- The status and scope of sibling sub-tasks (if any) — which are done, in-progress, or pending.
- Any dependencies or related context from linked issues.

This synthesized context will be passed to the `planner` skill in Step 3.

## Step 2: Set Up Development Branch

- Determine the branch name using the convention: `{jira_ticket_id}_{short_concise_descriptive_name}`
  - The descriptive name should be a short, lowercase, underscore-separated summary derived from the ticket (e.g., `OASIS-495_sync_upstart`).
- **Check the current branch first.** If you are already on a branch that matches the ticket ID prefix (e.g., `OASIS-495_*`), **skip branch creation** and proceed to Step 3.
- If a new branch is needed:
  1. Determine the base branch:
     - If the user provided a `clone_from` branch in their prompt, use that.
     - Otherwise, detect the default branch (`master` or `main`) and use it.
  2. Fetch the latest from the remote for the base branch.
  3. Create and check out the new branch from the base branch.

### 2a. Update Ticket Status to In Development

- Use the `jira-manager` skill to list the ticket's available transitions (`GET /rest/api/2/issue/KEY/transitions`) and transition it to **In Development**, or to **In Progress** if the project's workflow has no "In Development" (e.g. FTDS).
- If the transition fails, report the error to the user and continue.

## Step 3: Draft Implementation Plan

> **Use the `planner` skill for planning. Do not substitute an independent planning procedure.**

- Load and follow `planner` using the host's skill mechanism, or read its instructions directly if no dedicated skill tool exists.
- Pass the **synthesized context from Step 1c** as the task description.
- Let the planner skill handle all subsequent steps — do NOT pre-empt it by writing plan content in chat or in files yourself.
- Let planner choose lightweight or full-handoff depth based on risk. It asks only for consequential unresolved decisions; do not force an interview when the code and ticket already settle the requirements.

## Step 4: Plan Quality Gate

After the planner skill completes, verify the generated plan meets the **handoff readiness** bar:

> **Litmus test:** Could a brand-new agent session start safely from the plan's intent, named files, dependencies, assumptions, and completion checks without guessing product requirements?

If the plan lacks specific targets, consequential decision rationale, or observable phase results with exact checks — **send it back to the planner for revision** before confirming with the user. Targeted code verification is expected, not a plan defect. Do not reject a lightweight plan for omitting an empty Q&A log or multi-phase complexity summary. Do not hand off a `Draft` or `Blocked` plan as ready to execute.

## Step 5: Hand Off

- Report the plan path, mode, readiness, first phase, required batches, and any deferred checks. Suggest a fresh session when context isolation helps; do not claim guaranteed cost savings or require per-phase model recommendations. Do not execute unless the user asks.
- For example:

  > Plan ready (lightweight). To execute, run `/execute-plan ~/.windsurf/plans/OASIS-495-sync-upstart.md Phase 1`. The plan records its required validation checks.

---

## Important

- Ask for consequential unresolved decisions; investigate factual uncertainty before asking. Do not invent requirements or user approval.
- Follow the host's applicable workspace instructions and conventions, not only `.windsurf/rules/`.
