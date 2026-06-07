# Glossary — libs/auth
<!-- Project-specific vocabulary only. One line per term. -->

**Session** — a decoded, unexpired auth token plus its `userId`/`expiresAt`. A *missing* or
*expired* session is represented as `undefined`, never an error. _Avoid:_ "login state" (broader).

**Adapter** — `libs/auth` is a thin wrapper over the managed provider, not an auth implementation.
_Avoid:_ "auth service" (implies we own the auth logic; we don't).
