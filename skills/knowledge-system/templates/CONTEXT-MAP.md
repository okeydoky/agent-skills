# Context map
<!-- Routes to every package's glossary (`CONTEXT.md`). Read the relevant one WHOLE when you enter
     that domain (contract reflexes 1 & 2). Maintained by `materialize` — it lists a package here
     once that package's CONTEXT.md gets its first term. Not a build artifact, but never hand-grown
     ahead of the glossaries it points at. -->

## Contexts
- **root** — cross-cutting vocabulary, defined in this directory's `CONTEXT.md` (created lazily).
<!-- materialize appends one line per package as its glossary is created, e.g.:
- **apps/web** — `apps/web/.knowledge/CONTEXT.md`
- **libs/auth** — `libs/auth/.knowledge/CONTEXT.md` -->

## Relationships
<!-- Only when it earns its keep: how two contexts relate, in one line each. e.g.:
- **apps/web → libs/auth**: web consumes auth's session primitives; `Session` is owned by libs/auth. -->
