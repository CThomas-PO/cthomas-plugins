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
