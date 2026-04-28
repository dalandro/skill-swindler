---
name: skill-swindler
description: Extract repeatable patterns as skill candidates after multi-step sessions.
---

# Skill Swindler

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

Write a candidate file to `~/.skill-swindler/staging/candidates/` (create the directory if it does not exist).

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
The direct sequence of actions that produced the outcome — as many bullets as the pattern needs, no more. No conversation, no dead ends.
- <action>
- <action>
- ...

## Shape
<1–2 sentences describing the kind of work this was, generic enough that a reviewer can compare it against other candidates. Don't predict whether it will recur — that's detected later by similar candidates piling up.>

## Inputs / triggers
<What kicked this off — a command, a file, a request shape.>

## Artifacts
<Paths of files created or edited, commands run. Keep it concrete.>
```

Fill every field from what you actually observed in the session. If a field is genuinely unknown, write `unknown` — do not invent.

After writing, tell the user the path in one line and stop:

> Candidate written: `<path>`

## On "no" or silence

Do nothing. Do not re-ask.

## Judgment

The engineer's "yes" is the quality signal. Your job is to make saying yes cheap (one question, one tap) and to produce a candidate good enough that future-them wouldn't cringe reading it. If you cannot produce a candidate that meets the quality bar in `ADVISORY.md`, do not ask.
