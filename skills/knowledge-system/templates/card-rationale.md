---
id: kebab-slug-naming-the-rejected-option   # name the rejected option so "let's try B" routes here
title: Chose X over Y for <decision>
summary: Chose X over Y for <decision>; Y rejected — <the specific reason>.   # names the rejected option(s)
type: rationale
topic: realtime
tags: [websockets, polling, proxy]          # include the rejected option(s) as tags
confidence: 9
status: active
created: 2026-06-06
updated: 2026-06-06
source: ticket:PROJ-1234                     # the ticket carries the discussion a human needs to refresh context
refs:
  - apps/web/src/orders/live-updates.ts
related: []
supersedes: null
---
**Decision.** The question + the chosen option, NAMED not elaborated (the code shows the detail).
**Rejected.** Each rejected option + the *specific* reason it lost. This is the payload — the only
irrecoverable content; spend the body's weight here. Do NOT re-document the chosen design.
**Valid while.** The condition(s) that keep the rejection binding. When they change, the rejected
option is back on the table — this is the line the decision gate surfaces and lint re-confirms.
