# Archetype Invoker — Integration Guide

How the archetype-invoker connects with sibling skills in the Windsurf ecosystem.

## Skill Interactions

### archetype-discover

When `repo_url` is not provided, the invoker delegates to `archetype-discover` to resolve the archetype name to a GitHub repository URL.

**Typical flow:** User describes task → `archetype-discover` returns best-fit archetype name + repo URL → `archetype-invoker` caches the repo and executes its workflow.

### github-manager

All GitHub API operations (listing repo trees, reading file contents, authentication via `~/.levelup`) are delegated to the `github-manager` skill. The invoker never calls GitHub APIs directly or references `github-manager`'s internal scripts.

### planner

For complex tasks the `planner` skill may decompose work into sub-modules. The invoker can be called for any sub-module that maps to a known archetype.

## Cache Convention

Archetypes are cached at:

```
{workspace_root}/archetypes/{archetype_name}/
```

- The full repository structure is preserved inside the cache directory.
- The cache persists across invocations — archetypes are fetched once and reused.
- Multiple archetypes live side by side under `archetypes/`.

## Dependency Resolution

Archetype workflows may depend on other archetypes. When a dependency is encountered, the invoker recursively resolves it through the same cache-check → fetch → select-workflow → execute cycle, with circular-dependency detection to prevent infinite loops. Maximum depth is controlled by `max_dependency_depth` in `config/default.json`.
