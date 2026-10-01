---
name: resolve-sonar
description: Triage SonarQube/SonarCloud findings (user provides file, line, and Sonar's exact message) — verify legitimacy against the code, weigh the cost of fixing (complexity, readability), then decide Fix, Won't Fix (accept), or False Positive. Only fixes when the finding is real and worth it. Use when the user pastes a Sonar issue, says "sonar", "quality gate", "code smell", "S1234 / typescript:S...", or asks whether to fix a Sonar warning.
argument-hint: "<file>:<line> <exact Sonar message / rule key>"
---

# Resolve Sonar

Sonar findings are **automated heuristics, not verdicts**. Rules are context-blind: they flag patterns, not bugs. This skill forces a judgment call before any code changes. Never apply a Sonar suggestion blindly.

## Core Invariant

Fix **only** when both hold:

1. **Legit** — the problem is real in this code (verified by reading it, not by trusting the rule text).
2. **Worth it** — the fix doesn't cost more (complexity, readability, risk, churn) than the issue does.

Everything else is Won't Fix or False Positive. "Make the quality gate green" is not a reason by itself.

## Step 0: Gather Input

Expect from the user: **file path, line number, exact Sonar message** (rule key if available, e.g. `typescript:S3776`, `java:S2095`).

- Missing file/line/message → ask for the missing piece. Don't guess which issue is meant.
- Multiple findings → split into a numbered list; triage each independently.
- Read the file with enough context (whole function, callers, related tests, sibling code). Line numbers may be stale vs. the scanned version; locate by the quoted code/message if they don't match.
- If a `CONTEXT.md` exists, read it; recorded decisions can justify a Won't Fix.
- Check for an existing suppression convention in the repo (`// NOSONAR`, `@SuppressWarnings("java:S...")`, `sonar.issue.ignore.multicriteria` in `sonar-project.properties`) and follow it.

## Step 1: Verify Legitimacy

Answer concretely, with `file:line` evidence:

1. **What does the rule actually claim?** Restate in one line. If the rule is unfamiliar, look up the rule key in Sonar docs (`https://rules.sonarsource.com/<language>/RSPEC-<n>`) rather than guessing.
2. **Is the claim true here?** Trace the code path. Check types, nullability, framework guarantees, upstream validation, whether the flagged value is user-controlled, whether the code is test/generated/vendored.
3. **Is it already handled elsewhere?** (guard in caller, framework auto-escaping, try-with-resources semantics, etc.)

Outcome of this step: **Real**, **Not real (False Positive)**, or **Unsure** (→ ask user; don't fabricate certainty).

Common false-positive patterns: taint analysis missing a sanitizer; "unused" symbol used via reflection/DI/serialization; "duplicate string literal" in tests or config keys; hardcoded-credential rules matching a placeholder/test fixture/variable name containing "password"; null-deref warnings on values guaranteed by a prior check Sonar can't see; "cognitive complexity" on a flat `switch`/mapping.

## Step 2: Weigh the Cost of Fixing (only if Real)

Sketch the fix mentally first. Then judge:

| Factor                      | Question                                                                          |
| --------------------------- | --------------------------------------------------------------------------------- |
| **Severity / blast radius** | Security hotspot, vulnerability, or bug in production path vs. pure style smell?  |
| **Readability**             | Does the fix make the code clearer, or does it scatter logic to satisfy a metric? |
| **Complexity added**        | New helpers, indirection, extra params, abstractions solely to appease the rule?  |
| **Risk**                    | Behavior change in untested/critical code? Public API change?                     |
| **Churn**                   | Touching many call sites or generated/legacy code for a minor gain?               |
| **Alternatives**            | Is there a smaller, more idiomatic fix than Sonar's suggestion?                   |

Rules of thumb:

- Security vulnerabilities / real bugs / resource leaks → fix unless truly unreachable.
- Cognitive complexity, duplication, long param lists, "extract method" smells → fix only if the result is _easier to read_; otherwise Won't Fix with rationale.
- Test code, generated code, migrations, vendored code → lean Won't Fix (or recommend excluding via `sonar.exclusions` / `sonar.test.exclusions` — propose, don't edit config unasked).
- Trivial and strictly-better fixes (unused import, redundant cast, missing `final`/`const`) → just fix.

## Step 3: Verdict

| Verdict                | Meaning                                                        | Action                                                   |
| ---------------------- | -------------------------------------------------------------- | -------------------------------------------------------- |
| **Fix**                | Real and worth it.                                             | Change the code (Step 4).                                |
| **Fix (modified)**     | Real and worth it, but Sonar's suggestion is not the best fix. | Implement the better fix; say why.                       |
| **Won't Fix (accept)** | Technically valid, but cost > benefit, or intentional design.  | No code change. Give rationale + suggested Sonar status. |
| **False Positive**     | The rule's claim is wrong for this code.                       | No code change. Give evidence + suggested Sonar status.  |
| **Needs input**        | Can't verify, or a tradeoff the user must decide.              | Ask; don't change code.                                  |

Record the verdict for every finding **before** editing anything.

## Step 4: Act

### Fix / Fix (modified)

- Smallest change that addresses the root cause. Prefer existing repo patterns/helpers.
- Don't introduce a new problem (swallowed exception, over-broad type, behavior change).
- Keep scope to the finding; no unrelated cleanup. If the same pattern appears in sibling code, mention it but don't fix without confirming.
- Run the relevant tests/linter/type-check for touched files. If a local scanner is configured (`sonar-scanner`, Gradle/Maven sonar task), don't run it unasked — it needs server access; just report that re-scan is needed.

### Won't Fix / False Positive

- **Do not change the code to silence it** unless the user asks. Inline suppression (`// NOSONAR`, `@SuppressWarnings`) is a code change — offer it as an option, with the narrowest scope and a one-line reason, rather than applying by default.
- Provide the text the user can paste into the Sonar UI.

## Step 5: Report

Per finding, in order, tight:

```markdown
## Sonar Resolution

1. **[Fix]** `S3776` Cognitive complexity too high — `src/foo.ts:42`
   Why legit/worth it: <evidence>. Fixed: <what changed>.

2. **[Won't Fix]** `S1192` Duplicated string literal — `src/bar.ts:10`
   Sonar status: Accepted / Won't Fix
   Comment: "<one-line paste-ready rationale>"

3. **[False Positive]** `S2068` Hard-coded password — `src/cfg.ts:7`
   Sonar status: False Positive
   Comment: "<one-line paste-ready evidence, e.g. value is a placeholder key name, not a credential>"

4. **[Needs input]** <summary> — Question: <what's needed>
```

Close with one line: counts of fixed / won't fix / false positive / pending.

## Rules

- Never apply Sonar's suggestion verbatim without checking it's the best fix.
- Every verdict cites something checked in the code (`file:line`) or in the rule docs — not plausibility.
- Never fix just to turn the gate green when the fix hurts readability or adds needless complexity.
- Never edit Sonar config, exclusions, or add suppressions without the user's go-ahead.
- Won't Fix ≠ False Positive: use False Positive only when the rule's claim is actually wrong; use Won't Fix when it's right but not worth acting on.
- If unsure, say so and ask.
