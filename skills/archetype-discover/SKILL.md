---
name: archetype-discover
description: >
  Takes a task description and returns the best-fit archetype with name,
  repo URL, and confidence level.
---

# Archetype Discover

This is an instruction-driven skill. Read `ARCHETYPE_SUMMARY.md` (in this skill's directory) and follow the procedure below. There are no scripts to run.

## Procedure

### Step 1 — Load the Catalog

Read `ARCHETYPE_SUMMARY.md` in full. Each archetype entry contains:

- **Name** — identifier (e.g. `agent-developer`)
- **Does** — what it does
- **Best fit** — when to use it
- **Keywords** — high-signal terms for matching
- **Depends on** — tools/frameworks it requires (optional)
- **Repo** — source repository URL

### Step 2 — Match

Given the user's task description, evaluate each archetype by:

1. **Keywords first** — check for direct keyword overlap with the task.
2. **Intent second** — compare the task against each archetype's "Does" and "Best fit" descriptions.
3. **Dependencies** — note if the task mentions tools/frameworks listed in "Depends on".

Select the top 1–3 archetypes. For each, assign a confidence:

- **high** — strong keyword + intent alignment
- **medium** — partial keyword or intent match
- **low** — weak/tangential match only

If no archetype reaches at least **medium** confidence, report that to the caller — do not guess.

### Step 3 — Return

Return results as:

| Field      | Value                                         |
| ---------- | --------------------------------------------- |
| name       | archetype identifier (e.g. `agent-developer`) |
| repo_url   | from the Repo line in the catalog             |
| confidence | high / medium / low                           |
| does       | the "Does" description                        |
| best_fit   | the "Best fit" description                    |
