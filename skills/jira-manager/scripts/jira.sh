#!/bin/bash

# Portable Jira API Client for Skills (Native macOS)
# Usage: bash jira.sh <endpoint> [payload_json_or_file] [METHOD]

ENDPOINT=$1
PAYLOAD=$2
METHOD=$3

if [ -z "$ENDPOINT" ]; then
    echo "Usage: bash jira.sh <endpoint> [payload_json_or_file] [METHOD]"
    exit 1
fi

# 1. Load configuration from ~/.levelup
ENV_PATH="$HOME/.levelup"

if [ ! -f "$ENV_PATH" ]; then
    echo "Error: ~/.levelup file not found. Create it in your home directory with JIRA_URL, JIRA_USER_EMAIL, and JIRA_TOKEN."
    exit 1
fi

# Parse ~/.levelup (ignoring comments and empty lines)
while IFS='=' read -r key value || [ -n "$key" ]; do
    if [[ ! $key =~ ^# && -n $key ]]; then
        # Strip potential carriage returns and quotes
        value=$(echo "$value" | tr -d '\r' | sed "s/^'//;s/'$//;s/^\"//;s/\"$//")
        export "$key=$value"
    fi
done < "$ENV_PATH"

if [ -z "$JIRA_URL" ] || [ -z "$JIRA_TOKEN" ]; then
    echo "Error: JIRA_URL and JIRA_TOKEN must be defined in ~/.levelup"
    exit 1
fi

BASE_URL="${JIRA_URL%/}"
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

# 3. Request Function
make_request() {
    local AUTH_HEADER="$1"
    local RESPONSE_FILE=$(mktemp)
    
    local CURL_ARGS=("-s" "-L" "-w" "%{http_code}" "-o" "$RESPONSE_FILE")
    CURL_ARGS+=("-X" "$HTTP_METHOD")
    CURL_ARGS+=("-H" "Authorization: $AUTH_HEADER")
    CURL_ARGS+=("-H" "Accept: application/json")
    CURL_ARGS+=("-H" "X-Atlassian-Token: no-check")

    # Only include Content-Type if there is a payload
    if [ -n "$PAYLOAD" ]; then
        CURL_ARGS+=("-H" "Content-Type: application/json")
        CURL_ARGS+=("${CURL_PAYLOAD_ARGS[@]}")
    fi

    local HTTP_CODE=$(curl "${CURL_ARGS[@]}" "$FULL_URL")

    # Output Debug to stderr
    echo "Debug: Status $HTTP_CODE" >&2
    LAST_HTTP_CODE=$HTTP_CODE

    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        if [ -s "$RESPONSE_FILE" ]; then
            # Pretty print with python3 if file not empty
            python3 -m json.tool < "$RESPONSE_FILE"
        fi
        rm "$RESPONSE_FILE"
        return 0
    else
        cat "$RESPONSE_FILE" >&2
        echo "" >&2
        rm "$RESPONSE_FILE"
        return 1
    fi
}

# 4. Try Bearer first, fallback to Basic
make_request "Bearer $JIRA_TOKEN"
RESULT=$?

if [ $RESULT -ne 0 ] && { [ "$LAST_HTTP_CODE" -eq 401 ] || [ "$LAST_HTTP_CODE" -eq 403 ]; } && [ -n "$JIRA_USER_EMAIL" ]; then
    echo "Debug: Auth failed ($LAST_HTTP_CODE). Retrying with Basic Auth fallback..." >&2
    BASIC_AUTH=$(echo -n "$JIRA_USER_EMAIL:$JIRA_TOKEN" | base64)
    make_request "Basic $BASIC_AUTH"
    RESULT=$?
fi

exit $RESULT
