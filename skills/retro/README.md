# retro

End-of-session retrospective. Run right before closing a session: the agent reviews what happened (failed commands, workarounds, missing tools, corrections, decisions, skill friction) and **recommends** what to persist so future sessions don't repeat mistakes. It never writes anything without your sign-off.

## Output

Ranked recommendations, each with evidence, rationale, target, and exact how-to-persist. Targets: global instructions, repo `AGENTS.md`, `CONTEXT.md` / `.knowledge/` (via knowledge-system inbox), tool installs, or edits to a skill's source.

## Platform compatibility

Designed for VS Code + GitHub Copilot and Devin IDE. Repo-level lessons go to `AGENTS.md` (read by both). Global lessons are written as an identical pair: `~/.copilot/instructions/*.instructions.md` and `~/.codeium/windsurf/memories/global_rules.md`. The full matrix is in [SKILL.md](SKILL.md).

## Install

- **Devin IDE:** `install_devin_skills.ps1` / `.sh` at the repo root copies it to `~/.codeium/windsurf/skills/retro/`.
- **VS Code Copilot:** copy/symlink `skills/retro/` to `~/.copilot/skills/retro/`.

## Use

Invoke `retro` (e.g. "run retro") at the end of a session.
