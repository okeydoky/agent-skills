#!/bin/bash

# Portable GitHub API Client for Skills (Native macOS/Linux)
# Usage: bash github.sh <endpoint> [payload_json_or_file] [METHOD]

ENDPOINT=$1
PAYLOAD=$2
METHOD=$3

if [ -z "$ENDPOINT" ]; then
    echo "Usage: bash github.sh <endpoint> [payload_json_or_file] [METHOD]"
    exit 1
fi

# 1. Load configuration from ~/.levelup
ENV_PATH="$HOME/.levelup"

if [ ! -f "$ENV_PATH" ]; then
    echo "Error: ~/.levelup file not found. Create it in your home directory with GH_TOKEN."
    exit 1
fi

# Parse ~/.levelup (ignoring comments and empty lines)
while IFS='=' read -r key value || [ -n "$key" ]; do
    if [[ ! $key =~ ^# && -n $key ]]; then
        value=$(echo "$value" | tr -d '\r' | sed "s/^'//;s/'$//;s/^\"//;s/\"$//")
        export "$key=$value"
    fi
done < "$ENV_PATH"

if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN must be defined in ~/.levelup"
    exit 1
fi

BASE_URL="https://api.github.com"
FULL_URL="${BASE_URL}${ENDPOINT}"

# 2. Prepare Payload
HTTP_METHOD="GET"
if [ -n "$METHOD" ]; then
    HTTP_METHOD=$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')
elif [ -n "$PAYLOAD" ]; then
    HTTP_METHOD="POST"
fi

CURL_PAYLOAD_ARGS=()
if [ -n "$PAYLOAD" ]; then
    if [[ "$PAYLOAD" == "{"* || "$PAYLOAD" == "["* ]]; then
        CURL_PAYLOAD_ARGS=("-d" "$PAYLOAD")
    elif [ -f "$PAYLOAD" ]; then
        CURL_PAYLOAD_ARGS=("-d" "@$PAYLOAD")
    else
        echo "Error: Payload must be a JSON string or a valid file path."
        exit 1
    fi
fi

# 3. Execute request
RESPONSE_FILE=$(mktemp)

CURL_ARGS=("-s" "-L" "-w" "%{http_code}" "-o" "$RESPONSE_FILE")
CURL_ARGS+=("-X" "$HTTP_METHOD")
CURL_ARGS+=("-H" "Authorization: token $GH_TOKEN")
CURL_ARGS+=("-H" "Accept: application/vnd.github+json")
CURL_ARGS+=("-H" "X-GitHub-Api-Version: 2022-11-28")

if [ -n "$PAYLOAD" ]; then
    CURL_ARGS+=("-H" "Content-Type: application/json")
    CURL_ARGS+=("${CURL_PAYLOAD_ARGS[@]}")
fi

HTTP_CODE=$(curl "${CURL_ARGS[@]}" "$FULL_URL")

echo "Debug: Status $HTTP_CODE" >&2

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    if [ -s "$RESPONSE_FILE" ]; then
        python3 -m json.tool < "$RESPONSE_FILE" 2>/dev/null || cat "$RESPONSE_FILE"
    fi
    rm "$RESPONSE_FILE"
    exit 0
else
    # Check for rate limiting
    if [ "$HTTP_CODE" -eq 403 ]; then
        echo "Possible rate limit exceeded. Check X-RateLimit-Remaining header." >&2
    fi
    cat "$RESPONSE_FILE" >&2
    echo "" >&2
    rm "$RESPONSE_FILE"
    exit 1
fi
