# User Persona Generator

Simulated UX testing for teams that can't recruit real users. Generate
research-grade personas, then (in upcoming versions) watch them drive your
app in a real browser — clicking, typing, thinking aloud — and hand you a
severity-ranked findings report.

## Skills

| Skill | Status | What it does |
|-------|--------|--------------|
| `create-persona` | ✅ v0.1.0 | Interviews you about your app and target user, writes a runnable persona file |
| `run-persona-test` | ✅ v0.2.0 | Persona drives the app via Playwright, thinks aloud, logs a timestamped transcript |
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
