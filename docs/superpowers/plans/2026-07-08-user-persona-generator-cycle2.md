# User Persona Generator — Cycle 2 Implementation Plan (run-persona-test)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `run-persona-test` v0.2.0 — a persona loads from `ux-testing/personas/`, drives the app in a live Playwright browser with first-person think-aloud, logs a timestamped transcript with screenshots, and hands off to findings.

**Architecture:** The skill runs **inline in the main conversation** (spec: "Cycle 2 decisions") so think-aloud streams live and AskUserQuestion works mid-session. Browser capability ships via a root `.mcp.json` declaring the Playwright MCP server. The transcript is appended as the session runs, never buffered.

**Tech Stack:** Claude Code plugin (markdown skill + JSON manifests), Playwright MCP (`@playwright/mcp`).

## Global Constraints

- Version bump: `0.1.0` → `0.2.0` in `plugin.json` AND the plugin's entry in `.claude-plugin/marketplace.json` (NOT `metadata.version`)
- Session caps (defaults, overridable at session start): **20 minutes wall-clock or 60 browser actions**, whichever first; hitting a cap is logged as "ended by cap", never disguised as a persona decision
- Warm-session only in chat: credential values never pass through the conversation or any file
- Personas never navigate outside the allowed origins in `ux-testing/app-profile.md`
- Confirm-first actions (from app profile + persona Runner Config) require AskUserQuestion before acting
- Commits via the `/commit` procedure (explicit staging + secret scan), one per task
- All JSON must parse (`ConvertFrom-Json`)

---

### Task 1: Playwright MCP declaration + version bump

**Files:**
- Create: `plugins/user-persona-generator/.mcp.json`
- Modify: `plugins/user-persona-generator/.claude-plugin/plugin.json` (version field)
- Modify: `.claude-plugin/marketplace.json` (user-persona-generator entry's version field only)

**Interfaces:**
- Produces: MCP server name `playwright` — SKILL.md (Task 3) references its tools (`browser_navigate`, `browser_snapshot`, `browser_click`, `browser_type`, `browser_take_screenshot`, `browser_resize`, `browser_close`).

- [ ] **Step 1: Write .mcp.json** (stdio server, mirrors sibling plugin's file location)

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

- [ ] **Step 2: Bump versions.** `bump.ps1` is hardcoded to job-search-copilot — edit directly. In `plugins/user-persona-generator/.claude-plugin/plugin.json` change `"version": "0.1.0"` → `"version": "0.2.0"`. In `.claude-plugin/marketplace.json`, in the object whose `"name"` is `"user-persona-generator"`, change `"version": "0.1.0"` → `"version": "0.2.0"`. Touch nothing else.

- [ ] **Step 3: Verify**

Run: `powershell -Command "Get-Content 'plugins/user-persona-generator/.mcp.json' -Raw | ConvertFrom-Json | Out-Null; (Get-Content 'plugins/user-persona-generator/.claude-plugin/plugin.json' -Raw | ConvertFrom-Json).version; ((Get-Content '.claude-plugin/marketplace.json' -Raw | ConvertFrom-Json).plugins | Where-Object name -eq 'user-persona-generator').version"`
Expected: `0.2.0` twice, no parse errors.

- [ ] **Step 4: Commit** — `user-persona-generator 0.2.0: declare Playwright MCP, bump version`

---

### Task 2: Transcript template

**Files:**
- Create: `plugins/user-persona-generator/skills/run-persona-test/references/transcript-template.md`

**Interfaces:**
- Produces: the entry types `[Think]`, `[Action #N]`, `[Screen]`, `[Moderator]` and the Session summary block — Task 3's SKILL.md and the future `persona-findings` skill parse these exactly.

- [ ] **Step 1: Write transcript-template.md**

```markdown
# Transcript Template

Copy this structure when writing a session's `transcript.md`. Write the
header before the session starts; append Timeline entries AS the session
runs (never buffer — a crashed session must still leave a usable
transcript). Entry tags are parsed by persona-findings — keep them
verbatim.

---

# UX Test Session: {Persona Name} — {task, short form}

- **Date:** {YYYY-MM-DD}
- **Persona:** {path to persona file}
- **App:** {app name} — {start URL}
- **Viewport:** {from persona Runner Config}
- **Access:** warm-session (tester logged in before handoff: {yes/no})
- **Caps:** {20 min / 60 actions or overrides}
- **Task assigned:** {tester's words, verbatim}
- **Completion criterion:** {one sentence — how we know the task is done}

## Timeline

(Every entry gets a real clock timestamp. One entry per line, blank line
between entries. Entry types:)

**[HH:MM:SS] [Think]** {First-person, in-character narration — what the
persona notices, expects, feels, decides. Written BEFORE the action it
motivates.}

**[HH:MM:SS] [Action #N]** {What the persona physically did, one action:
clicked "Sign in", typed "warehouse supervisor" into the search box,
scrolled down one screen. N counts toward the action cap.}

**[HH:MM:SS] [Screen]** screenshots/{NNN}-{slug}.png — {one line: what
this screenshot shows}

**[HH:MM:SS] [Moderator]** {Out-of-character exchange between tester and
runner: login handoff, confirm-first approvals, CAPTCHA assists, tester
interjections, cap warnings. Never in the persona's voice.}

## Debrief

(In character, after the task ends — three questions, verbatim answers:)

- **What was the hardest part?** {answer}
- **Was there a moment you almost gave up? What was on the screen?** {answer}
- **If the people who made this were sitting here, what would you tell
  them?** {answer}

## Session summary

- **Outcome:** {success | partial | abandoned at {step} | ended by cap}
- **Duration:** {MM:SS} — **Actions used:** {N} of {cap}
- **Moments of confusion:** {bulleted list, each with timestamp and one
  line}
- **Moderator assists:** {count + one line each, or "none"}
- **Guardrail events:** {confirm-first pauses, origin boundary hits, or
  "none"}
```

- [ ] **Step 2: Verify entry tags present**

Run: `powershell -Command "(Select-String -Path 'plugins/user-persona-generator/skills/run-persona-test/references/transcript-template.md' -Pattern '\[Think\]','\[Action #N\]','\[Screen\]','\[Moderator\]' | Select-Object -ExpandProperty Pattern -Unique).Count"`
Expected: `4`

- [ ] **Step 3: Commit** — `user-persona-generator 0.2.0: add session transcript template`

---

### Task 3: run-persona-test SKILL.md + README status update

**Files:**
- Create: `plugins/user-persona-generator/skills/run-persona-test/SKILL.md`
- Modify: `plugins/user-persona-generator/README.md` (skills table row for run-persona-test: `🔜 planned` → `✅ v0.2.0`)

**Interfaces:**
- Consumes: persona schema (sections 8–9) from cycle 1, `app-profile.md` allowed origins/guardrails, `references/transcript-template.md` from Task 2, Playwright MCP tools from Task 1.
- Produces: session directory layout `ux-testing/sessions/<YYYY-MM-DD>-<persona-slug>-<task-slug>/` with `transcript.md` + `screenshots/` — `persona-findings` (cycle 3) reads exactly this.

- [ ] **Step 1: Write SKILL.md**

```markdown
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
```

- [ ] **Step 2: Update README skills table.** Change the row `| \`run-persona-test\` | 🔜 planned | ... |` to `| \`run-persona-test\` | ✅ v0.2.0 | Persona drives the app via Playwright, thinks aloud, logs a timestamped transcript |`.

- [ ] **Step 3: Verify headings**

Run: `powershell -Command "(Select-String -Path 'plugins/user-persona-generator/skills/run-persona-test/SKILL.md' -Pattern '^## ').Line"`
Expected: Pre-flight (in order, before the browser opens) / Embodiment rules / The think-aloud loop / Guardrails (enforced out of character) / Moderator exchanges / Ending the session / Rules

- [ ] **Step 4: Commit** — `user-persona-generator 0.2.0: add run-persona-test skill`

---

### Task 4: Push, PR, spec-coverage check

**Files:** none (git + review)

- [ ] **Step 1: Spec coverage grep.** Confirm the SKILL.md encodes every Cycle-2 decision:

Run: `powershell -Command "Select-String -Path 'plugins/user-persona-generator/skills/run-persona-test/SKILL.md' -Pattern 'ended by cap','warm-session','AskUserQuestion','start your screen recording','never invent','CAPTCHA' | Select-Object -ExpandProperty Pattern -Unique"`
Expected: all six patterns.

- [ ] **Step 2: Push branch, open PR** titled `user-persona-generator 0.2.0: run-persona-test skill` targeting main. Body summarizes: inline live-narration session runner, Playwright MCP via .mcp.json, transcript template, caps/guardrails/warm-session.

---

### Task 5: Live acceptance run (after Craig merges + marketplace refresh, or executed from the repo copy of SKILL.md)

**Files:** writes to `C:\Users\mgyat\OneDrive\Documents\plugin testing\create persona\ux-testing\sessions\...` (Craig's test project)

- [ ] **Step 1:** Prompt Craig for Gary's task + completion criterion (plan pre-approved: persona `gary-job-novice`, app Indeed per its app-profile.md).
- [ ] **Step 2:** Execute the session following the shipped SKILL.md verbatim — pre-flight, recording moment, warm-session login handoff in the browser window, think-aloud loop, debrief, summary.
- [ ] **Step 3:** Acceptance criteria: transcript exists with all four entry tags and real timestamps; ≥3 screenshots; no credential text anywhere in session files; outcome honestly recorded (success, abandonment, or cap); Craig watched the browser live.
