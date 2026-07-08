# User Persona Generator — Cycle 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the `user-persona-generator` plugin scaffold with a working `create-persona` skill, registered in the `cthomas-plugins` marketplace.

**Architecture:** One plugin following the `job-search-copilot` conventions: `.claude-plugin/plugin.json` manifest, one `skills/<name>/SKILL.md` per skill with `references/` templates. Personas are structured markdown written into the *tested app's* project (`ux-testing/`), not into the plugin. Spec: `docs/superpowers/specs/2026-07-08-user-persona-generator-design.md`.

**Tech Stack:** Claude Code plugin (markdown skills + JSON manifests). No runtime code this cycle.

## Global Constraints

- Plugin directory: `plugins/user-persona-generator/` (already exists, empty)
- Version everywhere: `0.1.0`
- Author: `{"name": "Craig"}` (match sibling plugin exactly)
- No secrets may ever appear in generated files; skill must refuse pasted credentials
- v1 test-running is browser-only; the skill must say so when the app is native
- Commits go through the `/commit` skill (per Craig's CLAUDE.md), one commit per task
- All JSON must parse (verify with PowerShell `ConvertFrom-Json`)

---

### Task 1: Plugin manifest and README

**Files:**
- Create: `plugins/user-persona-generator/.claude-plugin/plugin.json`
- Create: `plugins/user-persona-generator/README.md`

**Interfaces:**
- Produces: plugin name `user-persona-generator` v `0.1.0` — Task 4's marketplace entry must match both exactly.

- [ ] **Step 1: Write plugin.json**

```json
{
  "name": "user-persona-generator",
  "version": "0.1.0",
  "description": "Generate research-grade user personas for simulated UX testing: interview-based persona creation today; browser-driving test sessions with think-aloud transcripts and severity-ranked findings reports in upcoming versions.",
  "author": {
    "name": "Craig"
  },
  "keywords": ["ux", "usability-testing", "personas", "user-research", "ux-testing"]
}
```

- [ ] **Step 2: Write README.md**

```markdown
# User Persona Generator

Simulated UX testing for teams that can't recruit real users. Generate
research-grade personas, then (in upcoming versions) watch them drive your
app in a real browser — clicking, typing, thinking aloud — and hand you a
severity-ranked findings report.

## Skills

| Skill | Status | What it does |
|-------|--------|--------------|
| `create-persona` | ✅ v0.1.0 | Interviews you about your app and target user, writes a runnable persona file |
| `run-persona-test` | 🔜 planned | Persona drives the app via Playwright, thinks aloud, logs a timestamped transcript |
| `persona-findings` | 🔜 planned | Turns session transcripts into a severity-ranked findings report |

## How it works

1. Run `create-persona` inside the project of the app you want tested.
2. First run captures an **app profile** (what the app does, test URLs,
   access approach) — asked once, reused by every persona.
3. Build the persona **quick-draft** (one-line description, Claude drafts
   the rest for your review) or **guided** (structured interview).
4. Personas land in `ux-testing/personas/<slug>.md` in your project —
   versionable, human-editable, reusable.

## What's in a persona

The five research-standard elements (humanizers, demographics, environment,
goals & motivations, pain points) plus behaviors/habits and B2B KPIs — and a
**Behavioral directives** section that translates traits into concrete,
runnable testing behavior (patience budget, reading style, jargon tolerance,
help-seeking style).

## Security

- Credential **values** are never written to any file. Access is by
  env-var name or a "warm session" (you log in, the persona takes over).
- Personas only navigate origins listed in the app profile.

## Limitations (v0.1.0)

- Test runs will be **browser-based apps only** (Playwright). Personas for
  native apps can still be generated and used for manual testing.
- Persona photos: text appearance sketch only.
```

- [ ] **Step 3: Verify JSON parses**

Run: `powershell -Command "Get-Content 'plugins/user-persona-generator/.claude-plugin/plugin.json' -Raw | ConvertFrom-Json | Select-Object name, version"`
Expected: table showing `user-persona-generator  0.1.0`

- [ ] **Step 4: Commit via /commit skill**

Suggested message: `feat(user-persona-generator): scaffold plugin manifest and README`

---

### Task 2: Persona and app-profile templates

**Files:**
- Create: `plugins/user-persona-generator/skills/create-persona/references/persona-template.md`
- Create: `plugins/user-persona-generator/skills/create-persona/references/app-profile-template.md`

**Interfaces:**
- Produces: the exact heading structure Task 3's SKILL.md instructs Claude to follow, and that future `run-persona-test` / `persona-findings` skills will parse. Headings are load-bearing — do not rename them later without updating all consumers.

- [ ] **Step 1: Write persona-template.md**

```markdown
# Persona Template

Copy this structure exactly when writing `ux-testing/personas/<slug>.md`.
Headings are parsed by other skills — keep them verbatim. Replace guidance
text (in parentheses) with real content; delete section 7 for consumer apps.

---

# Persona: {Full Name}

Created: {YYYY-MM-DD}
Status: active

> "{Defining quote — first person, captures their mindset, frustration, or
> goal. e.g., 'I just want to file this without feeling stupid.'}"

## 1. Humanizers

- **Name:** {realistic full name}
- **Appearance sketch:** {2-3 sentences a reader can picture — stands in
  for a photo}

## 2. Demographics & Background

- **Age:** {number}
- **Education:** {highest level}
- **Marital/family status:** {status}
- **Job title:** {title, or "retired {former role}", "student", etc.}
- **Industry:** {industry}
- **Income band:** {e.g., $40–60k}

## 3. Environment

- **Devices:** {e.g., 6-year-old Windows laptop; iPhone 12 for everything else}
- **Tech proficiency:** {1–5} — {anchor}
  (Anchors: 1 = struggles with email attachments; 2 = comfortable with
  familiar apps only; 3 = adapts to new apps with some friction; 4 = picks
  up new tools quickly; 5 = power user, keyboard shortcuts, reads docs)
- **Physical/social context:** {where and when they'd use this app —
  e.g., kitchen table after dinner, interrupted often}

## 4. Goals & Motivations

- **Primary objective:** {the problem they're actively trying to solve
  with this app}
- **Motivations:** {what drives them — time, money, health, obligation,
  fear of getting it wrong}
- **Success looks like:** {one sentence in their words}

## 5. Pain Points & Frustrations

- **Current challenges:** {obstacles that keep them from the goal today}
- **Friction with existing solutions:** {what annoys them about how they
  do this now}

## 6. Behaviors & Habits

- **Information sources:** {where they'd look for help — Google, a
  relative, YouTube, official docs, nowhere}
- **Comparable products used:** {apps/services they already know — these
  set their expectations for how yours "should" work}

## 7. Job Requirements / KPIs (B2B only — delete for consumer personas)

- **Measured on:** {the metrics their boss watches}
- **What failure costs them:** {professional stakes}

## 8. Behavioral Directives

(How the persona behaves during a test run. Every line must be observable
behavior an agent can act on, not a personality adjective.)

- **Reading style:** {reads every label | skims for keywords | reads only
  headings and buttons}
- **Exploration:** {clicks only obvious primary buttons | explores menus |
  won't scroll below the fold unless something cues them}
- **Patience budget:** abandons the current step after {N} failed attempts;
  abandons the whole task after {M} minutes of feeling lost
- **Jargon tolerance:** {terms that would confuse them, e.g., "sync",
  "dashboard", "authenticate"}
- **Error reaction:** {retries same thing | tries different path | blames
  self and stops | looks for help}
- **Help-seeking:** {looks for a help link/FAQ | asks the moderator |
  gives up silently}
- **Trust triggers:** {what makes them hesitate — popups, requests for
  personal info, anything that looks like an ad}

## 9. Runner Config

- **Start URL:** {URL the test session opens on}
- **Viewport:** {desktop 1280x800 | mobile 375x812 — match their primary
  device}
- **Access:** {warm-session | env vars: NAME_OF_USER_VAR, NAME_OF_PASS_VAR
  — names only, never values}
- **Never do without confirming:** {inherited from app profile — payments,
  emails, deletes}
```

- [ ] **Step 2: Write app-profile-template.md**

```markdown
# App Profile Template

Copy this structure exactly when writing `ux-testing/app-profile.md`.
Written once per project; every persona and test session reads it.

---

# App Profile: {App Name}

Last updated: {YYYY-MM-DD}

## What it does

{One paragraph: what the app does and for whom.}

## Domain

{e.g., consumer fintech, B2B logistics SaaS, healthcare scheduling}

## Primary user segments

- {segment 1}
- {segment 2}

## Platform

{browser | native-desktop | native-mobile}
{If native: "Note: v1 automated test runs are browser-only. Personas can
be used for manual testing."}

## Test environment

- **URLs / allowed origins:** {test-env URLs — personas must not navigate
  outside these origins}
- **Access approach:** {warm-session — tester logs in before the persona
  takes over | env vars: VAR_NAMES — names only, never values}

## Destructive-action guardrails

Actions a persona must never take without pausing to confirm with the
tester:
- {e.g., anything on a payment screen, sending invitations, deleting records}
```

- [ ] **Step 3: Verify heading structure**

Run: `powershell -Command "(Select-String -Path 'plugins/user-persona-generator/skills/create-persona/references/persona-template.md' -Pattern '^## \d').Count"`
Expected: `9`

- [ ] **Step 4: Commit via /commit skill**

Suggested message: `feat(user-persona-generator): add persona and app-profile templates`

---

### Task 3: create-persona SKILL.md

**Files:**
- Create: `plugins/user-persona-generator/skills/create-persona/SKILL.md`

**Interfaces:**
- Consumes: `references/persona-template.md` and `references/app-profile-template.md` from Task 2 (referenced by relative path).
- Produces: skill name `create-persona` — future skills will tell users to run it when no persona exists.

- [ ] **Step 1: Write SKILL.md**

```markdown
---
name: create-persona
description: >
  This skill should be used when the user wants to "create a persona",
  "generate a user persona", "set up a test persona", "make a simulated
  user for UX testing", or runs any user-persona-generator skill without
  an existing persona. It captures a profile of the app under test (once
  per project), then builds a research-grade, runnable persona file in
  ux-testing/personas/ that future test-run skills can embody in a live
  browser session.
metadata:
  version: "0.1.0"
---

# Create Persona

Build a persona rich enough that an agent can *become* this user: read like
them, click like them, get confused where they would, and give up when they
would. The output is a structured markdown file other skills parse — follow
the templates in `references/` exactly.

## Before starting

1. Check the project for `ux-testing/app-profile.md`. If it exists,
   summarize it in one sentence and skip Phase 1 unless the user says the
   app has changed.
2. Check `ux-testing/personas/` for existing personas. If any exist, list
   them and ask: create a new persona, or update an existing one? Updating
   loads the file and revisits only the sections the user names.
3. If a `*.draft.md` persona exists, offer to resume it before anything else.

## Phase 1 — App profile (once per project)

Collect conversationally — batch related questions with AskUserQuestion,
never interrogate one field at a time. If the working directory contains
the app's source or README, infer what you can first and ask only to
confirm.

Gather:

1. **What the app does** (a paragraph) and its **domain**
2. **Primary user segments**
3. **Platform** — browser-based or native. If native, say plainly:
   automated test runs are browser-only in v1; the persona is still fully
   usable for manual testing. Do not hide this until later.
4. **Test environment URL(s)** — these become the only origins a persona
   may navigate during a test run
5. **Access approach** — offer exactly two options:
   - *Warm session* (default, recommended): the tester logs in manually at
     the start of a test session, then hands control to the persona
   - *Env vars*: the names of environment variables holding test-account
     credentials. Names only — see Security rules.
6. **Destructive-action guardrails** — anything a persona must never do
   without pausing to confirm (payments, sending email/invites, deleting
   records)

Write `ux-testing/app-profile.md` following
`references/app-profile-template.md` exactly.

## Phase 2 — Persona construction

Offer two modes (default: quick-draft):

**Quick-draft** — the user gives a one-liner ("62-year-old retired teacher,
low tech confidence, first time filing taxes online"). Draft the complete
persona yourself — every template section — then present it for review and
revise until approved. Invented details are expected here, but nothing is
final until the user approves it.

**Guided** — walk these question groups, one AskUserQuestion batch per
group:

1. **Identity & background:** approximate age, education, occupation and
   industry, income band, family situation
2. **Tech & environment:** devices they own, tech proficiency 1–5 (read the
   anchors from the persona template aloud so the user picks accurately),
   where and when they'd realistically use this app
3. **Goals & motivations:** what they're trying to accomplish with the app,
   why it matters, what success looks like in their words
4. **Pain points:** how they solve this problem today, what annoys them
   about it
5. **KPIs (B2B personas only):** how their job performance is measured,
   what failure costs them. Skip entirely for consumer personas.
6. **Behavioral tendencies:** patient or quick to abandon? reads carefully
   or skims? explores freely or sticks to obvious paths? what do they do
   when something errors?

## Deriving behavioral directives

This section is what makes the persona runnable. Translate traits into
observable behavior an agent driving a browser can act on — never restate
demographics as adjectives. Guidance:

- Proficiency 1–2 → reads every label; hesitates before unfamiliar
  controls; will not discover hover menus, right-click menus, or keyboard
  shortcuts; distrusts popups and permission prompts
- Proficiency 4–5 → skims; reaches for search boxes; tries keyboard
  shortcuts; high jargon tolerance
- Busy or mobile context → small patience budget (2–3 failed attempts on a
  step); won't read paragraphs of text
- Domain expert but tech novice → knows the vocabulary, struggles with the
  widgets. State that split explicitly — it is the most common real-world
  pattern and the most commonly missed.

Always set a **concrete patience budget** (abandon step after N failed
attempts; abandon task after M minutes lost) and a **help-seeking
behavior** (help link / ask the moderator / quit silently).

## Output

Write `ux-testing/personas/<slug>.md` following
`references/persona-template.md` exactly — its headings are parsed by
other skills. Slug = first name + defining trait, kebab-case, e.g.
`martha-tax-novice`.

## Validation before saving

- **Consistency:** proficiency, occupation, environment, and behavioral
  directives must not contradict each other. If the user's answers
  conflict (a "5 — power user" who "can't find the settings menu"), point
  it out and resolve it with them rather than saving the contradiction.
- **Traceability:** every fact traces to the user's answers or to a
  quick-draft they approved. Never silently add or change details after
  approval.
- **No secrets:** see Security rules.
- Show the complete persona and get an explicit yes before writing the file.

## After saving

Confirm the file path. Suggest next steps: create a contrasting persona
(different proficiency or segment reveals different findings), or — once
`run-persona-test` ships — assign this persona its first task.

## Security rules (non-negotiable)

- Never write credential values (passwords, tokens, API keys, session
  cookies) into any file, including drafts. If the user pastes one, refuse
  it, explain that persona files are meant to be committed to the repo,
  and record either the env-var *name* or the warm-session approach
  instead.
- Personas only ever reference the allowed origins in the app profile.
- Personas are fictional composites. Refuse to model a persona on a named
  real, private person.

## Interruption handling

If the interview is interrupted before validation passes, save progress to
`ux-testing/personas/<slug>.draft.md` with a `Status: draft — missing:
{sections}` line under the title, and say how to resume.
```

- [ ] **Step 2: Verify frontmatter and required sections**

Run: `powershell -Command "(Select-String -Path 'plugins/user-persona-generator/skills/create-persona/SKILL.md' -Pattern '^## ').Line"`
Expected: lines for Before starting, Phase 1, Phase 2, Deriving behavioral directives, Output, Validation before saving, After saving, Security rules (non-negotiable), Interruption handling

- [ ] **Step 3: Commit via /commit skill**

Suggested message: `feat(user-persona-generator): add create-persona skill`

---

### Task 4: Marketplace registration

**Files:**
- Modify: `.claude-plugin/marketplace.json` (append to `plugins` array)

**Interfaces:**
- Consumes: plugin name/version from Task 1 — must match `plugin.json` exactly.

- [ ] **Step 1: Append the plugin entry**

Add to the `plugins` array (after the `job-search-copilot` entry):

```json
{
  "name": "user-persona-generator",
  "source": "./plugins/user-persona-generator",
  "description": "Generate research-grade user personas for simulated UX testing: interview-based persona creation today; browser-driving test sessions with think-aloud transcripts and severity-ranked findings reports in upcoming versions.",
  "version": "0.1.0",
  "author": {
    "name": "Craig"
  },
  "keywords": ["ux", "usability-testing", "personas", "user-research", "ux-testing"]
}
```

- [ ] **Step 2: Verify JSON parses and both plugins are listed**

Run: `powershell -Command "(Get-Content '.claude-plugin/marketplace.json' -Raw | ConvertFrom-Json).plugins | Select-Object name, version"`
Expected: two rows — `job-search-copilot 0.9.0` and `user-persona-generator 0.1.0`

- [ ] **Step 3: Commit via /commit skill**

Suggested message: `feat(marketplace): register user-persona-generator v0.1.0`

---

### Task 5: Verification pass against spec

**Files:** none (read-only checks)

- [ ] **Step 1: Structure parity with sibling plugin**

Run: `powershell -Command "Get-ChildItem -Recurse -File 'plugins/user-persona-generator' | Select-Object -ExpandProperty FullName"`
Expected: plugin.json, README.md, SKILL.md, persona-template.md, app-profile-template.md — mirroring job-search-copilot's layout.

- [ ] **Step 2: Spec verification checklist**

Confirm against the spec's "Verification for this cycle" list:
- Persona template covers all 9 schema sections (Task 2 Step 3 proved this)
- SKILL.md instructs batched questions, never one-at-a-time (grep `AskUserQuestion`)
- SKILL.md refuses pasted credentials and offers warm-session (grep `warm`)
- SKILL.md skips Phase 1 when app-profile.md exists (grep `skip Phase 1`)
- Native-app limitation stated in Phase 1 (grep `browser-only`)

Run: `powershell -Command "Select-String -Path 'plugins/user-persona-generator/skills/create-persona/SKILL.md' -Pattern 'AskUserQuestion','warm','skip Phase 1','browser-only' | Select-Object -ExpandProperty Pattern -Unique"`
Expected: all four patterns found.

- [ ] **Step 3: Report results to Craig**

Note: live `/plugin` install testing requires an interactive session — hand that to Craig as the final acceptance step (refresh the marketplace, confirm `user-persona-generator` appears, run `create-persona` against a sample project).
