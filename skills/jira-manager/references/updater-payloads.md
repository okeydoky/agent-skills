# Jira Update Payloads (iTrack)

Refer to these schemas for `PUT` requests.

## 1. Core Fields
```json
{
  "fields": {
    "summary": "Updated summary title",
    "description": "Updated detailed description.",
    "priority": { "name": "High" }
  }
}
```

## 2. Custom Fields (Use mappings from field-mappings.json)
### Story Points
```json
{
  "fields": {
    "customfield_10693": 5
  }
}
```

### Sprint
```json
{
  "fields": {
    "customfield_10001": 5678
  }
}
```

## 3. Advanced Updates (Using 'update' for Comments)
```json
{
  "update": {
    "comment": [{ "add": { "body": "Updated via automated skill." } }]
  },
  "fields": {
    "customfield_10693": 8
  }
}
```

## 4. Status Transition (Advanced)
Note: Use `GET /rest/api/2/issue/{key}/transitions` to find transition IDs first.
```json
{
  "transition": { "id": "31" }
}
```
