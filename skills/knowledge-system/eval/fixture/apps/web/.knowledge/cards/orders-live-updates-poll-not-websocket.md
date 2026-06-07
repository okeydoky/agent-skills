---
id: orders-live-updates-poll-not-websocket
title: Live order updates use polling, not websockets
summary: Chose 5s polling over websockets for live order updates; websockets rejected — the corp egress proxy buffers long-lived connections, breaking realtime.
type: rationale
topic: realtime
tags: [websockets, polling, realtime, proxy, sse]
confidence: 9
status: active
created: 2026-04-12
updated: 2026-04-12
source: ticket:WEB-2210
refs:
  - apps/web/src/orders/live-updates.ts:5
related: []
supersedes: null
---
**Decision.** Live order updates use 5s server-side polling, not websockets.
**Rejected.** Websockets: the corp egress proxy buffers long-lived connections — push latency
spiked to 30–60s in staging, worse than polling and undebuggable from our side. SSE: same
proxy-buffering problem.
**Valid while.** All clients sit behind the corp proxy. If we ship a direct-internet client or
the proxy is replaced, re-evaluate — websockets would win on latency and server load.
