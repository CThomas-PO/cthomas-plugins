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
