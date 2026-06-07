---
id: kebab-slug-matches-filename            # = filename (without .md); the join key for refs/related
title: Human-readable label for this fact
summary: ONE near-lossless sentence; this is the index router line — retrieval routes on it without opening the card.
type: gotcha                # gotcha | rationale | architecture | operational   (locked enum)
topic: auth                 # ONE primary topic
tags: [session, cookies]
confidence: 8               # 1–10; below ~5 → hold, don't write
status: active              # active | stale | superseded | deprecated
created: 2026-06-06
updated: 2026-06-06
source: observed            # observed | user-stated | session | commit:<sha> | pr:<n> | ticket:<id>
refs:                       # code anchors; load-bearing for staleness. Capture at the moment.
  - src/auth/session.ts:47
  - sym:validateCookie
related: []                 # other card ids
supersedes: null
---
**Fact.** The one durable claim, stated plainly.
**Why it matters.** What goes wrong if a future agent doesn't know this.
**How to apply.** The concrete action a reader should take.
