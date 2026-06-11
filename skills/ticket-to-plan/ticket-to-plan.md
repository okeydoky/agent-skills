---
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

> **Note:** Do NOT transition the ticket's status yet — discovery may still reshape or invalidate the work. The transition to **In Development** happens in Step 5, after the plan is confirmed.

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

## Step 3: Draft Implementation Plan

> **⚠️ You MUST delegate planning to the `planner` skill via the `skill` tool. DO NOT draft a plan, write todo items, or list implementation steps yourself.**

- Call the `skill` tool with `SkillName: "planner"`.
- Pass the **synthesized context from Step 1c** as the task description.
- Let the planner skill handle all subsequent steps — do NOT pre-empt it by writing plan content in chat or in files yourself.
- The planner skill will conduct a **Discovery Interview** with the user to surface hidden requirements. This is expected and necessary — do not skip or rush through it.

## Step 4: Plan Quality Gate

After the planner skill completes, verify the generated plan meets the **handoff readiness** bar:

> **Litmus test:** Could a brand-new agent session (without this conversation's context) pick up the plan file and execute it without needing to ask clarifying questions?

If the plan references vague terms ("the relevant service", "update as needed"), contains steps that require re-discovery of context, or lacks rationale for key decisions — **send it back to the planner for revision** before confirming with the user.

## Step 5: Transition Ticket & Hand Off

Only run this step **after the user has confirmed the plan** (the planner skill's final confirmation).

### 5a. Update Ticket Status to In Development

- Use the `jira-manager` skill to transition the primary ticket's status to **In Development**.
- If the transition fails, report the error to the user and continue.

### 5b. Hand Off for Execution

- The **default execution mode is a fresh session per phase (or phase batch)**, using the model recommended in the plan's Phase Complexity Summary. A new session costs nothing extra under per-prompt pricing, sheds planning context the executor doesn't need, and lets the user drop to the cheaper recommended model. Executing in this session is the exception, only when the user explicitly asks.
- Close by telling the user the plan file path, the first phase's recommended model, and any batching hint, e.g.:

  > Plan confirmed and ticket transitioned. To execute: start a new session with **Sonnet 4.6** and run `/execute-plan ~/.windsurf/plans/OASIS-495-sync-upstart.md Phase 1` (Phases 1–2 can be batched).

---

## Important

- At **any point**, if you need clarification or are uncertain, **stop and ask the user**. Do NOT assume.
- Follow all workspace rules and conventions defined in `.windsurf/rules/`.
