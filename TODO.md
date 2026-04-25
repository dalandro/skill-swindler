# TODO

Planned work not yet built. The README describes what exists today; this file describes what comes next and the design rationale we want to preserve while we get there.

---

## Roadmap

The system is designed to be built incrementally. Each stage works on its own. Later stages add capability without breaking what came before. Stage 1 ships in the README; the rest are below.

### Stage 2 — Single machine, automated capture

**Goal:** remove the need to remember to extract manually.

Add the post-session hook. The extractor agent runs automatically after every session, writing pattern candidates to the local staging area without prompting. The Skill Prompt Reminder continues to run alongside it for high-confidence, in-context extractions. The watchlist arrives at this stage too — the automated extractor needs something to bias toward, where the prompt-reminder relied on a human in context.

Still one engineer, one machine. The difference is that the system is now watching passively rather than depending on you to notice.

### Stage 3 — Shared repo, manual sync

**Goal:** get a second engineer using the same skills.

Create the shared GitHub repository. Push your local staging area and live skills to it. Other engineers clone it and install the hook pointing to their own local staging folder. Each person manually opens a PR when they want to contribute candidates.

No aggregator yet. No automated promotion. Just a shared place where the team can see each other's candidates and pull live skills. This is enough to validate whether the patterns actually transfer between engineers.

### Stage 4 — Automated aggregation and promotion

**Goal:** close the loop so the system can promote patterns without human coordination.

Add the nightly aggregator agent. It reads candidate files from all connected engineers, clusters similar patterns, and opens a summary PR when a pattern crosses the promotion threshold (appears in 3+ sessions across 2+ engineers). Review and merge is still human, but the legwork of comparison and clustering is automated.

This is where the system starts to feel self-sustaining.

### Stage 5 — Feedback loop and quality scoring

**Goal:** have the system learn which skills are actually being used and which are dead weight.

Track skill usage through session hooks. Skills that are called frequently and whose outputs are accepted without correction score high. Skills that are rarely triggered or whose suggestions are frequently overridden score low and are flagged for review or retirement.

The advisory updates to reflect empirical quality data rather than just guidelines. The watchlist can be pruned based on which seeded patterns have produced useful live skills and which have not.

---

## Components to build

### Session hook (Stage 2)
A Claude Code post-session hook that triggers automatically when a session ends. Sends the session transcript to an extractor agent.

### Extractor agent (Stage 2)
A Claude agent with a focused prompt: strip out conversation noise, dead ends, and one-off questions. Identify direct sequences of actions — CLI commands, file edits, tool calls — that solved a concrete problem. Write these as candidate patterns to the local staging area.

### Manual watchlist (Stage 2)
A seeded file (`watchlist.yml`) listing known repeat patterns the extractor should actively look out for. Primes the automated system before it has enough session history to find patterns on its own. Examples of seeds:

- Feature configuration setting
- GraphQL field creation (mutation + resolver + type)
- Package upgrade sequence (lockfile + tests)
- Database migration generation and rollback
- API endpoint scaffolding
- Deployment environment variable changes

The watchlist is maintained by the team and grows as new repeat patterns are identified. Patterns that surface repeatedly through the prompt reminder are strong candidates for seeding.

### Shared staging repo (Stage 3)
A shared GitHub repository where candidate patterns accumulate across engineers. Each candidate carries the pattern itself, source sessions, contributing engineers, frequency count, and timestamps of first and most recent occurrence.

### Aggregator agent (Stage 4)
Reads candidate files from all connected engineers, clusters similar patterns, and opens a summary PR when patterns cross the promotion threshold.

---

## Distribution

- **Plugin marketplace.** Adopt the Claude Code plugin marketplace pattern (a `.claude-plugin/marketplace.json` manifest + `claude plugin install`) once the skill set grows beyond one or there is a real external audience. Stage 1 ships a curl-pipe-bash install script; the marketplace adds idiomatic install, auto-updates, and discoverability at the cost of more packaging concepts.

---

## Design notes

### Data quality

Session data from Claude Code interactions is significantly richer than scraping git history.

**Git history gives you:** what changed, when, by whom.

**Session data gives you:** the full sequence of actions taken to get there — which CLI commands were run, in what order, what Claude was asked, what was corrected, what was accepted. The developer-AI interaction captures the *process*, not just the *outcome*.

Git history scraping is a useful secondary signal (and can bootstrap the watchlist with patterns that are already in the codebase) but it is a different and lower quality data source than live session capture.

The hard problem is filtering. Raw session transcripts contain a lot of noise: exploratory questions, false starts, conversation, debugging tangents. The extractor agent's job is to collapse these into direct action sequences — the minimum set of steps that would reproduce the outcome.

### Team setup (Stage 3+)

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
