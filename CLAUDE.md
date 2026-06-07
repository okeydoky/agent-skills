# Agentic Skills Hub — Dev Conventions

This repo is a hub for agentic skill/workflow development. Each skill lives under `skills/<name>/` and is self-contained.

## Working on a skill

**npm-update** — has Node.js helper scripts and tests:
```sh
cd skills/npm-update
npm test          # runs all unit tests (node --test, no network)
```

**knowledge-system** — pure markdown + one Node build tool; no package install needed:
```sh
# One-time global install (makes /knowledge-init and /knowledge-materialize available everywhere):
sh skills/knowledge-system/install.sh        # macOS / Linux
./skills/knowledge-system/install.ps1        # Windows PowerShell

# Build the knowledge index in any repo that has .knowledge/:
node .knowledge/_tools/build-index.mjs
```

## Skill conventions

- Workflow document (`<skill-name>.md` or `commands/*.md`) is the primary artifact — the agent reads and follows it.
- Helper scripts live in `bin/` (entry point) + `lib/` (pure functions). Keep IO and logic separate so logic is unit-testable.
- Tests use whatever runner fits the skill; npm-update uses `node --test`.
- Install scripts (`install.sh` / `install.ps1`) do one-time global setup; per-repo setup is a separate workflow command.
- No cross-skill dependencies — each skill ships and installs independently.

## Adding a new skill

See the root `README.md` for the canonical layout and checklist.
