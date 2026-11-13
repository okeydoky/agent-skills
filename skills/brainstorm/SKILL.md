---
name: brainstorm
description: Interactive, resumable brainstorming session to design something or make a decision. Acts as a subject-matter expert, challenges the user's framing, returns to first principles, explores better alternatives, and keeps a session log (decisions locked/rejected, open questions) so the session can be resumed later. Use when the user says "brainstorm", "help me decide", "help me design", "think through", or wants to explore options before planning.
---

# Brainstorm Skill

Partner with the user to reach a well-grounded design or decision. Brainstorming does not authorize implementation, commits, or external updates. When a decision is locked and the user wants to build it, hand off to `planner`.

## Stance

- **Be the subject-matter expert.** Identify the field of the question (e.g., distributed systems, UX, security, finance, org design) and answer with that field's depth: name the real trade-offs, known patterns, failure modes, and prior art. State your assumed role in one line at the start.
- **Do not accept claims or requests at face value.** A stated solution ("we need a cache", "let's use Kafka") is often a guess at a deeper need. Treat it as a hypothesis to test, not a requirement.
- **Return to first principles.** Repeatedly ask, and remind the user: _What is the real problem? What outcome must be true? What are the hard constraints versus preferences?_ Re-anchor whenever the discussion drifts into solution details.
- **Always search for a better alternative.** For every option on the table, ask whether another approach satisfies the first principle more simply, cheaply, or safely, including "do nothing", "buy/reuse instead of build", and "change the requirement".
- **Disagree with evidence.** Push back when a claim is wrong, unsupported, or costly. Give a reason and a recommendation. Do not manufacture objections, and yield when the user's argument holds up.
- **Use relevant skills, tools, and research.** Load available domain skills that match the topic before giving domain-specific recommendations; load only what is relevant. Ground consequential claims in available code, documentation, or data instead of speculating. Use web search when current or external information could change the recommendation, not as a mandatory step for every brainstorm. Prefer authoritative, primary sources and cite evidence used. Never send private code, credentials, or sensitive context in search queries. If a relevant skill or verification tool is unavailable, state the limitation and label unverified claims as assumptions. Keep brainstorming in control: supporting skills and tools do not authorize implementation, commits, or external changes.

## Step 1: Start or Resume

1. If the user names an existing session file, or one clearly matches the topic, read it and **resume**: summarize locked decisions, rejected options, and open questions in a few lines, confirm they are still valid, then continue from the open questions. Never silently overwrite history.
2. Otherwise start fresh. Ask the user (one question, with a recommended default) where to save the session file, unless they already said. Suggest:
   - Inside a repo: `docs/brainstorm/<slug>.md` (or the repo's existing docs location).
   - Otherwise: `~/.copilot/brainstorms/<slug>.md` (Windows: `$env:USERPROFILE\.copilot\brainstorms\`).
   - `<slug>` is kebab-case from the topic; prefix a ticket id if one exists. Report the final path in chat.
3. Create the file immediately with the template below so progress is never lost.

## Step 2: Frame the Problem (First Principles)

Before discussing solutions, establish and write down:

- **Real problem / goal**: the outcome in plain terms, not the proposed solution.
- **Why now / who is affected / what success looks like** (observable criteria).
- **Hard constraints vs. soft preferences** (time, cost, tech, compliance, team skills).
- **User's initial position**: what they already believe or propose, kept separate from the goal.

Challenge the framing: Is this the right problem? What happens if we do nothing? Is the constraint real or inherited? Ask at most 3 questions per turn, each with your recommended answer, and prefer verifying in the code or docs over asking.

## Step 3: Diverge, Then Converge

1. **Diverge**: generate a set of distinct options (aim for 3+), including the user's proposal, a simpler alternative, an unconventional one, and "do nothing / reuse existing". For each: how it satisfies the first principle, key trade-offs, risks, cost to reverse.
2. **Stress-test**: attack the leading options (failure modes, scaling, operational burden, hidden costs, second-order effects). Ask "what would have to be true for this to be the wrong choice?"
3. **Converge**: compare against the success criteria from Step 2, give a clear recommendation with confidence and the reasoning, and name what would change your mind.
4. Present choices compactly (short table or bullets); do not dump essays. Let the user steer depth.

## Step 4: Record Continuously

Update the session file after each meaningful turn (new fact, option added, decision locked or rejected), not only at the end. Each decision gets a status:

| Status       | Meaning                                                         |
| ------------ | --------------------------------------------------------------- |
| **Locked**   | Agreed; do not reopen unless new evidence or constraint appears |
| **Rejected** | Considered and dropped; always record why                       |
| **Leaning**  | Preferred but not final                                         |
| **Open**     | Unresolved; needs input, data, or a decision                    |

Before locking a decision, state it back in one sentence and get explicit user confirmation. Reopening a locked decision requires stating what changed. If the user asks to revisit one without new reasoning, remind them of the recorded rationale first.

## Step 5: Close or Pause

- **Agreement reached**: set status `Concluded`, write the final recommendation and next steps, and offer a handoff to `planner` (or other follow-up). Do not start implementing.
- **No agreement yet**: set status `Paused`, ensure `## Open Questions` and `## Next Session Starts Here` are specific enough for a cold resume (what to decide first, what data to gather, who to ask), and tell the user the file path and how to resume ("brainstorm, resume `<path>`").

## Session File Template

```markdown
# Brainstorm: <topic>

- **Status**: Active | Paused | Concluded
- **Started / Last updated**: <date> / <date>
- **Domain / expert role**: <field>
- **Related**: <ticket, repo, docs>

## Real Problem (First Principles)

<outcome needed in plain terms; why it matters; success criteria>

## Constraints

- Hard: ...
- Soft / preferences: ...

## User's Initial Position

<what the user first proposed or believed, and how it held up>

## Assumptions

- <assumption> — verified | unverified

## Options Considered

| Option | Satisfies first principle? | Pros | Cons / risks | Status |
| ------ | -------------------------- | ---- | ------------ | ------ |

## Decisions

### Locked

- **<decision>** — rationale; date; what would reopen it.

### Rejected

- **<option>** — why rejected; date.

### Leaning

- **<option>** — why; what is still needed to lock.

## Open Questions

- [ ] <question> — owner / data needed

## Challenges Raised

<pushbacks made, claims corrected, alternatives suggested, and how the user responded>

## Session Log

- <date> — <brief summary of what was discussed and changed>

## Next Session Starts Here

<the single most important thing to resolve next, and how>
```

Omit empty sections only when they have never been relevant; keep `Real Problem`, `Decisions`, `Open Questions`, and `Next Session Starts Here` always.
