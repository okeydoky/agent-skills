# Jira Deletion Payloads (iTrack)

Jira `DELETE` requests typically do not have a body. Options are passed via URL query parameters.

## 1. Safety Check
Always check for subtasks performing a `GET` request before deleting.

**Endpoint**: `GET /rest/api/2/issue/{KEY}?fields=subtasks`
**Response**:
```json
{
    "id": "123456",
    "key": "PROJ-101",
    "fields": {
        "subtasks": [
            { "id": "123457", "key": "PROJ-102" }
        ]
    }
}
```

## 2. Hard Delete
Removes the issue and its subtasks (if parameter is set).

**Endpoint**: `DELETE /rest/api/2/issue/{KEY}?deleteSubtasks=true`

## 3. Implementation Table
| Scenario | Parameter | Method |
| :--- | :--- | :--- |
| Single Issue (No subtasks) | None | DELETE |
| Task with Subtasks | `deleteSubtasks=true` | DELETE |
| Epic with Stories | `deleteSubtasks=false` (Stories are NOT deleted by default) | DELETE |

## 4. Error Codes
- **403 Forbidden**: You do not have the 'Delete Issue' permission in this project.
- **404 Not Found**: The issue key is invalid or the issue has already been deleted.
- **400 Bad Request**: "Issue has subtasks and deleteSubtasks is false".
