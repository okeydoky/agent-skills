#!/bin/bash

# Install GitHub Copilot for VS Code (+ Devin CLI) skills.
# Copies every skill folder (SKILL.md) to ~/.copilot/skills
# (or $COPILOT_HOME/skills if set).
#
# Note: Devin CLI imports skills directly from GitHub Copilot's global skill
# directory (~/.copilot/skills), so it is intentionally NOT installed to a
# separate ~/.config/devin/skills location — that would just duplicate the
# same files. See: https://docs.devin.ai/cli/reference/configuration/read-config-from

# Get the directory where this script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define source and target paths
copilot_base_dir="${COPILOT_HOME:-$HOME/.copilot}"
copilot_skills_dir="$copilot_base_dir/skills"

# Define what to copy: every skill folder (each contains a SKILL.md)
skills=("archetype-discover" "archetype-invoker" "bootstrap-context" "draft-jira" "draft-pr" "execute-plan" "resolve-code-review" "review-plan" "ticket-to-plan" "github-manager" "jira-manager" "planner")

# Track what was copied
declare -a copied_items

# Create directories if they don't exist
mkdir -p "$copilot_skills_dir"

# Copy GitHub Copilot skills (folders) — also picked up by Devin CLI
echo "Copying GitHub Copilot skills..."
for skill in "${skills[@]}"; do
    source_path="$script_dir/skills/$skill"

    if [ -d "$source_path" ]; then
        dest_path="$copilot_skills_dir/$skill"

        # Remove existing destination if it exists
        rm -rf "$dest_path"

        cp -r "$source_path" "$dest_path"
        copied_items+=("✓ Copilot skill: $skill/ (folder)")
    else
        echo "Warning: Skill folder not found: $source_path" >&2
    fi
done

# Report results
echo ""
echo "============================================"
echo "Installation Complete!"
echo "============================================"
echo ""
echo "Copied items:"
for item in "${copied_items[@]}"; do
    echo "  $item"
done
echo ""
echo "Directory: $copilot_skills_dir"
echo ""
echo "Devin CLI reads skills from the Copilot skills dir above automatically;"
echo "no separate Devin install step is needed."
echo ""
