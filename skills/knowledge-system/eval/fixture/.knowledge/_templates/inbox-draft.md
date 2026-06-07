---
# A pre-approval DRAFT written by the capture reflex into a local `.knowledge/inbox/`.
# Fill what you KNOW NOW (esp. refs + source — they're only alive at this moment).
# `materialize` fills the rest (id, created/updated, status) and drops `justification`.
title: Human-readable label
summary: ONE near-lossless sentence (the future index router line).
type: gotcha                # gotcha | rationale | architecture | operational
topic: auth                 # ONE primary topic
tags: []
confidence: 7               # 1–10; below ~5 → don't draft
source: observed            # observed | user-stated | session | commit:<sha> | pr:<n> | ticket:<id>
refs:                       # capture NOW — file:line and/or sym:name
  - libs/auth/src/session.ts:12
justification: Hidden (returns undefined, not throw — not visible from the call site) × Costly (callers ship silent auth bugs)
---
**Fact.** ...
**Why it matters.** ...
**How to apply.** ...
