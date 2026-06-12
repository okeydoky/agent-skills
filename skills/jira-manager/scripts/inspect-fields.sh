#!/bin/bash

# Jira Field Inspector (Native macOS)
# Usage: bash inspect-fields.sh <mode: createmeta|issue> <key_or_project> [issuetype]

MODE=$1
TARGET=$2
ISSUE_TYPE=$3

if [ -z "$MODE" ] || [ -z "$TARGET" ]; then
    echo "Usage: bash inspect-fields.sh <mode: createmeta|issue> <key_or_project> [issuetype]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JIRA_CLIENT="$SCRIPT_DIR/jira.sh"

if [ "$MODE" == "createmeta" ]; then
    echo "Inspecting creation metadata for Project: $TARGET, IssueType: ${ISSUE_TYPE:-All}..." >&2
    ENDPOINT="/rest/api/2/issue/createmeta?projectKeys=$TARGET&expand=projects.issuetypes.fields"
    if [ -n "$ISSUE_TYPE" ]; then
        # Robust URL encoding using python
        ENCODED_TYPE=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "$ISSUE_TYPE")
        ENDPOINT="${ENDPOINT}&issuetypeNames=${ENCODED_TYPE}"
    fi

    # Fetch and parse with python
    RESPONSE=$(bash "$JIRA_CLIENT" "$ENDPOINT")
    if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
        echo "Error: Failed to fetch metadata from Jira." >&2
        exit 1
    fi
    echo "$RESPONSE" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
except Exception as e:
    print(f"Error parsing JSON: {e}", file=sys.stderr)
    sys.exit(1)
if not data.get("projects"):
    print("Error: No metadata found.")
    sys.exit(1)
res = {}
for project in data["projects"]:
    for it in project["issuetypes"]:
        fields = {}
        for fid, info in it["fields"].items():
            fields[info["name"]] = {
                "id": fid,
                "required": info["required"],
                "type": info["schema"].get("type") if "schema" in info else None,
                "custom": info["schema"].get("custom") if "schema" in info else None,
                "operations": info.get("operations")
            }
        res[it["name"]] = fields
print(json.dumps(res, indent=2))
'
elif [ "$MODE" == "issue" ]; then
    echo "Inspecting existing issue: $TARGET..." >&2
    RESPONSE=$(bash "$JIRA_CLIENT" "/rest/api/2/issue/$TARGET?expand=names,schema")
    if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
        echo "Error: Failed to fetch issue data from Jira." >&2
        exit 1
    fi
    echo "$RESPONSE" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
except Exception as e:
    print(f"Error parsing JSON: {e}", file=sys.stderr)
    sys.exit(1)
names = data.get("names", {})
schema = data.get("schema", {})
fields = data.get("fields", {})
res = {}
for fid, name in names.items():
    res[name] = {
        "id": fid,
        "type": schema[fid].get("type") if fid in schema else None,
        "custom": schema[fid].get("custom") if fid in schema else None,
        "value": fields.get(fid)
    }
print(json.dumps(res, indent=2))
'
else
    echo "Error: Invalid mode '$MODE'. Use 'createmeta' or 'issue'."
    exit 1
fi
