# Jira API Payloads (iTrack / Data Center)

Refer to these schemas when constructing payloads for the `jira-client.mjs` script.

## Create Issue
**Endpoint**: `POST /rest/api/2/issue`

### 1. User Story
```json
{
  "fields": {
    "project": { "key": "GENAIISR" },
    "summary": "Implement Login Feature",
    "description": "Details about the story...",
    "issuetype": { "name": "Story" },
    "customfield_10777": "Acceptance criteria text"
  }
}
```

### 2. Bug
```json
{
  "fields": {
    "project": { "key": "GENAIISR" },
    "summary": "[Bug] Crashes on startup",
    "description": "Steps to reproduce...",
    "issuetype": { "name": "Bug" },
    "priority": { "id": "1" }
  }
}
```

### 3. Epic
*Note: iTrack requires specific fields for Epic Name.*
```json
{
  "fields": {
    "project": { "key": "GENAIISR" },
    "summary": "Large Feature Area",
    "issuetype": { "name": "Epic" },
    "customfield_10971": "Epic Name Value"
  }
}
```

## Update Issue / Add Comment
**Endpoint**: `POST /rest/api/2/issue/{KEY}/comment`
```json
{
  "body": "This is a comment message."
}
```

## Common iTrack Custom Fields
- **Acceptance Criteria**: `customfield_10777`
- **Epic Link**: `customfield_10970`
- **Scrum Team**: `customfield_16473`

## Troubleshooting
- **400 Bad Request**: "Field 'summary' cannot be set". 
  - Ensure you have the **Create Issue** permission in the project.
  - Check `GET /rest/api/2/mypermissions?projectKey=KEY`.
- **404 Not Found**: "Issue Does Not Exist". 
  - Confirm the Project Key is correct.
  - Check if the Project allows the specified `issuetype`.
- **401 Unauthorized**: User unrecognized.
  - Identity is confirmed by the `x-ausername` header in script output. If `anonymous`, check `~/.levelup`.
