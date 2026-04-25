# Skill Swindler

A Claude Code skill that asks once at the end of multi-step sessions whether the work felt repeatable, and writes a candidate file describing the pattern to a local folder if you say yes. The candidates are reviewed later — they are not themselves skills.

This is the first stage of a longer project — a system for surfacing repeatable patterns across a team of engineers and promoting them into shared, reusable skills. See `TODO.md` for the planned roadmap.

---

## The Problem

Repeatable work happens constantly and invisibly. One engineer configures a feature setting, another does the same thing a week later. Someone writes a GraphQL field, three others write near-identical ones. A package upgrade gets done twice with the same sequence of steps. Each time, the engineer either rediscovers the pattern alone or asks Claude to help from scratch.

The knowledge exists. It just never crystallises into something the whole team can use.

---

## What it does today

A single Claude Code skill — Skill Prompt Reminder — installed into `~/.claude/skills/`. At the end of sessions involving multi-step work (3+ tool calls forming a coherent sequence, multi-attempt problem-solving, or unfamiliar multi-file edits), Claude asks one question:

> That felt like a repeatable pattern. Would you like to extract it as a skill candidate?

On yes, Claude writes a candidate file to `~/.skill-harvest/staging/candidates/<date>-<slug>.md` using the shape in `staging/candidates/TEMPLATE.md`. On no or silence, Claude does nothing.

One engineer, one machine, one folder. No hooks, no shared repo, no automation. Candidates accumulate locally; review them at your own pace per `ADVISORY.md`.

---

## Repo contents

- `.claude/skills/skill-prompt-reminder/SKILL.md` — the skill
- `staging/candidates/TEMPLATE.md` — the candidate shape (reference)
- `ADVISORY.md` — quality bar and review conventions
- `install.sh` — one-liner installer
- `TODO.md` — planned stages and deferred work

---

## Installing

One-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/dalandro/skill-swindler/main/install.sh | bash
```

Or inspect the script before running it:

```sh
curl -fsSL https://raw.githubusercontent.com/dalandro/skill-swindler/main/install.sh
```

Then read `ADVISORY.md` once so you know the quality bar. Candidates land in `~/.skill-harvest/staging/candidates/` (the skill creates the directory on first write).

---

## What this is not

- It does not watch sessions in real time or send data anywhere.
- It does not auto-extract; it asks once and only writes on yes.
- It is not a replacement for deliberate skill authorship — hand-written skills for complex, nuanced patterns will always be higher quality. This system finds the patterns worth writing those skills about.
