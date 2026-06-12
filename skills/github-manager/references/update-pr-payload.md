# Update Pull Request — Payload Reference

## Endpoint

```
PATCH /repos/{owner}/{repo}/pulls/{pull_number}
```

## Updatable Fields

All fields are optional — only include the ones you want to change.

| Field                    | Type    | Description                                           |
|--------------------------|---------|-------------------------------------------------------|
| `title`                  | string  | Updated title of the pull request.                    |
| `body`                   | string  | Updated description/body (Markdown).                  |
| `state`                  | string  | `open` or `closed`. Use this to close a PR without merging. |
| `base`                   | string  | Change the base branch the PR targets.                |
| `maintainer_can_modify`  | boolean | Whether maintainers can push to the head branch.      |

## Example Payloads

### Update title and body

```json
{
  "title": "Fix login timeout issue (v2)",
  "body": "## Updated Summary\n\nRevised approach based on code review feedback."
}
```

### Close a PR without merging

```json
{
  "state": "closed"
}
```

### Re-open a closed PR

```json
{
  "state": "open"
}
```

### Change target branch

```json
{
  "base": "release/v2.1"
}
```

## Merge Pull Request

To merge (not just update), use a separate endpoint:

```
PUT /repos/{owner}/{repo}/pulls/{pull_number}/merge
```

### Merge Payload

| Field           | Type   | Default    | Description                                    |
|-----------------|--------|------------|------------------------------------------------|
| `commit_title`  | string | auto       | Custom title for the merge commit.             |
| `commit_message`| string | auto       | Custom message for the merge commit.           |
| `merge_method`  | string | `"merge"`  | One of: `merge`, `squash`, `rebase`.           |
| `sha`           | string | —          | SHA the head must match (safety check).        |

### Merge Example

```json
{
  "merge_method": "squash",
  "commit_title": "fix: login timeout (#42)"
}
```

## Request Reviewers

```
POST /repos/{owner}/{repo}/pulls/{pull_number}/requested_reviewers
```

### Payload

```json
{
  "reviewers": ["username1", "username2"],
  "team_reviewers": ["team-slug"]
}
```

## Common Errors

| Status | Reason                                                        |
|--------|---------------------------------------------------------------|
| 403    | Token lacks required permissions.                             |
| 404    | PR not found or token lacks repo access.                      |
| 405    | PR is not mergeable (merge endpoint).                         |
| 409    | Merge conflict — head is out of date with base.               |
| 422    | Validation failed — e.g., invalid state value or SHA mismatch.|
