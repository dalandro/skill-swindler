# TODO

Planned work not yet built. The README describes what exists today; this file describes what comes next and the design rationale we want to preserve while we get there.

---

## Roadmap

The system is designed to be built incrementally. Each stage works on its own. Later stages add capability without breaking what came before. Stage 1 ships in the README; the rest are below.

### Stage 2 — Shared repo, manual sync

**Goal:** get a second engineer using the same skills.

Create the shared GitHub repository. Push your local staging area and live skills to it. Other engineers install the skill-swindler skill and point it at their own local staging folder. Each person manually opens a PR when they want to contribute candidates.

No aggregator yet. No automated promotion. Just a shared place where the team can see each other's candidates and pull live skills. This is enough to validate whether the patterns actually transfer between engineers.

### Stage 3 — Automated aggregation and promotion

**Goal:** close the loop so the system can promote patterns without human coordination.

Add the nightly aggregator agent. It reads candidate files from all connected engineers, clusters similar patterns, and opens a summary PR when a pattern crosses the promotion threshold (appears in 3+ sessions across 2+ engineers). Review and merge is still human, but the legwork of comparison and clustering is automated.

This is where the system starts to feel self-sustaining.

### Stage 4 — Feedback loop and quality scoring

**Goal:** have the system learn which skills are actually being used and which are dead weight.

Track skill usage through session hooks. Skills that are called frequently and whose outputs are accepted without correction score high. Skills that are rarely triggered or whose suggestions are frequently overridden score low and are flagged for review or retirement.

The advisory updates to reflect empirical quality data rather than just guidelines.

---

## Optional extension — automatic post-session capture (any time)

**Goal:** capture candidates from sessions where skill-swindler didn't fire.

Today the system relies on Claude noticing a repeatable pattern mid-session and asking the user. That's high-quality (a human says yes in context) but it depends on the in-session heuristic firing. A passive post-session hook could pick up patterns skill-swindler missed.

Shape: a Claude Code post-session hook fires when a session ends, sends the transcript to an extractor agent, and the agent writes pattern candidates to the local staging area without prompting.

This is decoupled from the staged roadmap on purpose. Try it once you've spent time with Stage 1 candidates and have a feel for whether silent automated capture is worth the noise.

**Design tensions to resolve before building it:**

- The auto-extractor and skill-swindler both see the same sessions. Without dedup, you get duplicate candidates for the same pattern in the same session.
- Auto-extracted candidates are lower quality (no human gate) than skill-swindler ones. The candidate frontmatter would need a `source:` field (`skill-swindler` vs `extractor`) so the Stage 3 aggregator can weight provenance.
- The extractor benefits from a watchlist (a seeded file of known repeat patterns it should bias toward). Skill-swindler doesn't need one — the human is the watchlist. So the watchlist arrives with this extension, not before.

**Components this extension would add:**

- **Session hook.** A Claude Code post-session hook that triggers when a session ends and sends the transcript to the extractor.
- **Extractor agent.** A Claude agent with a focused prompt: strip out conversation noise, dead ends, and one-off questions; identify direct sequences of actions that solved a concrete problem; write candidates to staging.
- **Manual watchlist.** A seeded file (`watchlist.yml`) listing known repeat patterns the extractor should actively look out for. Examples of seeds: feature configuration setting, GraphQL field creation, package upgrade sequence, database migration, API endpoint scaffolding, deployment env var changes.

---

## Components to build

### History search tool
A tool that scans past Claude session transcripts and surfaces skill candidates that were never captured — either because skill-swindler didn't fire or the session predates the skill. Takes the same extraction logic as the auto-extractor but runs on-demand against the full local history rather than hooking into session end.

### Shared staging repo (Stage 2)
A shared GitHub repository where candidate patterns accumulate across engineers. Each candidate carries the pattern itself, source sessions, contributing engineers, frequency count, and timestamps.

### Aggregator agent (Stage 3)
Reads candidate files from all connected engineers, clusters similar patterns, and opens a summary PR when patterns cross the promotion threshold.

---

## Distribution

- **Plugin marketplace.** Adopt the Claude Code plugin marketplace pattern (a `.claude-plugin/marketplace.json` manifest + `claude plugin install`) once the skill set grows beyond one or there is a real external audience. Stage 1 ships a curl-pipe-bash install script; the marketplace adds idiomatic install, auto-updates, and discoverability at the cost of more packaging concepts.

---

## Possible rename — skill itself to `skill-harvest`

Today the only installed skill is named `skill-swindler`, matching the project. As more components land (auto-extractor, aggregator, watchlist tooling), `skill-swindler` is better suited as the umbrella project name and each component should get its own name. The current in-session skill would likely be renamed to `skill-harvest` to reflect its specific role (gathering candidate patterns) and to leave room for sibling skills under the same project.

Defer until there are actually multiple components — renaming once is cheaper than renaming twice.

---

## Design notes

### Data quality

Session data from Claude Code interactions is significantly richer than scraping git history.

**Git history gives you:** what changed, when, by whom.

**Session data gives you:** the full sequence of actions taken to get there — which CLI commands were run, in what order, what Claude was asked, what was corrected, what was accepted. The developer-AI interaction captures the *process*, not just the *outcome*.

Git history scraping is a useful secondary signal (and can bootstrap the watchlist with patterns that are already in the codebase) but it is a different and lower quality data source than live session capture.

The hard problem for any automated extractor is filtering. Raw session transcripts contain a lot of noise: exploratory questions, false starts, conversation, debugging tangents. The extractor agent's job is to collapse these into direct action sequences — the minimum set of steps that would reproduce the outcome.

### Team setup (Stage 2+)

Each engineer installs the skill-swindler skill locally. At Stage 2, candidates are pushed to a shared repo by hand. At Stage 3, an aggregator runs nightly and opens a summary PR when new candidates cross the threshold.

**Threshold for promotion to candidate:** pattern appears in 3+ sessions across 2+ engineers.

**Promotion to live skill:** team review + merge.

Engineers on the team:
- Alex — GraphQL fields, API layer
- Theo — feature configuration settings
- Nadia — feature configuration settings
- Ravi — GraphQL fields
- Marcus — package upgrades

These overlapping domains are exactly the areas the watchlist should seed first if and when the optional auto-extractor is built.
