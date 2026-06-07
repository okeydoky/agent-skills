---
id: auth-managed-provider-not-custom
title: Use the managed auth provider, never roll our own
summary: Chose a managed auth provider (Auth0) over a custom auth service; rolling our own was rejected — SOC2 scope and token-rotation maintenance outweighed any flexibility gain.
type: rationale
topic: auth
tags: [auth, auth0, custom-auth, build-vs-buy, soc2]
confidence: 9
status: active
created: 2026-02-01
updated: 2026-02-01
source: ticket:ARCH-104
refs:
  - libs/auth/src/session.ts
related: [auth-session-swallows-cookie-errors]
supersedes: null
---
**Decision.** All authentication goes through the managed provider (Auth0). `libs/auth` is a thin
adapter, not an auth implementation.
**Rejected.** Rolling our own auth service: pulls password storage, MFA, and token rotation into
our SOC2 audit scope and becomes permanent maintenance load. The flexibility we'd gain never
justified that ongoing cost.
**Valid while.** We remain a small team under SOC2. If compliance scope changes or the provider's
pricing/limits become blocking at scale, re-evaluate build-vs-buy.
