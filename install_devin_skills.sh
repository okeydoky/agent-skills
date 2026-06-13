#!/bin/bash

# Install Devin/Windsurf skills and workflows
# Copies workflows and skill folders to ~/.codeium/windsurf directories

# Get the directory where this script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define source and target paths
base_dir="$HOME/.codeium/windsurf"
workflows_dir="$base_dir/global_workflows"
skills_dir="$base_dir/skills"

# Define what to copy
workflows=("bootstrap-context" "draft-pr" "execute-plan" "review-plan" "ticket-to-plan")
skills=("github-manager" "jira-manager" "planner")

# Track what was copied
declare -a copied_items

# Create directories if they don't exist
mkdir -p "$workflows_dir"
mkdir -p "$skills_dir"

# Copy workflows
echo "Copying workflows..."
for workflow in "${workflows[@]}"; do
    source_path="$script_dir/skills/$workflow/$workflow.md"

    if [ -f "$source_path" ]; then
        dest_path="$workflows_dir/$workflow.md"
        cp "$source_path" "$dest_path"
        copied_items+=("✓ Workflow: $workflow.md")
    else
        echo "Warning: Workflow not found: $source_path" >&2
    fi
done

# Copy skills
echo "Copying skills..."
for skill in "${skills[@]}"; do
    source_path="$script_dir/skills/$skill"

    if [ -d "$source_path" ]; then
        dest_path="$skills_dir/$skill"

        # Remove existing destination if it exists
        rm -rf "$dest_path"

        cp -r "$source_path" "$dest_path"
        copied_items+=("✓ Skill: $skill/ (folder)")
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
echo "Location: $base_dir"
echo ""
echo "Copied items:"
for item in "${copied_items[@]}"; do
    echo "  $item"
done
echo ""
echo "Directories:"
echo "  Workflows: $workflows_dir"
echo "  Skills:    $skills_dir"
echo ""
