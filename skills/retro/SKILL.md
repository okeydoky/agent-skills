---
name: retro
description: Session retrospective, run right before closing a session. Reviews what happened (failed commands, workarounds, missing tools, user corrections, business decisions, skill friction) and recommends what to persist so future agents don't repeat mistakes. Proposes only; writes nothing until the user signs off. Use when the user says "retro", "wrap up", "close out the session", or "what should we remember".
---

# Retro

End-of-session review. Output = a short, ranked list of **persistence recommendations**, each with rationale and exact how-to-persist. Nothing is written until the user approves.

## Hard rules

1. **Propose, never apply.** No file writes, installs, or config changes before explicit sign-off (Step 5).
2. **Dual-platform.** Everything persisted must work in both **VS Code + GitHub Copilot** and **Devin IDE (Windsurf)**. See the compatibility matrix. If a target is single-platform, recommend the mirrored pair or pick a shared target instead.
3. **Hidden x Costly filter.** Persist only what is (a) not cheaply re-derivable from code/search/general knowledge AND (b) costly if a future agent gets it wrong. No session narrative, no file maps, no obvious facts.
4. **No secrets/PII.** Never persist tokens, credentials, internal URLs with secrets, or personal data.
5. **Be short.** Max ~7 recommendations, ranked by value. "Nothing worth persisting" is a valid, good answer - do not pad.

## Step 1: Gather evidence

Review the whole session (conversation, tool calls, errors, edits). Also run `git status` / `git diff --stat` when in a repo. Scan for these signals:

| Signal | Examples |
|---|---|
| **Failed attempts** | command/tool errored, retried, or was abandoned; approach tried then dropped |
| **Working solution** | the command/flags/sequence that finally worked after failures |
| **Missing tooling** | CLI/module/extension absent; needed install or PATH fix |
| **Environment quirks** | OS/shell gotchas (e.g. PowerShell syntax, path separators, quoting, auth, proxy) |
| **User corrections** | user said "no, do X instead", repeated a preference, or overrode a default |
| **Business/product decisions** | scope choice, rejected alternative, naming, constraint + the why |
| **Skill friction** | an invoked skill was unclear, wrong, missing a step, or needed improvisation |
| **Repeated discovery** | same file/command/fact looked up multiple times |

Keep a scratch list of candidates with evidence (what happened, where in the session).

## Step 2: Dedup against what already exists

Before recommending, check the candidate isn't already persisted. Read (if present):

- `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/`, `.devin/rules/`, `.windsurf/rules/`
- `CONTEXT.md` files; `.knowledge/index.md` (and relevant cards) if the repo uses the knowledge-system
- Global: `~/.copilot/instructions/`, `~/.codeium/windsurf/memories/global_rules.md`

Drop duplicates. If an existing entry is wrong/outdated, recommend an **update/removal** instead of a new entry.

## Step 3: Classify and pick a target

For each surviving candidate pick ONE type and ONE target.

| Type | Best target |
|---|---|
| Environment/tool gotcha + working command (machine-wide, any repo) | **Global instructions** |
| Missing tool | **Install recommendation** (command for user to run) + one line in global/repo instructions if agents must check for it |
| Repo-specific command, convention, pitfall, workflow | **Repo `AGENTS.md`** |
| Domain term or durable business/architecture decision (with why) | **`CONTEXT.md`** (or `.knowledge/` card if repo uses knowledge-system) |
| Rejected approach / "don't retry X" (repo-specific) | **`.knowledge/` card** if available, else **`AGENTS.md`** |
| Skill was wrong/unclear/missing a step | **Skill source edit** |

### Compatibility matrix (verify a target is dual-platform before proposing it)

| Target | Copilot (VS Code) | Devin IDE | Verdict |
|---|---|---|---|
| Repo `AGENTS.md` | read | read | **Preferred repo default** |
| Repo `CONTEXT.md` / `.knowledge/` | plain markdown, agent reads it | same | OK; needs the always-on pointer/contract (`/knowledge-init`) so agents look |
| `.github/copilot-instructions.md` | read | not read | Copilot-only -> mirror or use `AGENTS.md` |
| `.devin/rules/*.md` (legacy `.windsurf/rules/`) | not read | read | Devin-only -> mirror or use `AGENTS.md` |
| Global: `~/.copilot/instructions/<name>.instructions.md` | read (frontmatter `applyTo: '*'`) | not read | write **both** globals with identical body |
| Global: `~/.codeium/windsurf/memories/global_rules.md` | not read | read | write **both** globals with identical body |
| Skills (`SKILL.md` with `name` + `description` frontmatter) | `~/.copilot/skills/` or repo skills dir | imports from `~/.copilot/skills/` | keep body platform-agnostic |

Rules of thumb:
- Repo-level -> `AGENTS.md` (single file, both platforms). Do not create per-platform duplicates unless the user asks.
- Global-level has no shared file -> always recommend the **pair** (Copilot file + Devin file) with identical content, and say so.
- Content itself must be platform-neutral: no tool names only one platform has; phrase commands as shell commands, not "use the X tool". Note OS (Windows/macOS/Linux) when a command is OS-specific.
- Global entries should be **few and tight** (they load every session). Prefer repo-scope when the lesson is repo-specific.
- Do not recommend Copilot/Devin built-in "auto memory" as the sole store - it is not portable across the two platforms.

### Skill improvements

When a skill you invoked caused friction:
1. Identify the skill and the exact defect (step unclear, wrong command, missing precondition, missing failure handling).
2. **Ask the user for the skill's source location** (the installed copy in `~/.copilot/skills/` is usually a copy; edits there get overwritten on reinstall). Use `ask_user` if available.
3. Recommend an edit to the **source**, and remind to re-run the install script afterward so both platforms get it.

### Knowledge-system repos

If the repo has `.knowledge/`, do not write cards directly. Follow `~/.knowledge-system/workflows/knowledge-materialize.md` and `~/.knowledge-system/templates/inbox-draft.md`: draft to `.knowledge/inbox/`, then the user runs `/knowledge-materialize`. Recommend this path for rationale/gotcha/decision items.

## Step 4: Present recommendations

Output a short summary line, then one block per recommendation, ranked. Use this exact shape:

```
### R<n>. <one-line lesson>  [<type>]
- **Evidence:** what happened in this session (1-2 lines)
- **Rationale:** why a future agent benefits / what it saves
- **Persist to:** <target path(s)> (<platforms covered>)
- **How:** <exact steps: file, location in file, and the literal text/command to add (short)>
```

Then a one-line table of "considered but dropped" items (with reason) so the user can overrule the filter.

Write proposed entry text in imperative, concrete form, e.g. `On Windows PowerShell 5, don't use && ; chain with ; and check $?`. Include the **why** for decisions; include the **working command** for failures.

## Step 5: Get sign-off

Ask the user which to apply (`ask_user` with the recommendation IDs; allow "all", "none", or a subset; allow edits to wording). Do not proceed on silence or partial ambiguity.

## Step 6: Apply approved items only

- Edit exactly the approved targets; for dual-platform globals, write both files with identical body.
- Create the file if missing (global Copilot file needs frontmatter `description` + `applyTo: '*'`).
- Append to the right section; keep entries terse; do not reformat unrelated content.
- For installs, give the user the command to run; run it only if they said so.
- For skill edits, edit the source path the user gave, then tell them to re-run the install script.
- Verify each write (re-read the file), then report a one-line-per-item summary: what changed, where, platforms covered.
- Do not commit unless asked.
