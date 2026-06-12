# Create Pull Request — Payload Reference

## Endpoint

```
POST /repos/{owner}/{repo}/pulls
```

## Required Fields

| Field  | Type   | Description                                      |
|--------|--------|--------------------------------------------------|
| `title`| string | The title of the pull request.                   |
| `head` | string | The branch where your changes are. Can be `user:branch` for cross-repo PRs. |
| `base` | string | The branch you want the changes pulled into (e.g., `main`, `master`). |

## Optional Fields

| Field                    | Type    | Default | Description                                           |
|--------------------------|---------|---------|-------------------------------------------------------|
| `body`                   | string  | `""`    | The description/body of the pull request (Markdown).  |
| `draft`                  | boolean | `false` | If `true`, creates a draft pull request.              |
| `maintainer_can_modify`  | boolean | `true`  | Whether maintainers can modify the head branch.       |

## Example Payload

### Minimal

```json
{
  "title": "Fix login timeout issue",
  "head": "fix/login-timeout",
  "base": "main"
}
```

### Full

```json
{
  "title": "Fix login timeout issue",
  "head": "fix/login-timeout",
  "base": "main",
  "body": "## Summary\n\nFixes the session timeout bug reported in #42.\n\n## Changes\n- Increased token TTL from 15m to 30m\n- Added retry logic on 401 responses",
  "draft": false,
  "maintainer_can_modify": true
}
```

## Common Errors

| Status | Reason                                                        |
|--------|---------------------------------------------------------------|
| 403    | Token lacks `pull_requests:write` permission.                 |
| 404    | Repository not found or token lacks access.                   |
| 422    | Validation failed — e.g., head branch doesn't exist, or a PR already exists for that head/base pair. |

## Notes

- `head` must be a branch that has been pushed to the remote.
- If a PR already exists for the same `head` → `base`, GitHub returns 422.
- For cross-fork PRs, use the format `owner:branch` for the `head` field.
