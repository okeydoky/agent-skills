# Agentic Skills Hub

A monorepo for agentic skill and workflow development — reusable, installable building blocks for Claude Code, GitHub Copilot (VS Code), and Devin that automate complex, multi-step engineering tasks. Every skill follows the [Agent Skills standard](https://agentskills.io/specification) (`SKILL.md` with YAML frontmatter), so the same files work across all of them.

## Skills

| Skill                 | Purpose                                                                                                                                                                                                                                | Location                                                 |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| **npm-update**        | Upgrade an npm repo to its newest compatible dependencies; handles Nx/Angular/NestJS migrations, conflict resolution, and breaking-change fixing                                                                                       | [`skills/npm-update/`](skills/npm-update/)               |
| **knowledge-system**  | Always-on agent contract + two workflows that give any repo compounding session recall via an atomic card/glossary store                                                                                                               | [`skills/knowledge-system/`](skills/knowledge-system/)   |
| **ticket-to-plan**    | Fetch a Jira ticket + related issues, set up a branch, and delegate to the planner; transitions the ticket and hands off for fresh-session execution                                                                                   | [`skills/ticket-to-plan/`](skills/ticket-to-plan/)       |
| **planner**           | Discovery interview (with mandatory pushback and recommended answers) that produces a self-sufficient, phase-organized plan with per-phase model recommendations                                                                       | [`skills/planner/`](skills/planner/)                     |
| **review-plan**       | Cold-read adversarial review of a finished plan from a fresh session — verifies claims against the codebase, checks correctness + necessity/efficiency, and emits a SHIP/REVISE/BLOCK verdict to a sibling review file (findings-only) | [`skills/review-plan/`](skills/review-plan/)             |
| **execute-plan**      | Execute one or more plan phases, verify with tests, and update the plan with downstream-focused implementation notes                                                                                                                   | [`skills/execute-plan/`](skills/execute-plan/)           |
| **draft-pr**          | Draft a PR from the diff + plan files, then transition the Jira ticket and attach the plans                                                                                                                                            | [`skills/draft-pr/`](skills/draft-pr/)                   |
| **bootstrap-context** | One-time interview that seeds a repo's (or monorepo app's) `CONTEXT.md` glossary + durable-decision files for the planner to read                                                                                                      | [`skills/bootstrap-context/`](skills/bootstrap-context/) |

## Structure

```
skills/
  <skill-name>/
    README.md          # what the skill does and how to install it
    SKILL.md           # required: name + description frontmatter, the procedure the agent follows (main artifact)
    bin/               # optional: helper scripts / CLI tools
    lib/               # optional: pure-function modules for helpers
    test/              # optional: unit tests
    workflows/         # optional: sub-workflows (for multi-command skills)
    frontends/         # optional: thin per-platform entry points (e.g. claude/)
    templates/         # optional: file templates the skill installs
    install.sh/.ps1    # optional: one-time global install script
```

Each skill is self-contained. A skill's minimum viable form is a single `SKILL.md` the agent reads and follows. Helper scripts, tests, and install automation are additive.

## Installing

Run [`install_devin_skills.sh`](install_devin_skills.sh) (or `.ps1` on Windows) to copy every skill into `~/.copilot/skills/` — GitHub Copilot for VS Code (global). Devin CLI also imports skills directly from this directory, so no separate Devin install step is needed.

## Adding a New Skill

1. Create `skills/<new-skill>/`
2. Add the workflow document (what the agent does, step by step)
3. Add a `README.md` with purpose and install instructions
4. Add helpers, tests, or install scripts as needed
5. Add a row to the table above
