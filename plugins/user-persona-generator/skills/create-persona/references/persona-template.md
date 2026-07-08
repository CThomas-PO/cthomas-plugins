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
