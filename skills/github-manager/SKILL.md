---
name: github-manager
description: Manage GitHub Pull Requests. Supports creating, listing, updating, commenting, requesting reviewers, and merging PRs. Auto-detects repo and default branch from git context.
---

# GitHub Manager

This skill provides streamlined procedures for managing **Pull Requests** on GitHub via the REST API.

## 1. Setup & Initialization

Before any GitHub operation, ensure your environment is ready.

### Shell Default

> **Default to bash for all commands in this skill.** Use PowerShell variants only when bash is explicitly unavailable (e.g., the user confirms no Git Bash / WSL is installed).

To confirm bash is available on Windows:

```
bash --version
```

If it prints a version, use bash for all commands below. If not, fall back to PowerShell.

### A. Credentials File (`~/.levelup`)

The file lives at `~/.levelup` (bash) or `$env:USERPROFILE\.levelup` (PowerShell).

> **PowerShell path rule**: Never use `~` to reference this file in PowerShell — `~` resolution is unreliable across shell runner contexts and will cause false "file not found" errors. Always use `$env:USERPROFILE\.levelup` explicitly.

1. **Check existence**:
   - **bash**: `test -f ~/.levelup && echo exists || echo missing`
   - **PowerShell**: `Test-Path $env:USERPROFILE\.levelup`
     > Returns `True` (exists) or `False` (missing). Do NOT use an `if/else` one-liner — it will be truncated by the shell runner.
2. **If missing or empty**, follow these steps to guide the user through setup:
   - **Step 1 — Ask the user** for confirmation that they have a GitHub PAT. If not, direct them to:
     - **GitHub → Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens**
     - Required permissions: `Pull requests` (Read & Write), `Contents` (Read), `Metadata` (Read)
   - **Step 2 — Create or append** to `~/.levelup` with the GitHub key, leaving `GH_TOKEN` empty:
     - **bash/zsh**:
       ```bash
       echo 'GH_TOKEN=' >> ~/.levelup
       ```
     - **PowerShell**:
       ```powershell
       Add-Content $env:USERPROFILE\.levelup "GH_TOKEN="
       ```
   - **Step 3 — Open the file** for the user so they can paste their token:
     - macOS/bash: `open ~/.levelup`
     - Windows (PowerShell): `notepad $env:USERPROFILE\.levelup`
   - **Step 4 — Instruct the user** to:
     - Paste the token into the `GH_TOKEN=` field in the opened file and save.
   - **Step 5 — Wait** for the user to confirm they have saved the token before proceeding.
   - **SECURITY RULE**:
     - NEVER ask the user to provide the token in the chat.
     - The token must only be entered directly in the `~/.levelup` file.
3. **Check if `GH_TOKEN` is present and non-empty** (run after confirming the file exists):
   - **bash**: `grep -q 'GH_TOKEN=.' ~/.levelup && echo present || echo missing`
   - **PowerShell** — always use the `powershell -Command { ... }` block form; semicolons in one-liners are truncated by the shell runner:
     ```powershell
     powershell -Command { $cfg = Get-Content "$env:USERPROFILE\.levelup" | ConvertFrom-StringData; if ($cfg.GH_TOKEN) { "token present, length=$($cfg.GH_TOKEN.Length)" } else { 'token missing or empty' } }
     ```
4. **If `GH_TOKEN` is missing or empty**:
   - Append `GH_TOKEN=` to the file and follow steps 3–5 above.
5. **File location**: Always use `~/.levelup` — never place credentials inside the repository.

> **PowerShell shell runner rules**:
>
> 1. Always use `$env:USERPROFILE\.levelup` — never `~\.levelup`.
> 2. Any multi-statement command (`;`) MUST be wrapped in `powershell -Command { ... }`. Plain semicolon-separated one-liners are silently truncated.

### B. Repository Context (Auto-Detect)

Before every operation, auto-detect the current repository context. These values are derived at runtime and never hardcoded.

1. **Owner and Repo Name** — parse from the git remote:
   - **bash/zsh**:
     ```bash
     GH_REMOTE=$(git remote get-url origin 2>/dev/null)
     GH_OWNER=$(echo "$GH_REMOTE" | sed -E 's#.+[:/]([^/]+)/([^/.]+)(\.git)?$#\1#')
     GH_REPO=$(echo "$GH_REMOTE" | sed -E 's#.+[:/]([^/]+)/([^/.]+)(\.git)?$#\2#')
     ```
   - **PowerShell**:
     ```powershell
     $GH_REMOTE = git remote get-url origin 2>$null
     if ($GH_REMOTE -match '[:/]([^/]+)/([^/.]+?)(?:\.git)?$') {
         $GH_OWNER = $Matches[1]
         $GH_REPO  = $Matches[2]
     }
     ```

2. **Default Branch** — query the remote for its HEAD branch:
   - **bash/zsh**:
     ```bash
     GH_DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | grep "HEAD branch" | awk '{print $NF}')
     ```
   - **PowerShell**:
     ```powershell
     $GH_DEFAULT_BRANCH = (git remote show origin 2>$null | Select-String "HEAD branch") -replace '.*:\s*', ''
     ```
   - This handles `main`, `master`, `develop`, or any other default branch name.

3. **Current Branch**:
   - **bash/zsh**: `GH_HEAD_BRANCH=$(git branch --show-current)`
   - **PowerShell**: `$GH_HEAD_BRANCH = git branch --show-current`

4. **Validation**: If any of `GH_OWNER`, `GH_REPO`, or `GH_DEFAULT_BRANCH` are empty, inform the user and abort.

## 2. Running API Calls

Use the appropriate method for the active shell:

**bash/zsh** — use the helper script:

```bash
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
bash "$SKILL_DIR/scripts/github.sh" "<ENDPOINT>" '<BODY>' <METHOD>
```

**PowerShell** — use the helper script:

```powershell
$SKILL_DIR = Split-Path -Parent $PSCommandPath
& "$SKILL_DIR\scripts\github.ps1" "<ENDPOINT>" '<BODY>' <METHOD>
```

For GET requests omit the body argument. For DELETE requests omit the body and use `DELETE` as the method.

### Inline Snippet (Alternative)

If the helper scripts are not available, use this reusable inline snippet.

> **Critical**: Always wrap in `powershell -Command { ... }`. Do NOT run as a plain one-liner — semicolons are truncated by the shell runner and the command will silently produce no output.

**PowerShell**:

```powershell
powershell -Command { $cfg = Get-Content "$env:USERPROFILE\.levelup" | ConvertFrom-StringData; $hdrs = @{ Authorization = "token $($cfg.GH_TOKEN)"; Accept = 'application/vnd.github+json'; 'X-GitHub-Api-Version' = '2022-11-28' }; Invoke-RestMethod -Uri "https://api.github.com<ENDPOINT>" -Headers $hdrs -Method <METHOD> -Body '<BODY>' | ConvertTo-Json -Depth 10 }
```

For GET requests, omit `-Body`. For DELETE, use `-Method DELETE` and omit `-Body`.

## 3. Operations

For every command below, a **bash/zsh** form and a **PowerShell** form are provided. Use the one that matches the active shell detected in step 1.

All endpoints use the pattern `/repos/{owner}/{repo}/...` — substitute `GH_OWNER` and `GH_REPO` from §1.B.

### A. Create Pull Request

- **Reference**: See `references/create-pr-payload.md` for full payload schema.
- **Auto-populated fields**:
  - `head` ← current branch (from §1.B.3)
  - `base` ← default branch (from §1.B.2), unless the user specifies a different target
- **Minimum required from user**: PR title. If not provided, draft one from recent commits.
- **Optional**: `body`, `draft` (boolean), `maintainer_can_modify`

**bash/zsh**:

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/pulls" \
  '{"title":"...","head":"<branch>","base":"<default>","body":"...","draft":false}' POST
```

**PowerShell**:

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/pulls" `
  '{"title":"...","head":"<branch>","base":"<default>","body":"...","draft":false}' POST
```

**Post-creation**: Report the PR number and URL to the user.

### B. List Pull Requests

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/pulls?state=open"
```

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/pulls?state=open"
```

Optional query params: `state` (open/closed/all), `head`, `base`, `sort`, `direction`, `per_page`.

### C. Get Pull Request Details

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>"
```

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>"
```

### D. Update Pull Request

- **Reference**: See `references/update-pr-payload.md` for full payload schema.
- Updatable fields: `title`, `body`, `state` (open/closed), `base`

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>" \
  '{"title":"...","body":"..."}' PATCH
```

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>" `
  '{"title":"...","body":"..."}' PATCH
```

### E. Add Comment to PR

GitHub PRs use the Issues API for comments:

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/issues/<NUMBER>/comments" \
  '{"body":"Comment text"}' POST
```

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/issues/<NUMBER>/comments" `
  '{"body":"Comment text"}' POST
```

### F. Request Reviewers

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>/requested_reviewers" \
  '{"reviewers":["username1","username2"]}' POST
```

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>/requested_reviewers" `
  '{"reviewers":["username1","username2"]}' POST
```

### G. Merge Pull Request

- **Safety First**: Merging is significant. Always confirm with the user before executing.

1. **Check merge status** first:

   ```bash
   bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>"
   ```

   Verify `mergeable` is `true` and `mergeable_state` is `clean`.

2. **Confirmation**: Present the PR title, number, and merge method. **Wait for explicit confirmation.**

3. **Execute merge**:

   ```bash
   bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>/merge" \
     '{"merge_method":"squash"}' PUT
   ```

   ```powershell
   & "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/pulls/<NUMBER>/merge" `
     '{"merge_method":"squash"}' PUT
   ```

   Supported `merge_method` values: `merge`, `squash`, `rebase`. Default to `squash` unless the user specifies otherwise.

### H. List Branches

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/$GH_OWNER/$GH_REPO/branches?per_page=100"
```

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/$GH_OWNER/$GH_REPO/branches?per_page=100"
```

## 4. Reading an External Repository

When tasked with reading any GitHub repo (fetching metadata, listing files, reading contents, etc.), always use the token from `~/.levelup`.

### Step 1 — Authenticate with the token from `~/.levelup`

First confirm the token is present (see §1.A step 3), then make the request:

**bash**:

```bash
GH_TOKEN=$(grep 'GH_TOKEN' ~/.levelup | cut -d= -f2)
curl -s -H "Authorization: token $GH_TOKEN" -H "Accept: application/vnd.github+json" https://api.github.com/repos/<OWNER>/<REPO>
```

**PowerShell**:

```powershell
powershell -Command { $cfg = Get-Content "$env:USERPROFILE\.levelup" | ConvertFrom-StringData; $hdrs = @{ Authorization = "token $($cfg.GH_TOKEN)"; Accept = 'application/vnd.github+json'; 'X-GitHub-Api-Version' = '2022-11-28' }; Invoke-RestMethod -Uri "https://api.github.com/repos/<OWNER>/<REPO>" -Headers $hdrs | ConvertTo-Json -Depth 5 }
```

- If this succeeds (HTTP 200), proceed with authenticated requests for the rest of the session.
- If it fails, move to Step 2.

### Step 2 — Report failure to the user

If the request fails, report clearly:

- The HTTP status code returned
- Whether it was a 401 (bad/expired token), 403 (forbidden — token lacks permission), or 404 (repo not found or no access)
- Suggested remediation:
  - **401**: Token is invalid or expired — generate a new PAT and update `~/.levelup`
  - **403**: Token exists but lacks required scopes — ensure `Contents: Read` and `Metadata: Read` are granted for the target org/repo
  - **404**: Repo may not exist, may be in a different org, or the token has no visibility into the org at all

> **Never silently fail.** Always surface the error and status code so the user can take action.

### Step 3 — List Directory Contents

Use the Contents API to list files and subdirectories at a given path. Omit `<PATH>` (or use an empty path) to list the repository root.

**bash**:

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/<OWNER>/<REPO>/contents/<PATH>"
```

**PowerShell**:

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/<OWNER>/<REPO>/contents/<PATH>"
```

The response is a JSON array of objects. Each object includes:

| Field          | Description                                       |
| -------------- | ------------------------------------------------- |
| `name`         | File or directory name                            |
| `path`         | Full path relative to repo root                   |
| `type`         | `file`, `dir`, or `symlink`                       |
| `size`         | Size in bytes (files only; 0 for directories)     |
| `download_url` | Direct download URL (files only; `null` for dirs) |

To recurse into a subdirectory, call the same endpoint with the subdirectory path.

### Step 4 — Retrieve File Contents

To retrieve the contents of a single file:

**bash**:

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/<OWNER>/<REPO>/contents/<FILE_PATH>"
```

**PowerShell**:

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/<OWNER>/<REPO>/contents/<FILE_PATH>"
```

The response is a JSON object with:

| Field          | Description                                                   |
| -------------- | ------------------------------------------------------------- |
| `content`      | Base64-encoded file content                                   |
| `encoding`     | Always `base64`                                               |
| `size`         | File size in bytes                                            |
| `download_url` | Direct raw URL — can be fetched without auth for public repos |

**Decoding the content**:

- **bash**: `echo '<content>' | base64 -d`
- **PowerShell**: `[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('<content>'))`

> **Size limit**: The Contents API returns file contents for files up to **1 MB**. For larger files, use the `download_url` directly or the Blobs API (`/repos/<OWNER>/<REPO>/git/blobs/<SHA>`).

### Step 5 — Retrieve Full Repository Tree

To get a recursive listing of all files and directories in one call:

**bash**:

```bash
bash "$SKILL_DIR/scripts/github.sh" "/repos/<OWNER>/<REPO>/git/trees/<BRANCH>?recursive=1"
```

**PowerShell**:

```powershell
& "$SKILL_DIR\scripts\github.ps1" "/repos/<OWNER>/<REPO>/git/trees/<BRANCH>?recursive=1"
```

Replace `<BRANCH>` with a branch name (e.g., `main`) or a tree SHA. The response includes a `tree` array where each entry has:

| Field  | Description                         |
| ------ | ----------------------------------- |
| `path` | Full path relative to repo root     |
| `mode` | Git file mode (e.g., `100644`)      |
| `type` | `blob` (file) or `tree` (directory) |
| `sha`  | Git SHA of the object               |
| `size` | File size in bytes (blobs only)     |

> **Truncation**: If the tree contains more than 100,000 entries or exceeds 7 MB, the response will be truncated (`truncated: true`). In that case, fall back to listing individual directories via the Contents API (Step 3).

## 5. Smart Defaults & Convenience

- **PR Body Generation**: If the user does not provide a body, offer to generate one from recent commits:
  ```bash
  git log origin/<base>..<head> --oneline --no-merges
  ```
- **Branch Push Check**: Before creating a PR, verify the current branch has been pushed:
  ```bash
  git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "NOT_PUSHED"
  ```
  If not pushed, offer to push first: `git push -u origin <branch>`.
- **Draft PRs**: Ask the user if they want to create a draft PR. Default to `false` unless specified.

## Core Tips

- **API Base URL**: Always `https://api.github.com`. Never hardcode a different URL.
- **Auth Header**: `token <GH_TOKEN>` (classic PAT) or `Bearer <GH_TOKEN>` (fine-grained PAT). The scripts try `token` first, which works for both.
- **Rate Limiting**: GitHub API has rate limits (5000 req/hour for authenticated users). If a 403 with `X-RateLimit-Remaining: 0` is returned, inform the user.
- **Error Handling**: On 422 (Validation Failed), display the `errors` array from the response body to the user.
