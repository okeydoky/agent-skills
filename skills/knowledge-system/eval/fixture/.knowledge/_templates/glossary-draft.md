---
# A pre-approval GLOSSARY DRAFT (a TERM, not a fact) staged by the capture reflex into a local
# `.knowledge/inbox/`. ONE term per file. A glossary entry is NOT a card: no `type`, no
# `confidence`, no index line. `materialize` renders it as one line in the right `CONTEXT.md`:
#     **<term>** — <definition>. _Avoid:_ <avoid…>
# Use only for vocabulary unique to THIS repo — never a general programming concept, never
# implementation detail (that's a card).
kind: glossary
term: tick
definition: One 5-second poll cycle on the order screen — the unit of cadence for live updates.
avoid:                      # optional — near-synonyms this term should displace
  - poll
  - interval
package:                    # optional route hint (e.g. apps/web). Omit → routed by the inbox this
                            # draft sits in, then by refs; a cross-cutting term → root CONTEXT.md.
refs:                       # optional — file:line that grounds the term
  - apps/web/src/orders/live-updates.ts:8
source: observed            # optional — observed | user-stated | session | commit:<sha> | pr:<n>
---
