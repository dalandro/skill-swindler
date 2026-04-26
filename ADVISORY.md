# Advisory

Living guidance on what makes a good skill candidate, how to handle candidates,
and where the quality bar sits. Update it as the team learns what works.

---

## What makes a good candidate

A good candidate describes **a direct sequence of actions that solved a concrete
problem** and has **a shape that could recur**. If a future engineer read it
cold, they should be able to reproduce the outcome without re-deriving the
approach.

A single occurrence is enough. Recurrence isn't predicted at write time — it's
detected later, by the same shape stacking up in the staging pile.

**Strong signals:**

- The sequence is stable — the steps would look the same if redone.
- The outcome is verifiable (a test passes, a config loads, an endpoint responds).
- The pattern has clear inputs and a clear stopping point.

**Weak signals / noise:**

- Unique-shape work — a fix whose steps wouldn't help anyone else.
- Exploration that produced understanding but no concrete artifact.
- Work where the "right" approach is still in flux.
- Conversational turns with no tool calls.

---

## How to annotate a candidate

When you review a candidate in `staging/candidates/`, add a short block at the
bottom labelled `## Review`. Keep it tight:

```markdown
## Review
- verdict: promote | hold | discard
- reviewer: <name>
- notes: <one or two sentences>
```

- **promote** — this should become a live skill; open a PR moving it under `skills/live/`.
- **hold** — good pattern but needs more occurrences before it justifies a skill.
- **discard** — noise, duplicate, or the pattern has drifted.

Do not delete discarded candidates immediately; leave them for a week so others
can disagree. After a week, remove them in a batch.

---

## How to write a watchlist entry

Add an entry to `watchlist.yml` when you notice a pattern repeating in the wild
that the automated system should prime on. A good entry is:

- **Specific enough** that the extractor can recognise it (concrete file paths,
  command shapes, tool sequences).
- **General enough** that it captures variants, not a single instance.
- **Owned** — at least one engineer in `seen_by` so there's a human to consult.

Remove entries when the pattern has graduated to a live skill or has proven to
be a one-off.

---

## Quality bar for promotion to live skill

Do not promote a candidate to `skills/live/` unless **all** of these hold:

1. It has appeared in **3+ sessions across 2+ engineers** (Stage 4 will enforce
   this automatically; until then, check by hand).
2. The action sequence is stable — reviewers agree on what the steps are.
3. The skill, as written, would have saved real time on the sessions that
   produced it. If it would have produced worse output than the engineer
   writing it from scratch, it fails the bar.
4. A reviewer who did not author the candidate has read it and agreed.

When in doubt, hold. A small library of skills that pull their weight is worth
more than a large library of mediocre ones.
