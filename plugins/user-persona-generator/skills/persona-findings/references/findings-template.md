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
