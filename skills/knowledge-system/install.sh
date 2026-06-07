#!/usr/bin/env sh
# One-time global install (macOS / Linux). Run from the cloned repo: `sh install.sh`
# Makes /knowledge-init and /knowledge-materialize available in EVERY repo, and drops the
# assets that /knowledge-init copies into each repo.
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${HOME}/.claude"

mkdir -p "$DEST/commands" "$DEST/knowledge-system"

# 1) global slash commands
cp "$SRC"/commands/*.md "$DEST/commands/"

# 2) assets that /knowledge-init copies into each target repo (refresh on re-run)
for d in contract tools templates commands; do
  rm -rf "$DEST/knowledge-system/$d"
  cp -R "$SRC/$d" "$DEST/knowledge-system/$d"
done

echo "Installed."
echo "  commands -> $DEST/commands  (/knowledge-init, /knowledge-materialize now work in any repo)"
echo "  assets   -> $DEST/knowledge-system"
echo
echo "Next: cd into a repo and run /knowledge-init"
