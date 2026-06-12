---
name: jira-manager
description: Manage iTrack (Jira Data Center) work items. Supports creating new items (Epics, Stories, Bugs) and updating existing ones (status, points, sprints, comments).
---

# Jira Manager

This skill provides streamlined procedures for managing work items on **iTrack (Jira Data Center)**.

## 1. Setup & Initialization

Before any Jira operation, ensure your environment is ready.

### Shell Detection (Run First)

Detect which shell is active so the correct commands are used throughout this skill:

- **PowerShell**: `$PSVersionTable.PSVersion` returns a value.
- **bash/zsh (macOS/Linux)**: `echo $BASH_VERSION` or `echo $ZSH_VERSION` returns a value.

Store the result and use the appropriate command variant for each step below.

### A. Credentials File (`~/.levelup`)

The file lives at `~/.levelup` on all platforms — `~` resolves correctly in both bash and PowerShell.

1. **Check existence**:
   - **bash/zsh**: `test -f ~/.levelup && echo exists || echo missing`
   - **PowerShell**: `if (Test-Path ~\.levelup) { 'exists' } else { 'missing' }`
2. **If missing or empty**, follow these steps to guide the user through setup:
   - **Step 1 — Ask the user** for the following two values (show the examples below):
     - `JIRA_URL` — e.g., `https://your-jira-instance.com`
     - `JIRA_USER_EMAIL` — e.g., `your.email@company.com`
   - **Step 2 — Create the file** at `~/.levelup` and pre-fill it with the values the user provided, leaving `JIRA_TOKEN` empty:
     - **bash/zsh**:
       ```bash
       cat > ~/.levelup << 'EOF'
       JIRA_URL=<value from user>
       JIRA_USER_EMAIL=<value from user>
       JIRA_TOKEN=
       EOF
       ```
     - **PowerShell**:
       ```powershell
       @"
       JIRA_URL=<value from user>
       JIRA_USER_EMAIL=<value from user>
       JIRA_TOKEN=
       "@ | Set-Content ~\.levelup
       ```
   - **Step 3 — Open the file** for the user so they can paste their token:
     - macOS: `open ~/.levelup`
     - Windows (PowerShell): `notepad $env:USERPROFILE\.levelup`
   - **Step 4 — Instruct the user** to:
     - Generate a Personal Access Token at: User Profile → Personal Access Tokens (or `${JIRA_URL}/secure/ViewProfile.jspa`).
     - Paste the token into the `JIRA_TOKEN=` field in the opened file and save.
   - **Step 5 — Wait** for the user to confirm they have saved the token before proceeding.
   - **SECURITY RULE**:
     - NEVER ask the user to provide the token in the chat.
     - The token must only be entered directly in the `~/.levelup` file.
     - Since `~/.levelup` lives outside any repository, it does **not** need to be added to `.gitignore`.
3. **File location**: Always use `~/.levelup` — never place credentials inside the repository.

### B. Configuration Assets (Auto-Initialize)

The skill uses `config/field-mappings.json` and `config/schema-guide.md` to ensure payload accuracy.

1. **Verify Assets**: Check if these files exist and are NOT empty.
2. **Auto-Initialize**: If any are missing or empty, you MUST re-create them with the following defaults:
   - **field-mappings.json**: Include `COMMON_ITRACK` (Acceptance Criteria: `customfield_10777`, Epic Link: `customfield_10970`, etc.).
   - **schema-guide.md**: Include basic Jira markup rules (`*bold*`, `{code}`) and data types.

## 2. Requirement Discovery (Look-Before-You-Leap)

To avoid "400 Bad Request", always verify field IDs for the target project if they aren't in `field-mappings.json`.

### Running API Calls

Use the appropriate method for the active shell:

**bash/zsh** — use the helper script:

```bash
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
bash "$SKILL_DIR/scripts/jira.sh" "<ENDPOINT>" '<BODY>' <METHOD>
```

**PowerShell** — use this reusable snippet (substitute `<ENDPOINT>`, `<BODY>`, `<METHOD>`):

```powershell
$SKILL_DIR = Split-Path -Parent $PSCommandPath
$cfg  = Get-Content ~\.levelup | ConvertFrom-StringData
$hdrs = @{ Authorization = "Bearer $($cfg.JIRA_TOKEN)"; 'Content-Type' = 'application/json' }
Invoke-RestMethod `
  -Uri    "$($cfg.JIRA_URL)<ENDPOINT>" `
  -Headers $hdrs `
  -Method  <METHOD> `
  -Body    '<BODY>' | ConvertTo-Json -Depth 10
```

For GET requests omit `-Body`. For DELETE requests omit `-Body` and use `-Method DELETE`.

1. **Find a Reference**: Search for an existing issue of the same type.
   - bash/zsh: `bash "$SKILL_DIR/scripts/jira.sh" "/rest/api/2/search?jql=project=KEY AND issuetype='Story'&maxResults=1"`
   - PowerShell: use the snippet above with `ENDPOINT=/rest/api/2/search?jql=project=KEY AND issuetype='Story'&maxResults=1` and `METHOD=GET`
2. **Inspect Fields**: Extract exact field IDs and data formats.
   - bash/zsh: `bash "$SKILL_DIR/scripts/inspect-fields.sh" issue KEY`
   - PowerShell: use the snippet above with `ENDPOINT=/rest/api/2/issue/KEY?expand=editmeta` and `METHOD=GET`
3. **Update Cache**: Immediately save discovered mappings to `config/field-mappings.json`.

### MANDATORY: Auto-Update Rules for `field-mappings.json`

- **NEVER ask the user** whether to update the mappings file. Always update it silently.
- **New project detection**: Before the first operation on any project, check if the project key exists under `PROJECT_MAPPINGS` in `config/field-mappings.json`.
  - If it does **not** exist, **proactively** run `inspect-fields.sh` to discover the project's field IDs and save them under `PROJECT_MAPPINGS.<PROJECT_KEY>` before executing the operation.
  - This prevents the first operation from failing due to incorrect field IDs.
- When a field ID is discovered during any operation (create, update, inspect), **immediately write it** to `config/field-mappings.json`.
- When a request fails due to an incorrect field ID, **automatically**:
  1. Run `inspect-fields.sh` to discover the correct field ID.
  2. Update `config/field-mappings.json` with the correct value.
  3. Retry the original operation.
  4. Do NOT ask the user for confirmation at any point in this process.
- When a project-specific mapping differs from `COMMON_ITRACK`, add it under `PROJECT_MAPPINGS` with the project key.
- Always prefer `PROJECT_MAPPINGS.<PROJECT_KEY>.<field>` over `COMMON_ITRACK.<field>` when both exist.

## 3. Operations

For every command below, a **bash/zsh** form and a **PowerShell** form are provided. Use the one that matches the active shell detected in step 1.

### A. Create Issue (Creator)

- **Schemas**: Refer to `references/creator-payloads.md`.
- bash/zsh: `bash "$SKILL_DIR/scripts/jira.sh" /rest/api/2/issue '{"fields":{...}}' POST`
- PowerShell: use the snippet from §2 with `ENDPOINT=/rest/api/2/issue`, `METHOD=POST`, and the JSON payload as `BODY`.

### B. Update Issue (Updater)

- **Schemas**: Refer to `references/updater-payloads.md`.
- bash/zsh: `bash "$SKILL_DIR/scripts/jira.sh" /rest/api/2/issue/KEY '{"fields":{...}}' PUT`
- PowerShell: use the snippet from §2 with `ENDPOINT=/rest/api/2/issue/KEY`, `METHOD=PUT`, and the JSON payload as `BODY`.
- **Sprint**: To update a sprint, first find the board (`/rest/agile/1.0/board?projectKeyOrId=KEY`) then list active sprints.

### C. Delete Issue (Deleter)

- **Safety First**: Issue deletion is IRREVERSIBLE.

1. **Check Subtasks**:
   - bash/zsh: `bash "$SKILL_DIR/scripts/jira.sh" /rest/api/2/issue/KEY?fields=subtasks`
   - PowerShell: snippet from §2 with `ENDPOINT=/rest/api/2/issue/KEY?fields=subtasks`, `METHOD=GET`.
2. **Confirmation**: Present the issue summary and subtask count. **Wait for explicit confirmation**.
3. **Execution**:
   - bash/zsh: `bash "$SKILL_DIR/scripts/jira.sh" "/rest/api/2/issue/KEY?deleteSubtasks=true" "" DELETE`
   - PowerShell: snippet from §2 with `ENDPOINT=/rest/api/2/issue/KEY?deleteSubtasks=true`, `METHOD=DELETE`, no `BODY`.

### D. Comments & Metadata

- **Add Comment**:
  - bash/zsh: `bash "$SKILL_DIR/scripts/jira.sh" /rest/api/2/issue/KEY/comment '{"body":"Text"}' POST`
  - PowerShell: snippet from §2 with `ENDPOINT=/rest/api/2/issue/KEY/comment`, `METHOD=POST`, `BODY={"body":"Text"}`.
- **Permissions**:
  - bash/zsh: `bash "$SKILL_DIR/scripts/jira.sh" /rest/api/2/mypermissions?projectKey=KEY`
  - PowerShell: snippet from §2 with `ENDPOINT=/rest/api/2/mypermissions?projectKey=KEY`, `METHOD=GET`.

## Core Tips

- **iTrack Custom Fields**: Acceptance Criteria (`customfield_10777`), Epic Link (`customfield_10970`), Story Points (`customfield_10693`).
- **SQLFeed/Prisma**: Fields like `customfield_1700x` often take simple strings even if the UI looks like a list.
