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
# One-time global install (auto-detects Claude Code / Windsurf; or pass claude|windsurf|all).
# Puts shared assets at ~/.knowledge-system/ and the /knowledge-init + /knowledge-materialize
# front-ends into each platform's global command location:
sh skills/knowledge-system/install.sh        # macOS / Linux
./skills/knowledge-system/install.ps1        # Windows PowerShell

# Build the knowledge index in any repo that has .knowledge/ (repos carry no tooling):
node ~/.knowledge-system/tools/build-index.mjs .
```

## Skill conventions

- Workflow document (`<skill-name>.md` or `workflows/*.md`) is the primary artifact — the agent reads and follows it.
- Multi-platform skills keep one platform-agnostic core and ship thin per-platform entry points under `frontends/<platform>/` (see knowledge-system); never fork the core per platform.
- Helper scripts live in `bin/` (entry point) + `lib/` (pure functions). Keep IO and logic separate so logic is unit-testable.
- Tests use whatever runner fits the skill; npm-update uses `node --test`.
- Install scripts (`install.sh` / `install.ps1`) do one-time global setup; per-repo setup is a separate workflow command.
- No cross-skill dependencies — each skill ships and installs independently.

## Adding a new skill

See the root `README.md` for the canonical layout and checklist.
