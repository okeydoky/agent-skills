---
description: Create a draft PR and optionally update the associated Jira ticket.
---

# Draft PR

## Prerequisites

- The current branch must have commits ready to be submitted as a pull request.
- The branch must be pushed to the remote. If not, offer to push it first.

---

## Step 1: Gather Context

### Step 1a: Git Context

Run these commands and analyze the output. Do not skip any.

1. Determine the base branch (usually `main` or `master`):
   - **bash/Git Bash**: `git remote show origin | grep "HEAD branch"` — gives the default branch
   - **PowerShell**: `git remote show origin | Select-String 'HEAD branch'`
   - If that fails, check for `main` then `master`: `git branch -r`

2. Get the current branch name:
   - `git rev-parse --abbrev-ref HEAD`

3. Get the full diff against the base branch:
   - `git diff <base>...HEAD`
   - If the diff is very large (many files, lock files, or generated assets), do NOT dump it in full. Instead, rely on the `--stat` output from step 4 to identify the meaningful files, then read only those with `git diff <base>...HEAD -- <file>`.

4. Get the list of changed files with stats:
   - `git diff --stat <base>...HEAD`

5. Get the commit messages on this branch:
   - `git log <base>..HEAD --oneline --no-merges`

If the diff is empty (branch is in sync with base), stop and tell the user — there is nothing to PR.

### Step 1b: Extract the Jira Ticket

Look for a Jira ticket key in this priority order. A Jira key matches the pattern `[A-Z]{2,}-\d+` (e.g. `PROJ-412`, `ABC-7`).

1. **User-provided** — if the user explicitly provides a ticket ID in their prompt, use that.
2. **Branch name** — match case-insensitively and normalize to uppercase. Try these patterns in order:
   - Underscore-delimited prefix: `<JIRA-ID>_<name>` (e.g., `OASIS-495_sync_upstart`)
   - Slash-delimited segment: `feature/<JIRA-ID>-...` (e.g., `feature/PROJ-412-add-oauth`)
   - General regex anywhere in branch name: `[A-Z]{2,}-\d+`
3. **Commit messages** — scan the `git log` output for a ticket key.
4. If no ticket is found anywhere, proceed WITHOUT a ticket. Do not invent one.

> The ticket detected here is shared with Step 2 for Jira integration — no re-detection needed there.

### Step 1c: Locate Plan Files

Search for plan files that correspond to this work. A plan file captures the original intent and implementation design — it is valuable context for drafting an accurate PR.

**Search order** (stop at the first match set; use all matches within a tier):

1. **User-provided** — if the user explicitly provides plan file paths, use those.
2. **Open editors** — check currently open editor tabs for any `.md` files whose name contains "plan" OR starts with the Jira ticket ID (e.g., `OASIS-495-*.md`).
3. **Plans directory** — search `~/.windsurf/plans/` (Windows: `$env:USERPROFILE\.windsurf\plans\`) for files matching `*plan*.md` OR `<JIRA-ID>-*.md`:
   - **bash**: `ls ~/.windsurf/plans/ 2>/dev/null | grep -iE "(plan|<JIRA-ID>-)" || true`
   - **PowerShell**:
     ```powershell
     powershell -Command {
       $plansDir = "$env:USERPROFILE\.windsurf\plans"
       $jiraId = '<JIRA-ID>'
       Get-ChildItem $plansDir -Filter '*.md' -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -like '*plan*' -or $_.Name -like "$jiraId-*" }
     }
     ```
4. **Workspace root** — search for files matching `*plan*.md` or `<JIRA-ID>-*.md` in the workspace root.

**If no plan files are found**, do NOT silently proceed — without plan context, PR body quality degrades sharply on lightweight models. Pause and tell the user no plan file was located, then offer both options in a single message:

1. **Provide an anchor** — the user gives 1–2 sentences of what/why, which you use to anchor the PR body alongside the diff.
2. **Continue diff-only** — proceed from the diff and commit messages alone. Recommend that the user re-run this workflow on a stronger model (Haiku or above) if they pick this and the work is non-trivial.

Either way, never invent a "why" that the diff and commit messages cannot support.

**If plan files are found**, you **MUST read every file in the list** before moving to Step 2. Do NOT stop after reading the first one. Process them one by one until all are read:

1. Build the full list of matching plan files from the search above.
2. For each file in the list (iterate through all of them — do not skip any):
   - Read the file in full.
   - Extract and accumulate the following into a combined plan summary:
     - **Goal / User's Intent** — what the work was supposed to achieve.
     - **Scope** — which parts of the system are affected.
     - **Phases completed** — which phases have been implemented (look for checked items or completion markers).
     - **Key design decisions** — non-obvious choices captured in the plan.
     - **Remaining work** — any phases or TODOs not yet done (flag these in the PR Notes section).
3. After reading all files, merge the extracted context into a single coherent plan summary. Where plans overlap on the same phase or topic, consolidate rather than duplicate. Where they cover different phases, combine them additively.

> **Checkpoint**: Before proceeding to Step 2, confirm in your reasoning that you have read N of N plan files found. If you have not finished reading all of them, continue reading before moving on.

---

## Step 2: Analyze and Draft PR Content

### Step 2a: Analyze the Changes

Combine insights from the **git diff** (Step 1a) and the **plan** (Step 1c, if available) to determine:

- **Type**: infer from the actual changes, NOT the branch name. Use one of:
  `feat` (new feature), `fix` (bug fix), `refactor` (no behavior change),
  `perf`, `docs`, `test`, `chore`, `build`, `ci`, `revert`.
- **Scope**: the primary module/area affected (e.g. `auth`, `api`, `ui`). Infer from file paths. Omit if changes are cross-cutting.
- **What actually changed** at a functional level — not a file-by-file readout. If a plan is available, cross-reference the diff against the plan's phases to confirm what was implemented.
- **Why** — the problem being solved. Prefer the plan's stated goal over guessing from commit messages. If neither source provides a clear "why," say so explicitly.
- **How** — only the non-obvious implementation decisions a reviewer should know. The plan's design decisions are a primary source here.
- **Remaining work** — if the plan shows phases or TODOs not reflected in the diff, note them.

### Step 2b: Generate the PR Title and Body

If the user provides a PR title or body, use their input. Otherwise, generate from the analysis above.

**Title format**: `[<JIRA-ID>] <type>(<scope>): <short description>`

- Omit `[<JIRA-ID>]` prefix if no ticket was found.
- Imperative mood, lowercase, no period. Keep under 72 characters (excluding the ticket prefix).

**Body format**:

```markdown
## What

{1-3 sentences on what changed at a functional level}

## Why

{the problem or requirement driving this change — use plan's goal if available}

## How

{key implementation decisions and non-obvious choices — bullets; draw from plan's design decisions if available}

## Testing

{how this was or should be verified — note if you cannot confirm tests were run}

## Notes

{breaking changes, follow-up TODOs, incomplete plan phases, migration steps, anything risky — omit section if none}

Closes {TICKET-KEY}
```

Skip any section that would be empty. Include `Closes {TICKET-KEY}` only if a Jira ticket was detected. If the plan reveals work that is NOT yet in the diff, call that out explicitly under **Notes** as "Remaining work".

### Step 2c: Create Draft Pull Request

- Use the `github-manager` skill to create a pull request with `"draft": true`.
- Use the title and body generated in Step 2b.
- Auto-detect `head` (current branch) and `base` (default branch) per the `github-manager` skill conventions.
- After creation, report the PR number and URL to the user.

---

## Step 3: Jira Ticket Integration (Conditional)

This step only runs if a Jira ticket ID was detected in **Step 1b**. If no ticket was found, skip this step entirely and end the workflow.

### Step 3a: Transition Jira Ticket to "In Review"

- Use the `jira-manager` skill to transition the ticket status to `In Review`.
- First, fetch available transitions for the ticket:
  - **Endpoint**: `GET /rest/api/2/issue/<JIRA-ID>/transitions`
- Find the transition whose `name` matches `In Review` (case-insensitive).
- Execute the transition:
  - **Endpoint**: `POST /rest/api/2/issue/<JIRA-ID>/transitions`
  - **Body**: `{"transition":{"id":"<transition_id>"}}`
- If the transition is not available (e.g., the ticket is already in that status or the transition doesn't exist), inform the user and continue. Do NOT stop the workflow.

### Step 3b: Attach Plan Files to Jira Ticket (Conditional)

This sub-step only runs if plan files were found in **Step 1c**.

For each plan file found, upload it as an attachment to the Jira ticket:

- **Endpoint**: `POST /rest/api/2/issue/<JIRA-ID>/attachments`
- **Header**: `X-Atlassian-Token: no-check` (required for attachment uploads)
- Use `multipart/form-data` with the file field named `file`.
- **bash**:
  ```bash
  JIRA_TOKEN=$(grep 'JIRA_TOKEN' ~/.levelup | cut -d= -f2)
  JIRA_URL=$(grep 'JIRA_URL' ~/.levelup | cut -d= -f2)
  curl -s -X POST \
    -H "Authorization: Bearer $JIRA_TOKEN" \
    -H "X-Atlassian-Token: no-check" \
    -F "file=@<FILE_PATH>" \
    "$JIRA_URL/rest/api/2/issue/<JIRA-ID>/attachments"
  ```
- **PowerShell** (compatible with PS5+; `-Form` requires PS7 and must NOT be used):
  ```powershell
  powershell -Command {
    $cfg = Get-Content "$env:USERPROFILE\.levelup" | ConvertFrom-StringData
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add('Authorization', "Bearer $($cfg.JIRA_TOKEN)")
    $wc.Headers.Add('X-Atlassian-Token', 'no-check')
    $response = $wc.UploadFile("$($cfg.JIRA_URL)/rest/api/2/issue/<JIRA-ID>/attachments", '<FILE_PATH>')
    [System.Text.Encoding]::UTF8.GetString($response)
  }
  ```

Report the result of each upload to the user.

---

## Rules

- Never fabricate a Jira ticket, test results, or a "why" you cannot determine from the diff or plan.
- Never force-push or modify commit history.
- Keep the PR title under 72 characters where possible (excluding the ticket prefix).
- Infer type and scope from the diff — never from the branch name alone.
- Plan content is supplementary context — it does not override what the diff actually shows.
- At any point, if you need clarification or are uncertain, stop and ask the user. Do NOT assume.
- Each step should proceed even if a subsequent optional step fails — only the PR creation (Step 2c) is mandatory.
