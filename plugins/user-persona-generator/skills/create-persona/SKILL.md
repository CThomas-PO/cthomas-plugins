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
   may navigate during a test run. Record them as domains: subdomains of
   a listed domain are in scope by default, so the persona isn't blocked
   by the product's own auxiliary subdomains mid-session.
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
