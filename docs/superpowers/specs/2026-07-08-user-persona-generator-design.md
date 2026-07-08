# User Persona Generator — Design

Date: 2026-07-08
Status: Draft — awaiting Craig's approval
Author: Claude (brainstormed from Craig's brief)

## Problem

Startups struggle to recruit real users for UX testing. This plugin lets a tester generate
research-grade user personas, have those personas actually operate the app under test in a
real browser (clicking, typing, thinking aloud), and receive an actionable findings report —
simulated usability testing from a specific user's point of view.

## Scope decision

The full vision is three subsystems, designed together, built in order:

| # | Subsystem | This cycle? |
|---|-----------|-------------|
| 1 | **Persona Generator** — interview → persona profile | **Yes — build now** |
| 2 | **Persona Runner** — persona drives the app via browser automation, thinks aloud, can pause to ask the tester questions | Designed here, built next cycle |
| 3 | **Findings Reporter** — session transcript → severity-ranked findings | Designed here, built after the runner |

Designing all three now guarantees the persona file format carries everything the runner and
reporter need, so nothing gets rebuilt later.

## Approaches considered

**A. One plugin; personas are data files + a parameterized agent (RECOMMENDED)**
A single `user-persona-generator` plugin exposes three skills (`create-persona`,
`run-persona-test`, `persona-findings`). Each generated persona is a structured markdown file
saved into the tested project. The runner is one generic "persona tester" agent that reads a
persona file and embodies it.
*Pros:* one install; personas are portable, human-editable, git-versionable; runner logic
lives in one place so fixes apply to every persona. *Cons:* personas aren't literally
"plugins" as the brief worded it.

**B. Generator scaffolds a new plugin per persona (literal reading of the brief)**
*Pros:* matches the original wording; personas installable independently.
*Cons:* every persona duplicates runner logic (bug fixes require regenerating every persona);
marketplace/install churn per persona; much heavier to build and maintain. The plugin
machinery adds cost without adding capability — a persona is data, not behavior.

**C. No plugin — drop skills into each tested app's repo**
*Pros:* simplest possible start. *Cons:* no reuse across projects; contradicts the goal of
shipping something other teams can install.

**Recommendation: A.** It delivers everything B delivers from the persona's point of view,
with one codebase to maintain. If a "shareable persona pack" is ever needed, an export skill
can be added later without redesign.

## Architecture (Approach A)

```
plugins/user-persona-generator/
  .claude-plugin/plugin.json
  README.md
  skills/
    create-persona/
      SKILL.md                      # the interview (THIS CYCLE)
      references/persona-template.md
    run-persona-test/SKILL.md       # next cycle
    persona-findings/SKILL.md       # after runner
  agents/
    persona-tester.md               # generic agent the runner parameterizes (next cycle)
```

Registered in the existing `cthomas-plugins` marketplace (`.claude-plugin/marketplace.json`).

### Data the plugin writes into the tested app's project

```
ux-testing/
  app-profile.md                    # about the app under test (asked once, reused)
  personas/<slug>.md                # one file per persona
  sessions/<date>-<persona>-<task>/
    transcript.md                   # timestamped think-aloud + actions
    findings.md                     # the actionable report
    screenshots/
```

Personas live with the tested app (not inside the plugin) so they're versioned with the
project and reusable across sessions.

## Subsystem 1 — Persona Generator (`/create-persona`) — built this cycle

Follows the interview conventions already proven in `job-search-copilot:career-profile-setup`:
batch related questions with AskUserQuestion, infer before asking, never interrogate
one field at a time.

**Phase 1 — App context (skipped if `ux-testing/app-profile.md` exists):**
- What the app does, domain, primary user segments
- Platform: browser-based or native. **v1 supports browser-based only** — the runner uses
  Playwright. If native, the skill says so up front and still generates the persona (usable
  for manual testing), flagging the runner limitation.
- Test environment URL(s)
- Access/credentials approach (see Security below — names of env vars or "warm session";
  never secret values)

**Phase 2 — Persona construction. Two modes:**
- **Guided:** batched questions walking the five core elements (below)
- **Quick-draft:** tester gives a one-liner ("62-year-old retired teacher, low tech
  confidence, first time filing online") → Claude drafts the complete persona → tester
  reviews and edits. Fastest path; expected default.

**Persona file schema** (fixed sections so runner/reporter can parse reliably):
1. **Humanizers** — name, defining first-person quote. (Fictional photo: v1 emits a text
   appearance sketch only; image generation is a later nice-to-have.)
2. **Demographics & background** — age, education, marital status; job title, industry,
   income band
3. **Environment** — devices, tech proficiency (1–5 with concrete anchors), physical/social
   context (busy office, commuting, home)
4. **Goals & motivations** — primary objective, what drives them
5. **Pain points & frustrations** — current challenges, friction with existing solutions
6. **Behaviors & habits** *(bonus)* — where they get information, comparable products used
7. **Job requirements / KPIs** *(bonus, B2B)* — how their performance is measured
8. **Behavioral directives** *(the key addition that makes the persona runnable)* — traits
   translated into concrete testing behavior the runner obeys, e.g.:
   - Reading style: skims vs. reads every label
   - Scroll/explore tendency: won't look below the fold unless cued
   - Patience budget: abandons after N failed attempts on the same step
   - Jargon tolerance: which terms confuse them
   - Help-seeking: hunts for a help link vs. gives up vs. asks the moderator
9. **Runner config** — start URL, device/viewport, credential reference (name only)

**Validation before saving:** internal consistency check (proficiency vs. behaviors vs.
occupation), no invented specifics beyond what the tester approved, no secrets present.

## Subsystem 2 — Persona Runner (`/run-persona-test`) — next cycle (design only)

- Tester picks a persona + assigns a task in plain language ("find and book the cheapest
  Tuesday appointment") + confirms start URL.
- **Pre-flight:** app reachable; credentials resolved (env var or tester logs in first —
  "warm session"); reminder to start screen recording (the browser runs visibly via the
  Playwright MCP already installed, so the tester can watch and record).
- Spawns the `persona-tester` agent with the persona file + task. The agent:
  - **Thinks aloud in first person as the persona** before and after each action; every
    utterance and action is timestamped into `transcript.md`, with screenshots at key moments
  - **Stays in character:** acts at the persona's proficiency, never uses developer knowledge
    (no reading DOM/console to figure out the UI), gets confused where the persona would,
    and abandons when the persona's patience budget is spent — an abandonment is a finding,
    not a failure of the run
  - **Pauses to ask the tester questions** (AskUserQuestion) exactly like a participant
    asking the moderator — when blocked by something outside the test (e.g., a CAPTCHA, a
    dead test environment), not to get hints
- Ends by handing the transcript to the Findings Reporter.

## Subsystem 3 — Findings Reporter (`/persona-findings`) — after runner (design only)

- Input: one session transcript (auto-run at end of a session) or several (cross-persona
  synthesis)
- Output `findings.md`: task outcome (success / partial / abandoned + where), findings ranked
  blocker → major → minor → nitpick, each with evidence (verbatim think-aloud quote +
  screenshot reference + step in flow), and a recommendation per finding
- Findings describe the user experience, not code fixes — it reports "the persona couldn't
  find checkout because the cart icon has no label," not CSS patches

## Security & safety

- **No secrets in any generated file.** Credential handling is by reference only: env-var
  names, or the warm-session pattern (tester authenticates manually, persona takes over).
  The generator refuses to write a password/token if the tester pastes one, and says why.
- Runner only navigates within the app under test's origin(s) listed in `app-profile.md`.
- Runner never performs destructive or externally visible actions (payments, sending emails,
  deleting records) without pausing to confirm with the tester first.

## Error handling

- App unreachable / login fails → stop, report exactly what happened, don't improvise
- Persona genuinely stuck in-character → that's data: log it, let the persona behave
  per its patience budget, surface it as a finding
- Interview interrupted → partial persona saved as `<slug>.draft.md`, resumable

## Out of scope (v1)

- Native (non-browser) app driving — persona generation still works; runner is browser-only
- Generated persona photos (text appearance sketch instead)
- Audio/video think-aloud (text transcript + tester's own screen recording covers it)
- Multi-persona parallel sessions

## Verification for this cycle

1. Plugin loads: appears in `/plugin` list after marketplace refresh
2. `/create-persona` quick-draft mode produces a persona file matching the schema above
3. Guided mode covers all nine sections without asking one-field-at-a-time
4. Attempting to give the interview a real password → refused, warm-session offered
5. Re-running with an existing `app-profile.md` skips Phase 1

## Cycle 2 decisions (accepted by Craig, 2026-07-08)

- **Inline execution:** the persona session runs in the main conversation, not a
  subagent — think-aloud streams live so the tester can watch/record, and the
  persona can pause with AskUserQuestion. Tradeoff accepted: long sessions use
  more context.
- **Browser tooling:** the plugin ships a root `.mcp.json` declaring the
  Playwright MCP server (`@playwright/mcp`), so installing the plugin brings the
  browser-driving capability with it. Playwright's visible browser window is the
  watch/record surface.
- **Session caps:** default hard caps of 20 minutes wall-clock or 60 browser
  actions, whichever comes first (overridable when starting a session). The
  persona's own patience budget usually ends sessions earlier — the cap is a
  cost backstop, and hitting it is recorded in the transcript as
  "session ended by cap", never dressed up as a persona decision.
- **Warm session flow:** the runner opens the start URL, then pauses and asks
  the tester to log in directly in the browser window; the persona takes over
  only after the tester confirms. Credential values never pass through chat.
- **Transcript format:** `transcript.md` per session with a header block
  (persona, task, start URL, caps) and timestamped entries; each entry is a
  think-aloud utterance, an action, or a moderator exchange. Screenshots saved
  to `screenshots/` at task milestones, confusion moments, and abandonment.
- **First acceptance target:** persona `gary-job-novice` (proficiency-2,
  first-time job seeker) against https://www.indeed.com/ with Craig's account
  via warm session. "Apply for a job" is on the confirm-first guardrail list.

## Build order

1. **This cycle:** plugin scaffold + `create-persona` skill + marketplace registration
2. **Next:** `persona-tester` agent + `run-persona-test` skill (Playwright-driven)
3. **Then:** `persona-findings` skill
4. **Later ideas (parked):** persona photo generation, persona export packs, native app
   support via computer use, comparative multi-persona reports
