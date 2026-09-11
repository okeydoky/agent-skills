---
name: archetype-invoker
description: Resolves, caches, and executes archetype workflows to perform user tasks. Delegates discovery to archetype-discover and GitHub operations to github-manager.
---

# Archetype Invoker

This skill dynamically resolves an archetype, ensures it is cached locally, selects the best-fit workflow for the user's task, and executes that workflow end-to-end.

> **Instruction-driven skill.** The AI agent executes every step below using built-in tools and sibling skills. There are no scripts to run.

---

## 1. Input Parameters

| Parameter        | Required | Description                                                            |
| ---------------- | -------- | ---------------------------------------------------------------------- |
| `archetype_name` | Yes      | Identifier for the archetype (e.g., `ppt-maker`, `agent-developer`)   |
| `repo_url`       | No       | GitHub URL (`https://github.com/{owner}/{repo}`). Resolved if absent.  |
| `task_context`   | No       | Current task description — may be inferred from conversation context.  |

---

## 2. Invocation Procedure

Follow these steps **in order**. Do not skip steps.

### Step 1 — Resolve Archetype Source

1. Confirm `archetype_name` is a non-empty string.
2. If `repo_url` is provided, validate it matches `https://github.com/{owner}/{repo}` (with or without `.git` suffix). Extract `{owner}` and `{repo}`.
3. If `repo_url` is **not** provided, delegate to the **`archetype-discover`** skill with the `archetype_name` (and `task_context` if available) to obtain the `repo_url`.
4. If `archetype-discover` cannot resolve a repo URL (e.g., unknown archetype, no match found), **STOP** the workflow and report the failure to the user. Do not guess or fabricate a URL.

### Step 2 — Check Local Cache

The cache directory is:

```
{workspace_root}/archetypes/{archetype_name}
```

For example: `archetypes/ppt-maker`

1. Check whether the cache directory exists **and** contains files.
2. **If cached**: Skip to Step 4. The archetype is ready to use.
3. **If not cached**: Proceed to Step 3.

### Step 3 — Fetch Archetype to Cache

Use the **`github-manager`** skill to clone/download the archetype repository contents into the cache directory.

1. Delegate to `github-manager` to fetch the full repository tree from `{owner}/{repo}`.
2. Write all fetched contents into `{workspace_root}/archetypes/{archetype_name}/`, preserving the repository's directory structure.
3. For shell scripts (`*.sh`), ensure they are executable (`chmod +x`).
4. If the fetch fails (auth error, 404, rate limit, etc.), **STOP** and report the error. Do not continue with partial data. Refer the user to `github-manager`'s credential setup (`~/.levelup`) if it is an auth issue.

### Step 4 — Select Workflow

Each archetype contains workflow files that describe how to perform specific tasks. Locate them using this search order:

1. `.windsurf/workflows/` directory — scan all `.md` files within it.
2. `workflows/` directory at the archetype root — scan all `.md` files within it.
3. Root-level fallback files (in priority order): `WORKFLOW.md`, `README.md`, `INSTRUCTIONS.md`.

From the discovered workflow files:

- Read each workflow's title, description, or introductory section.
- **Select the single workflow that best matches the user's task** based on the task description and workflow purpose.
- If multiple workflows seem equally relevant, briefly list them and ask the user to choose.
- If **no** workflow files are found, **STOP** and report to the user that the archetype has no recognizable workflows.

### Step 5 — Execute Workflow

1. Read the selected workflow document **in full**.
2. **Follow its instructions as written** — the workflow is your execution plan.
3. Use any assets, scripts, configs, or templates referenced by the workflow from the cached archetype directory.
4. Adapt execution to `task_context` when provided (e.g., naming conventions, technology choices, target paths).
5. If the workflow defines numbered or sequential steps, execute them in order.
6. Report progress to the user as each major step completes.

**If the workflow is ambiguous or incomplete:**

- Check other files in the archetype cache for clarification (READMEs, configs, etc.).
- If still unclear, **ask the user** before proceeding. Do not guess at critical decisions.

**If a workflow step fails:**

- Report the failure with error details.
- If the step is critical, **STOP** and wait for user direction.
- If non-critical, note the failure and continue.

### Step 6 — Resolve Archetype Dependencies

If the workflow references or depends on **another archetype** (e.g., "requires `guardrails-engineer`" or "invoke `agent-validator`"):

1. Treat the dependency as a new invocation of this skill — **repeat Steps 1–5** for the dependent archetype.
2. The dependent archetype uses the same cache convention: `{workspace_root}/archetypes/{dependency_name}`.
3. After the dependency workflow completes, resume the original workflow from where it left off.
4. Track invoked archetypes to **prevent circular dependencies**. If a cycle is detected, **STOP** and report it.

---

## 3. Error Handling

| Scenario                        | Action                                                                                       |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| `archetype_name` missing/empty  | STOP — ask user for the archetype name.                                                      |
| `repo_url` invalid format       | STOP — report the malformed URL.                                                             |
| Discovery returns no match      | STOP — report that no archetype was found for the given name.                                |
| GitHub API 401/403              | STOP — direct user to verify `GH_TOKEN` in `~/.levelup` (per `github-manager` setup).       |
| GitHub API 404                  | STOP — ask user to verify the repository URL and access permissions.                         |
| GitHub rate limit               | STOP — inform user and suggest waiting or checking token auth.                               |
| No workflow files in archetype  | STOP — report the finding and ask user for guidance.                                         |
| Circular archetype dependency   | STOP — report the dependency cycle and list the chain.                                       |

**General rule:** Never continue a workflow with partial or missing data. Always STOP and inform the user.

---

## 4. Skill Dependencies

| Skill                  | Purpose                                                                     |
| ---------------------- | --------------------------------------------------------------------------- |
| `archetype-discover`   | Resolves `repo_url` when not provided. Provides archetype name → repo URL mapping. |
| `github-manager`       | All GitHub API operations — fetching repo contents, reading files, authentication. Never duplicate its logic. |

---

## 5. Cache Convention

```
{workspace_root}/
  archetypes/
    {archetype_name}/        ← full repo contents, preserving structure
      .windsurf/
        workflows/
          ...
      workflows/
        ...
      scripts/
        ...
      ...
    {another_archetype}/
      ...
```

- The `archetypes/` directory lives at the **workspace root**.
- Each archetype gets its own subdirectory named after the archetype.
- Contents mirror the source repository's structure exactly.
- The cache persists across invocations — archetypes are fetched once and reused.

---

## 6. Safety & Validation

- **URL validation**: Only `https://github.com/` URLs are accepted.
- **Path safety**: Never write files outside the workspace root. All archetype files go under `archetypes/`.
- **Destructive operations**: Confirm with the user before deleting files, overwriting existing project files, or running install commands.
- **Script review**: Before executing any script from a cached archetype, briefly describe its purpose and get user confirmation.
- **No logic duplication**: Authentication, API calls, and credential handling belong to `github-manager`. Discovery logic belongs to `archetype-discover`. This skill orchestrates — it does not reimplement.
