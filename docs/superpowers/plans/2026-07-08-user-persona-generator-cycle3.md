# User Persona Generator — Cycle 3 Implementation Plan (persona-findings)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `persona-findings` v0.3.0 — turns session transcripts into a severity-ranked, evidence-cited findings report; completes the three-skill pipeline.

**Architecture:** Pure analysis skill: reads the transcript entry tags cycle 2 defined (`[Think]`, `[Action #N]`, `[Screen]`, `[Moderator]`), produces `findings.md` per the fixed template. No browser, no new MCP. Single-session mode writes into the session folder; multi-session synthesis writes to `ux-testing/findings/`.

**Tech Stack:** Claude Code plugin (markdown skill + reference template). Version 0.3.0.

## Global Constraints

- Version `0.2.0` → `0.3.0` in `plugins/user-persona-generator/.claude-plugin/plugin.json` AND the plugin's entry in `.claude-plugin/marketplace.json` (never `metadata.version`)
- Findings describe the **user experience, not code fixes** (spec: "it reports 'the persona couldn't find checkout…', not CSS patches")
- Every finding must cite at least one timestamped transcript entry verbatim; no invented evidence
- Severity scale exactly: `Blocker > Major > Minor > Nitpick`
- Moderator-flagged test artifacts (account history, tool notes) must temper findings, in a mandatory caveats section
- Lean-session rule (Craig): the skill runs start-to-finish with **zero mid-run questions** when a session is unambiguous; it asks only when multiple sessions exist and the user didn't specify
- Commits via the /commit procedure (explicit staging + secret scan); JSON verified with `ConvertFrom-Json`

---

### Task 1: findings-template.md

**Files:**
- Create: `plugins/user-persona-generator/skills/persona-findings/references/findings-template.md`

**Interfaces:**
- Produces: the section headings and per-finding field list Task 2's SKILL.md instructs Claude to follow verbatim.

- [ ] **Step 1: Write findings-template.md**

```markdown
# Findings Report Template

Copy this structure when writing a findings report. Keep headings
verbatim. One `### F{n}.` block per finding, ranked most severe first.

---

# UX Findings: {App} — {persona(s) / task(s), short form}

- **Generated:** {YYYY-MM-DD}
- **Sessions analyzed:** {relative path(s) to session folder(s)}
- **Personas:** {name — one-line characterization, per persona}
- **Task outcome(s):** {per session: success | partial | abandoned at
  {step} | ended by cap, with duration and actions used}

## Executive summary

{3–6 sentences: did the persona accomplish the task, where did the
product fight them, what single fix would help this user segment most.}

## Findings

(Ranked most severe first. Severity rubric:
**Blocker** — prevented task completion for this persona, or required a
moderator rescue the product should have made unnecessary.
**Major** — forced a significant detour, broke the persona's mental
model, or caused them to skip a viable path; completion was at risk.
**Minor** — momentary, recoverable confusion; no change of path.
**Nitpick** — wording or cosmetic annoyance; no behavioral impact.)

### F{n}. {Short title} — {Blocker | Major | Minor | Nitpick}

- **What happened:** {1–3 sentences, plain language}
- **Evidence:** {verbatim [Think] or [Moderator] quote} —
  `[HH:MM:SS]`, {screenshots/NNN-slug.png if one exists}
- **Impact:** {who this affects and what it cost — time, a skipped job,
  a near-abandonment, an unfound feature}
- **Recommendation:** {UX-level change, phrased for a product/design
  team — never a code fix}
- **Confidence:** {high | medium | low} — {one line: sample size, any
  artifact caveat}

## What worked well

{2–4 bullets with the same evidence discipline — quote + timestamp.
Required: a report that only lists problems misleads.}

## Test-environment caveats

{Mandatory when the transcript contains [Moderator] artifact or tool
notes: list each and say which findings it tempers and how. "None" only
if the transcript has none.}

## Suggested next tests

{1–3 bullets: which persona or task would best confirm, extend, or
challenge these findings.}
```

- [ ] **Step 2: Verify headings**

Run: `powershell -Command "(Select-String -Path 'plugins/user-persona-generator/skills/persona-findings/references/findings-template.md' -Pattern '^## ').Line"`
Expected: Executive summary / Findings / What worked well / Test-environment caveats / Suggested next tests

- [ ] **Step 3: Commit** — `user-persona-generator 0.3.0: add findings report template`

---

### Task 2: persona-findings SKILL.md + README + version bump

**Files:**
- Create: `plugins/user-persona-generator/skills/persona-findings/SKILL.md`
- Modify: `plugins/user-persona-generator/README.md` (skills table row: `🔜 planned` → `✅ v0.3.0`)
- Modify: `plugins/user-persona-generator/.claude-plugin/plugin.json` (version → 0.3.0)
- Modify: `.claude-plugin/marketplace.json` (user-persona-generator entry version → 0.3.0)

**Interfaces:**
- Consumes: transcript entry tags from cycle 2 (`[Think]`, `[Action #N]`, `[Screen]`, `[Moderator]`) and the Session summary block; `references/findings-template.md` from Task 1.
- Produces: `findings.md` inside the session folder (single) or `ux-testing/findings/<YYYY-MM-DD>-<app-slug>-synthesis.md` (multi).

- [ ] **Step 1: Write SKILL.md**

```markdown
---
name: persona-findings
description: >
  This skill should be used when the user wants "the findings", "a
  findings report", "analyze the test session", "what did the persona
  learn", or after run-persona-test completes a session. It reads one or
  more session transcripts from ux-testing/sessions/ and produces a
  severity-ranked findings report where every finding cites verbatim,
  timestamped evidence from the transcript.
metadata:
  version: "0.3.0"
---

# Persona Findings

Turn a think-aloud transcript into the report a UX researcher would
write: ranked findings, each anchored to what the persona actually said
and did — never to what you imagine they felt.

## Before starting

1. Locate sessions: `ux-testing/sessions/*/transcript.md`. None → say so
   and point to run-persona-test.
2. Scope without asking when possible: if the user named a session or
   only one exists, analyze it silently. If several exist and the user
   said "all" or "for {app}", synthesize those. Ask ONLY when several
   sessions exist and the request names none.
3. A transcript without a `## Session summary` block is an interrupted
   session: analyze it, but mark every finding's confidence down one
   level and say why in the caveats section.

## Method

1. Read the whole transcript first: header (task, criterion, caps),
   timeline, debrief, summary.
2. Collect finding candidates from, in priority order:
   - [Moderator] notes explicitly flagged as finding candidates
   - [Think] entries showing confusion, hesitation, misreading, distrust,
     or wrong mental models
   - The debrief answers (the persona's own ranking of what hurt)
   - Patience-budget events: failed attempts, near-abandonments,
     abandonment itself (an abandonment is at least one Blocker)
3. Separate signal from noise:
   - [Moderator] *tool notes* (timeouts, retries) are NOT user
     experience — exclude them from findings entirely
   - [Moderator] *artifact notes* (account history, warm-session
     leftovers) temper related findings — cite them in the caveats
     section and lower the affected finding's confidence
4. Rank by the severity rubric in `references/findings-template.md`.
   Do not pad: three real findings beat seven stretched ones. Merge
   duplicates (same root cause observed twice is one finding with two
   pieces of evidence).
5. Write the report following the template exactly.

## Evidence rules (non-negotiable)

- Every finding cites at least one verbatim quote with its `[HH:MM:SS]`
  timestamp, plus a screenshot reference when one exists for that moment
- Quotes are copied exactly — never paraphrased inside quotation marks
- No finding may rest on inference alone; if the transcript doesn't
  show it, it isn't a finding
- Recommendations are UX-level ("label the save control with the word
  Save"), never implementation-level ("change the aria-label / CSS")
- "What worked well" is required — an all-negative report misleads

## Multi-session synthesis

When analyzing several sessions: group findings that recur across
personas (recurrence raises confidence and usually severity by one
notch, capped at Blocker); note which persona segments hit which
issues; keep single-session findings with their persona named. Output
goes to `ux-testing/findings/<YYYY-MM-DD>-<app-slug>-synthesis.md`.

## Output

- Single session → `findings.md` inside that session's folder
- Multi-session → the synthesis path above
- After writing, give the user the file path and the executive summary
  in chat — nothing else. No mid-run questions, no progress narration.

## Rules

- Never modify the transcript — it is the evidence record
- Never invent, soften, or dramatize evidence
- If the persona succeeded easily and there are no real findings, say
  exactly that — a clean bill is a valid, useful result
```

- [ ] **Step 2: Flip README row.** `| \`persona-findings\` | 🔜 planned | ... |` → `| \`persona-findings\` | ✅ v0.3.0 | Turns session transcripts into a severity-ranked findings report |`

- [ ] **Step 3: Bump versions.** plugin.json `"version": "0.2.0"` → `"0.3.0"`; marketplace.json user-persona-generator entry `"version": "0.2.0"` → `"0.3.0"`.

- [ ] **Step 4: Verify**

Run: `powershell -Command "(Select-String -Path 'plugins/user-persona-generator/skills/persona-findings/SKILL.md' -Pattern '^## ').Line; (Get-Content 'plugins/user-persona-generator/.claude-plugin/plugin.json' -Raw | ConvertFrom-Json).version; ((Get-Content '.claude-plugin/marketplace.json' -Raw | ConvertFrom-Json).plugins | Where-Object name -eq 'user-persona-generator').version"`
Expected: 6 section headings (Before starting / Method / Evidence rules (non-negotiable) / Multi-session synthesis / Output / Rules); `0.3.0` twice.

- [ ] **Step 5: Commit** — `user-persona-generator 0.3.0: add persona-findings skill`

---

### Task 3: Push, PR

- [ ] **Step 1:** Push branch `feature/persona-findings`; open PR titled `user-persona-generator 0.3.0: persona-findings skill` targeting main. Body: completes the pipeline; evidence rules; zero-question lean run; single + synthesis modes.

---

### Task 4: Acceptance — real findings report from Gary's session

**Files:** writes `C:\Users\mgyat\OneDrive\Documents\plugin testing\create persona\ux-testing\sessions\2026-07-08-gary-job-novice-find-and-save-jobs\findings.md`

- [ ] **Step 1:** Execute the shipped SKILL.md against Gary's transcript (single session, named — so zero questions).
- [ ] **Step 2:** Acceptance criteria: every finding has verbatim quote + timestamp; tool notes (typing timeout, click retry) appear in NO finding; artifact notes (account history) appear in caveats and lower affected confidence; "What worked well" cites the autocomplete moment; report ends in chat with path + executive summary only.
