---
id: auth-session-swallows-cookie-errors
title: Session validation swallows expired-cookie errors
summary: validateCookie() returns undefined (not throw) on missing/expired cookies; callers must null-check or they silently treat an expired session as logged-out.
type: gotcha
topic: auth
tags: [session, error-handling, cookies]
confidence: 8
status: active
created: 2026-03-02
updated: 2026-03-02
source: observed
refs:
  - libs/auth/src/session.ts:12
  - sym:validateCookie
related: []
supersedes: null
---
**Fact.** `validateCookie()` returns `undefined` instead of throwing when the cookie is missing
or expired.
**Why it matters.** A caller that assumes it throws (try/catch) will never catch anything and will
silently treat an expired session as "not logged in" — masking real auth bugs.
**How to apply.** Always null-check the return value; branch explicitly on `undefined` to
distinguish "no session" from a valid one.
