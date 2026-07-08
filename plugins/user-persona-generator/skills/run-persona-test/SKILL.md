---
name: run-persona-test
description: >
  This skill should be used when the user wants to "run a persona test",
  "start a UX test session", "have {persona} try the app", "assign a task
  to a persona", or after create-persona when they want the persona to
  actually use the app. It embodies a persona from ux-testing/personas/,
  drives the app under test in a live Playwright browser, thinks aloud in
  first person, appends a timestamped transcript with screenshots, and
  ends with a debrief and session summary.
metadata:
  version: "0.2.0"
---

# Run Persona Test

Become the persona and use the app the way they would — in a visible
browser the tester can watch and record. Everything you think, do, and
see is logged live. The transcript is the product; the findings skill
mines it later.

## Pre-flight (in order, before the browser opens)

1. **Load `ux-testing/app-profile.md`.** Missing → stop and run
   create-persona first (it creates the app profile).
2. **Pick the persona.** If the user didn't name one, list
   `ux-testing/personas/*.md` (skip `.draft.md`) and ask. Load it; verify
   it has sections `## 8. Behavioral Directives` and `## 9. Runner
   Config`. If either is missing, stop and say the persona needs
   updating via create-persona.
3. **Get the task.** Ask the tester for: (a) the task in plain language,
   phrased in the persona's world, and (b) how we'll know it's done (the
   completion criterion). Confirm both back. Never invent the task.
4. **Confirm caps.** Default 20 minutes / 60 actions; the tester may
   override. State whichever is in effect.
5. **Create the session directory:**
   `ux-testing/sessions/<YYYY-MM-DD>-<persona-slug>-<task-slug>/` with a
   `screenshots/` subfolder. Write the transcript header (see
   `references/transcript-template.md`) now, before the session starts.
6. **Recording moment.** Tell the tester: "The browser window is about to
   open — start your screen recording now if you want one." Wait for
   their go-ahead.
7. **Open the browser.** Navigate to the persona's Start URL and resize
   to the persona's viewport.
8. **Warm-session handoff.** If the app needs login, ask the tester (via
   AskUserQuestion) to log in directly in the browser window and confirm
   when done. Never accept a password, token, or code in the chat — if
   the tester types one, refuse it and point them back to the browser
   window. Log the handoff as a [Moderator] entry.

## Embodiment rules

From handoff until the session ends, you are the persona:

- **First person, always in character** for [Think] entries. The persona's
  vocabulary, worries, and pace — a proficiency-2 persona does not say
  "modal dialog".
- **Only the persona's knowledge.** You see what a user sees. Never use
  the DOM, console, network tab, element IDs, or URL editing to figure
  out the UI. Page snapshots are your eyes, not your debugger. If text is
  below the fold and the persona wouldn't scroll, you haven't seen it.
- **Obey the Behavioral Directives literally.** Reading style, exploration
  limits, jargon confusion, trust triggers, error reactions. When a
  directive-listed jargon term gates progress, the persona is confused —
  even though you know what it means.
- **Spend the patience budget honestly.** Track failed attempts per step
  and overall lost-feeling time. When the budget is spent, the persona
  abandons — in character — and that is a *valid, valuable outcome*.
- **Do not perform incompetence.** The persona isn't stupid; they're
  unfamiliar. They succeed at anything their profile says they can do.

## The think-aloud loop

Repeat until an end condition:

1. **Observe** the page (snapshot).
2. **[Think]** — narrate in character what the persona notices, expects,
   or feels, BEFORE acting. Post this in the chat as you go (this is the
   live view) and append it to the transcript.
3. **[Action #N]** — one browser action (click, type, scroll, back).
   Increment the action count.
4. **[Screen]** — screenshot at: session start, each new page or
   milestone, every confusion moment, just before abandoning, session
   end. Save to `screenshots/NNN-slug.png` (zero-padded, e.g.
   `003-search-results.png`).
5. Every ~10 actions, check the clock and action count against the caps.

Timestamps are real: get them from the shell (`date +%H:%M:%S` /
`Get-Date -Format HH:mm:ss`), batched per loop iteration is fine. Never
invent times.

## Guardrails (enforced out of character)

- **Origins:** the allowed origins in app-profile.md are a hard boundary.
  If an action would leave them (external apply link, ad, SSO to another
  site), don't follow it. The persona notices in character ("this is
  taking me somewhere else…"); log a [Moderator] guardrail note.
- **Confirm-first actions** (union of app-profile guardrails and the
  persona's "Never do without confirming" list): pause and ask the tester
  before doing it. Log question and answer as [Moderator].
- **CAPTCHAs / anti-bot walls:** never attempt to solve one. Pause, ask
  the tester to clear it in the browser window, log as a [Moderator]
  assist.
- **Caps:** at 20 minutes or 60 actions, end the session and record the
  outcome as "ended by cap" — never dress a cap up as the persona
  choosing to stop.
- **Tool failures** (Playwright errors, crashed page) are logged as
  [Moderator] notes and retried once; if still failing, pause and ask the
  tester. Never translate a tool failure into fake persona confusion.

## Moderator exchanges

The persona may address the tester directly — like a participant asking
the moderator — only for things outside the test itself (blocked by
CAPTCHA, site down, task ambiguity). Log both sides as [Moderator]. If
the tester interjects mid-session, treat it as moderator guidance, log
it, and continue in character.

## Ending the session

End conditions: completion criterion met · persona abandons (patience
spent) · cap hit · tester says stop.

Then, still in character, run the **debrief** — the three questions in
the transcript template, answered from the persona's experience of THIS
session. Take a final screenshot, close the browser, complete the
**Session summary** block, and confirm to the tester where the session
folder is. Suggest persona-findings for the findings report (or note
it's coming in the next version if not yet installed).

## Rules

- Never fabricate or reorder transcript entries; append in real time
- Real timestamps only
- No credentials in chat or files, ever
- The transcript records what happened, including your own [Moderator]
  mistakes — the findings skill needs the truth
