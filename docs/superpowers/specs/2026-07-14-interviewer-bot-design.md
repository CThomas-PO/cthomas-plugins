# Interviewer Bot — Design

Date: 2026-07-14
Status: Draft — awaiting Craig's approval
Author: Claude (brainstormed from Craig's brief)

## Problem

Candidates practicing for job interviews have no low-cost way to rehearse against a
realistic, adaptive interviewer calibrated to a specific job description, resume, and
company culture. This plugin turns Claude itself into that interviewer — entirely through
skill instructions, no backend, no state machine, no external model calls. Claude tracks
phase, persona, and hidden scoring in-context during the conversation and produces a saved
performance review at the end.

## Non-goals (explicit, from the brief)

- No web server, no MCP server, no external API calls, no persistent database
- No conversation-loop code, no scoring engine outside Claude's own reasoning
- No third-party dependencies unless a PDF genuinely can't be read inline (degrade to
  asking for pasted text instead)

## Architecture

```
plugins/interviewer-bot/
  .claude-plugin/plugin.json
  README.md
  skills/
    interviewer/
      SKILL.md
      references/
        rubric.md
        persona-library.md
        report-template.md
  commands/
    interview.md
```

Registered in the existing `cthomas-plugins` marketplace
(`.claude-plugin/marketplace.json`) as a third plugin, alongside `job-search-copilot` and
`user-persona-generator`. No `.mcp.json` — this plugin makes no external calls.

- `plugin.json`: `name: interviewer-bot`, `version: 0.1.0`, description, `author.name:
  "Craig"`, keywords (`interview-prep`, `mock-interview`, `career`, `behavioral-interview`,
  `star-method`).
- Root `README.md` gets a third row in the plugin table; `marketplace.json` gets a matching
  entry at `0.1.0`.
- `interviewer-bot/README.md` gets its own `## Changelog` starting at `0.1.0`.

## Session flow

### Phase 0 — Context ingestion

Collect, in order: **Job Description** (required), **Candidate Resume** (required),
**Cover Letter** (optional), **Company Background** (optional) — as uploaded files or
pasted text. PDFs are read inline where the runtime supports it; if a PDF genuinely can't
be read, ask once for pasted text instead of failing silently.

- Missing required input → ask once, concisely, for that specific input.
- Missing optional input → proceed, and note the reduced calibration explicitly (e.g.
  "no company background provided, so I'll interview in a neutral professional tone").

Inputs are session-scoped only. Unlike `job-search-copilot`'s `career-profile.md`, there is
no persistent candidate profile — each mock interview is likely for a different role, so
nothing is cached between sessions.

### Phase 0b — Session setup

Present a compact setup menu, each option defaulted from the JD:

| Option | Choices | Default source |
|---|---|---|
| Seniority / rigor | Intern · Junior · Mid · Senior · Staff/Principal | Level implied by JD |
| Focus mode | Full mock · Behavioral-only · Technical/systems-design-only · Rapid-fire | Full mock |
| Question count (Phase 2) | e.g. 3 / 5 / 8 | 5 |

Candidate answers in one line (e.g. "Senior, technical-only, 8") or says "defaults" to
accept all three. Claude then shows a one-line calibration summary — "Interviewing you as
[persona] for [role] at [company] — [level], [focus], [N] questions" — and waits for
confirmation before Phase 1 starts.

### Phase 1 — Icebreaker

1–2 warm opening questions, in persona.

### Phase 2 — Core

The candidate's chosen number of questions (default 5), shaped by focus mode and seniority.
Blends behavioral (STAR-eliciting) and technical questions drawn from the JD's stated
requirements, or skews fully to one style if that focus mode was chosen. Prioritizes the
JD's must-haves and any gaps/ambiguities visible in the resume.

Enforced behavior:
- One question at a time — never batch or preview upcoming questions
- Stay in character for the whole interview; never narrate mechanics or reveal scoring
- Probe adaptively: vague answers or incomplete STAR (no Result, no metrics) get a natural
  follow-up instead of moving on
- `/exit` at any point jumps straight to the report

### Phase 3 — Candidate's turn

Invite the candidate to ask questions about the company; answer in persona, grounded in
whatever company background was provided (or decline gracefully in neutral tone if none
was).

## Persona (`references/persona-library.md`)

Five archetypes, inferred from company background (or defaulted to neutral if absent):

1. **Fast-paced startup founder** — informal, terse questions, fast follow-ups, comfortable
   with ambiguity in answers
2. **Formal enterprise HR panel** — structured, scripted-feeling phrasing, polite but
   procedural, less follow-up improvisation
3. **Technical peer / bar-raiser** — dense technical probing, skeptical of hand-waving,
   pushes on depth and tradeoffs
4. **Mission-driven nonprofit / public-sector** — values- and impact-oriented framing,
   warmer tone, asks about motivation and fit as much as skill
5. **Neutral professional default** — used whenever company background is absent; balanced
   tone, no strong stylistic lean

Each archetype defines: tone, pacing, question phrasing style, and how aggressively it
follows up on weak answers.

## Hidden evaluation (`references/rubric.md`)

Four vectors, each scored 1–5 with defined behavioral anchors (what a 1 vs. 3 vs. 5 answer
actually sounds like, not just a label):

1. Communication clarity
2. Alignment with job requirements
3. STAR completeness (behavioral answers only)
4. Cultural fit

Claude maintains this as an internal running tally — not printed, not hinted at, not
referenced in any in-character remark. Anchors scale with the seniority level chosen in
setup (a "5" for Intern is a materially lower bar than a "5" for Staff/Principal). The
tally is revealed only inside the final report.

## Report (`references/report-template.md`)

On natural conclusion or `/exit`, generate a "Interview Performance Review" following a
fixed structure:

1. **Overall recommendation** — Strong Hire / Lean Hire / No Hire, one-paragraph rationale
2. **Vector breakdown** — each of the 4 vectors scored, with specific strengths/weaknesses
   observed during the session
3. **Transcript deep-dive** — 3–5 actual candidate quotes, each with a stronger rephrasing
   and why it lands better, tied to the vector it improves
4. **Top 3 priorities** — what to work on before the real interview

### Storage

Before saving, Claude checks for a connected working folder. If none is connected, it asks
once (the same fix `job-search-copilot` already needed at v0.8.1 — ask before saving, not
after silently failing to persist). The report saves to:

```
interview-reviews/<company-slug>-<role-slug>-<YYYY-MM-DD>.md
```

## Command

`commands/interview.md` — a thin slash command stating the trigger and pointing at the
`interviewer` skill. The skill's own `SKILL.md` description also carries natural-language
triggers ("run a mock interview for me", "practice interviewing for this job"), matching
how skills trigger in the other two plugins.

## Error handling

- Required input missing → ask once, specifically, don't guess
- PDF unreadable → ask for pasted text instead, explicitly, once
- No working folder at save time → ask once before the report is lost
- Candidate gives no company background → proceed in neutral persona, say so up front, no
  silent degradation

## Verification for this cycle

1. Plugin loads: appears in `/plugin` list after marketplace refresh
2. A full run (JD + resume, defaults accepted) completes all 3 phases and produces a saved
   report matching the template
3. An intentionally vague STAR answer triggers a follow-up probe rather than moving on
4. No score, critique, or rubric leak appears anywhere in the in-character transcript
5. `/exit` mid-Phase-2 jumps straight to a valid report
6. Missing company background → neutral persona used, calibration summary says so

## Out of scope (v1)

- Persistent candidate profile across sessions
- Multi-round / multi-interviewer panel simulation
- Voice or video delivery
- Scoring calibration against real hiring outcomes
