---
name: skill-prompt-reminder
description: At the end of a session where the user completed multi-step work (3+ tool calls forming a coherent sequence, unfamiliar file patterns, or a problem that took several attempts), ask once whether to extract it as a skill candidate. On yes, write a candidate file to the staging area. Skip single-step tasks, pure Q&A, and exploration that produced no concrete outcome.
---

# Skill Prompt Reminder

You are helping capture repeatable patterns before they fade from memory. The engineer is still in context and can judge quality better than any post-hoc automation.

## When to trigger

Trigger **once, at the end of a turn**, when the session included:

- A coherent sequence of 3+ tool calls that solved a concrete problem (not exploration).
- A problem that took multiple attempts and converged on a working approach.
- Unfamiliar file patterns or multi-file edits with a clear shape (e.g. "mutation + resolver + type", "migration + rollback + test").

Do **not** trigger for:

- Single-step tasks (one edit, one command, one question).
- Pure Q&A or explanation turns with no file changes.
- Dead ends, abandoned approaches, or sessions that ended unresolved.
- Turns where you already asked this question earlier in the session.

## What to ask

Ask exactly one short question, then stop and wait:

> That felt like a repeatable pattern. Would you like to extract it as a skill candidate?

Do not elaborate, do not list what you noticed, do not offer alternatives. One line.

## On "yes"

Write a candidate file to `~/.skill-harvest/staging/candidates/` (create the directory if it does not exist).

Filename: `YYYY-MM-DD-<short-slug>.md` using today's date and a 2–4 word slug derived from what was done.

Use this shape:

```markdown
---
slug: <short-slug>
date: YYYY-MM-DD
engineer: <git config user.name, or "unknown">
---

# <One-line description of the pattern>

## What was done
<2–4 bullet points: the direct sequence of actions that produced the outcome. No conversation, no dead ends.>

## Why it might recur
<1–2 sentences on what makes this likely to come up again.>

## Inputs / triggers
<What kicked this off — a command, a file, a request shape.>

## Artifacts
<Paths of files created or edited, commands run. Keep it concrete.>
```

Fill every field from what you actually observed in the session. If a field is genuinely unknown, write `unknown` — do not invent.

After writing, tell the user the path in one line and stop:

> Candidate written: `<path>`

## On "no" or silence

Do nothing. Do not re-ask. Do not log anything.

## Judgment

The engineer's "yes" is the quality signal. Your job is to make saying yes cheap (one question, one tap) and to produce a candidate good enough that future-them wouldn't cringe reading it. If you cannot produce a candidate that meets the quality bar in `ADVISORY.md`, do not ask.
