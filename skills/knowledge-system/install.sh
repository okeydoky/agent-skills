#!/usr/bin/env sh
# One-time global install (macOS / Linux). Run from the cloned repo: `sh install.sh [claude|windsurf|all]`
#
# Installs:
#   1) the shared assets (contract, tools, templates, workflow procedures) -> ~/.knowledge-system/
#   2) thin platform front-ends:
#        Claude Code            -> ~/.claude/commands/            (/knowledge-init, /knowledge-materialize)
#        Windsurf/Devin Desktop -> ~/.codeium/windsurf/global_workflows/
#
# With no argument, platforms are auto-detected (~/.claude and/or ~/.codeium/windsurf present).
# Re-run anytime to update — initialized repos never need touching (they carry content only).
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
ASSETS="${HOME}/.knowledge-system"
TARGET="${1:-detect}"

# 1) shared assets (refresh on re-run)
mkdir -p "$ASSETS"
for d in contract tools templates workflows; do
  rm -rf "$ASSETS/$d"
  cp -R "$SRC/$d" "$ASSETS/$d"
done
echo "assets   -> $ASSETS"

want() { [ "$TARGET" = "all" ] || [ "$TARGET" = "$1" ]; }
detected() { [ "$TARGET" = "detect" ] && [ -d "$2" ]; }
installed_any=0

# 2a) Claude Code front-ends
if want claude || detected claude "$HOME/.claude"; then
  mkdir -p "$HOME/.claude/commands"
  cp "$SRC"/frontends/claude/*.md "$HOME/.claude/commands/"
  # legacy asset location from the pre-v1.3 installer
  if [ -d "$HOME/.claude/knowledge-system" ]; then
    rm -rf "$HOME/.claude/knowledge-system"
    echo "cleaned  -> ~/.claude/knowledge-system (legacy asset dir; replaced by ~/.knowledge-system)"
  fi
  echo "claude   -> $HOME/.claude/commands  (/knowledge-init, /knowledge-materialize)"
  installed_any=1
fi

# 2b) Windsurf / Devin Desktop front-ends (global workflows)
if want windsurf || detected windsurf "$HOME/.codeium/windsurf"; then
  mkdir -p "$HOME/.codeium/windsurf/global_workflows"
  cp "$SRC"/frontends/windsurf/*.md "$HOME/.codeium/windsurf/global_workflows/"
  echo "windsurf -> $HOME/.codeium/windsurf/global_workflows  (/knowledge-init, /knowledge-materialize)"
  installed_any=1
fi

if [ "$installed_any" = "0" ]; then
  echo "No platform detected (~/.claude or ~/.codeium/windsurf). Assets installed;"
  echo "re-run with an explicit target: sh install.sh claude | windsurf | all"
else
  echo
  echo "Next: cd into a repo and run /knowledge-init"
fi
