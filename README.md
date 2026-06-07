# Agentic Skills Hub

A monorepo for agentic skill and workflow development — reusable, installable building blocks for Claude Code (and Windsurf/Devin) that automate complex, multi-step engineering tasks.

## Skills

| Skill | Purpose | Location |
|-------|---------|----------|
| **npm-update** | Upgrade an npm repo to its newest compatible dependencies; handles Nx/Angular/NestJS migrations, conflict resolution, and breaking-change fixing | [`skills/npm-update/`](skills/npm-update/) |
| **knowledge-system** | Always-on agent contract + two workflows that give any repo compounding session recall via an atomic card/glossary store | [`skills/knowledge-system/`](skills/knowledge-system/) |

## Structure

```
skills/
  <skill-name>/
    README.md          # what the skill does and how to install it
    <skill-name>.md    # the workflow document the agent follows (main artifact)
    bin/               # optional: helper scripts / CLI tools
    lib/               # optional: pure-function modules for helpers
    test/              # optional: unit tests
    commands/          # optional: sub-commands (for multi-command skills)
    templates/         # optional: file templates the skill installs
    install.sh/.ps1    # optional: one-time global install script
```

Each skill is self-contained. A skill's minimum viable form is a single workflow markdown document the agent reads and follows. Helper scripts, tests, and install automation are additive.

## Adding a New Skill

1. Create `skills/<new-skill>/`
2. Add the workflow document (what the agent does, step by step)
3. Add a `README.md` with purpose and install instructions
4. Add helpers, tests, or install scripts as needed
5. Add a row to the table above
