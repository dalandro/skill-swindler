# Skill Swindler

A passive background system that watches Claude Code sessions across a team of engineers, extracts repeatable patterns, and promotes them into shared, reusable skills — without anyone having to think about it.

---

## The Problem

Repeatable work happens constantly and invisibly. One engineer configures a feature setting, another does the same thing a week later. Someone writes a GraphQL field, three others write near-identical ones. A package upgrade gets done twice with the same sequence of steps. Each time, the engineer either rediscovers the pattern alone or asks Claude to help from scratch.

The knowledge exists. It just never crystallises into something the whole team can use.

---

## What This Does

Skill Harvest runs in the background during Claude Code sessions. It watches what Claude is actually being asked to do — the CLI commands, the file patterns, the combinations of tool calls — and quietly accumulates evidence of repeatable work. When a pattern appears across enough sessions and enough engineers, it gets promoted to a staging area as a skill candidate.

Nobody has to think about it. The system watches so you don't have to.

---

## How It Works

```
Claude Code session runs
    ↓
Post-session hook fires
    ↓
Extractor agent reads session transcript
    ↓
Filters signal from noise (questions, dead ends, retries removed)
    ↓
Extracted patterns written to local staging area
    ↓
Nightly aggregator compares patterns across engineers
    ↓
Patterns meeting threshold → promoted to skill candidates in shared repo
    ↓
Team pulls, reviews, and promotes candidates to live skills
```

---

## Components

### 1. Session Hook
A Claude Code post-session hook that triggers automatically when a session ends. Sends the session transcript to an extractor agent.

### 2. Extractor Agent
A Claude agent with a focused prompt: strip out conversation noise, dead ends, and one-off questions. Identify direct sequences of actions — CLI commands, file edits, tool calls — that solved a concrete problem. Write these as candidate patterns to a local `.skill-harvest/staging/` directory.

### 3. Staging Area
A shared GitHub repository (personal account) where candidate patterns accumulate. Each candidate includes:
- The pattern itself (what was done)
- Source sessions and contributing engineers
- Frequency count
- Timestamp of first and most recent occurrence

Engineers can review candidates, annotate them, and vote to promote or discard.

### 4. Manual Watchlist
A seeded file (`watchlist.yml`) listing known repeat patterns the extractor should actively look out for. This primes the system before it has enough session history to find patterns on its own.

Examples of seeds:
- Feature configuration setting
- GraphQL field creation (mutation + resolver + type)
- Package upgrade sequence (lockfile + tests)
- Database migration generation and rollback
- API endpoint scaffolding
- Deployment environment variable changes

The watchlist is maintained by the team and grows over time as new repeat patterns are identified manually.

### 5. Advisory
A living document in the repo (`ADVISORY.md`) that describes:
- What makes a good skill candidate vs noise
- How to annotate and promote candidates
- How to write a watchlist entry
- Quality bar for promotion to live skills

This exists so the system has consistent human judgment applied to it, not just automation.

### 6. Skill Prompt Reminder (Side Project)

A lightweight companion skill that runs independently of the automated pipeline. At the end of certain Claude Code interactions — particularly ones involving unfamiliar file patterns, multi-step tool sequences, or problems that took several attempts to resolve — Claude asks a single question:

> "That felt like a repeatable pattern. Would you like to extract it as a skill candidate?"

If yes, Claude writes a draft candidate directly to the local staging area, pre-annotated with what the pattern does and why it might recur. The engineer can edit or discard it immediately.

This is deliberately low-tech. It requires no hooks, no automation, no session history — just a skill file and a habit. It is the fastest way to start generating quality candidates because the engineer is still in context, knows what just happened, and can provide the signal directly. Candidates produced this way tend to be higher quality than anything extracted automatically, because a human judged them worthy at the moment of creation.

This side project also serves as a training mechanism for the watchlist: patterns that surface repeatedly through the prompt reminder are strong candidates for seeding into `watchlist.yml` so the automated system learns to recognise them passively.

---

## Data Quality

Session data from Claude Code interactions is significantly richer than scraping git history.

**Git history gives you:** what changed, when, by whom.

**Session data gives you:** the full sequence of actions taken to get there — which CLI commands were run, in what order, what Claude was asked, what was corrected, what was accepted. The developer-AI interaction captures the *process*, not just the *outcome*.

Git history scraping is a useful secondary signal (and can bootstrap the watchlist with patterns that are already in the codebase) but it is a different and lower quality data source than live session capture.

The hard problem is filtering. Raw session transcripts contain a lot of noise: exploratory questions, false starts, conversation, debugging tangents. The extractor agent's job is to collapse these into direct action sequences — the minimum set of steps that would reproduce the outcome.

---

## Team Setup

Each engineer installs the session hook locally. All hooks point to the shared staging repo. The aggregator runs nightly and opens a summary PR when new candidates cross the threshold.

**Threshold for promotion to candidate:** pattern appears in 3+ sessions across 2+ engineers.

**Promotion to live skill:** team review + merge.

Engineers on the team:
- Alex — GraphQL fields, API layer
- Theo — feature configuration settings
- Nadia — feature configuration settings
- Ravi — GraphQL fields
- Marcus — package upgrades

These overlapping domains are exactly the areas the watchlist should seed first.

---

## What This Is Not

- It does not watch sessions in real time or send data anywhere mid-session.
- It does not require engineers to tag or annotate their sessions manually.
- It is not a replacement for deliberate skill authorship — hand-written skills for complex, nuanced patterns will always be higher quality. This system finds the patterns worth writing those skills about.

---

## Repo Structure

```
skill-harvest/
├── README.md
├── ADVISORY.md
├── watchlist.yml
├── staging/
│   └── candidates/          # Promoted pattern candidates
├── skills/
│   └── live/                # Graduated, live skills
├── hooks/
│   └── post-session.sh      # Hook script for local install
└── agents/
    ├── extractor.md          # Extractor agent prompt
    └── aggregator.md         # Aggregator agent prompt
```

---

## Development Stages

The system is designed to be built incrementally. Each stage works on its own. Later stages add capability without breaking what came before.

---

### Stage 1 — Single machine, manual

**Goal:** prove the concept without building any infrastructure.

Install the Skill Prompt Reminder skill. At the end of sessions where something felt repeatable, Claude asks whether to extract a candidate. Write candidates to a local folder by hand. Seed the watchlist manually with patterns you already know exist.

This stage is just one person, one machine, one folder. No automation. No hooks. No repo. But by the end of it you have a small collection of real candidates and a clearer sense of what a good skill looks like in practice.

---

### Stage 2 — Single machine, automated capture

**Goal:** remove the need to remember to extract manually.

Add the post-session hook. The extractor agent now runs automatically after every session, writing pattern candidates to the local staging area without prompting. The Skill Prompt Reminder continues to run alongside it for high-confidence, in-context extractions. The watchlist arrives at this stage too — the automated extractor needs something to bias toward, where the prompt-reminder relied on a human in context.

Still one engineer, one machine. The difference is that the system is now watching passively rather than depending on you to notice.

---

### Stage 3 — Shared repo, manual sync

**Goal:** get a second engineer using the same skills.

Create the shared GitHub repository. Push your local staging area and live skills to it. Other engineers clone it and install the hook pointing to their own local staging folder. Each person manually opens a PR when they want to contribute candidates.

No aggregator yet. No automated promotion. Just a shared place where the team can see each other's candidates and pull live skills. This is enough to validate whether the patterns actually transfer between engineers.

---

### Stage 4 — Automated aggregation and promotion

**Goal:** close the loop so the system can promote patterns without human coordination.

Add the nightly aggregator agent. It reads candidate files from all connected engineers, clusters similar patterns, and opens a summary PR when a pattern crosses the promotion threshold (appears in enough sessions across enough engineers). Review and merge is still human, but the legwork of comparison and clustering is automated.

This is where the system starts to feel self-sustaining.

---

### Stage 5 — Feedback loop and quality scoring

**Goal:** have the system learn which skills are actually being used and which are dead weight.

Track skill usage through session hooks. Skills that are called frequently and whose outputs are accepted without correction score high. Skills that are rarely triggered or whose suggestions are frequently overridden score low and are flagged for review or retirement.

The advisory updates to reflect empirical quality data rather than just guidelines. The watchlist can be pruned based on which seeded patterns have produced useful live skills and which have not.

---

## Status

**Stage 1 — in progress.** The Skill Prompt Reminder is implemented. No hooks, no automation, no shared repo yet.

## Installing Stage 1 (single engineer, one machine)

One-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/dalandro/skill-swindler/main/install.sh | bash
```

Or inspect the script before running it:

```sh
curl -fsSL https://raw.githubusercontent.com/dalandro/skill-swindler/main/install.sh
```

Then read `ADVISORY.md` once so you know the quality bar. Candidates land in `~/.skill-harvest/staging/candidates/` (the skill creates the directory on first write). At the end of sessions involving multi-step work, Claude will ask once whether to extract a candidate. Say yes and a file lands in your staging folder; review it later per the advisory.
