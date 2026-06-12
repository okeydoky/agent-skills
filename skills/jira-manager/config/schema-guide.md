# Jira Payload Schema Guide (iTrack)

This guide describes how to format data for common Jira field types found in iTrack.

## 1. Simple Types
- **String**: `"fields": { "summary": "Title text" }`
- **Number**: `"fields": { "customfield_10123": 5 }`
- **Array of Strings**: `"fields": { "labels": ["tag1", "tag2"] }`

## 2. Object References (Standard)
Most system fields (Priority, Project, IssueType) require objects with `id`, `name`, or `key`.
- **Project**: `{ "key": "PROJ" }`
- **Issue Type**: `{ "name": "Story" }`
- **Priority**: `{ "id": "1" }` (1=Highest, 2=High, 3=Medium, 4=Low, 5=Lowest)

## 3. Custom Fields (iTrack Specific)
- **User (Single)**: `{ "name": "username" }` or `{ "accountId": "..." }`
- **Multi-Select**: `[{ "value": "Option A" }, { "value": "Option B" }]`
- **Single-Select**: `{ "value": "Option A" }`
- **SQLFeed / Prisma**: Often expect a raw string even if they represent a list in the UI. 
  - Example: `"customfield_17001": "SelectedValue"`

## 4. Rich Text (Jira Markup)
iTrack uses Jira Text Formatting (not Markdown) for Descriptions and Comments.
- **Bold**: `*text*`
- **Italic**: `_text_`
- **Links**: `[Title|URL]`
- **Code**: `{code} ... {code}`
- **Panels**: `{panel:title=Title} ... {panel}`

## 5. Transitions
To move an issue (e.g., to "Done"), you must use the `/transition` endpoint with a `transition.id`:
- **Done**: Usually `id: "31"` (vaires by workflow)
- **Payload**: `{ "transition": { "id": "31" } }`
