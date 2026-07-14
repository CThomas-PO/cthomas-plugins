# Interviewer Bot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a third plugin, `interviewer-bot`, in the `cthomas-plugins` marketplace that turns Claude into an adaptive mock-interview coach entirely through skill instructions (no server, no state-machine code, no external calls).

**Architecture:** One skill (`skills/interviewer/SKILL.md`) drives three in-context phases (icebreaker, core, candidate's-turn), reading three reference files for persona selection, hidden scoring, and the final report shape. A thin slash command (`commands/interview.md`) triggers it. The plugin is registered in the existing marketplace catalog alongside `job-search-copilot` and `user-persona-generator`.

**Tech Stack:** Markdown + YAML frontmatter only (Claude Code plugin/skill format). No code, no dependencies, no `.mcp.json`.

## Global Constraints

- No web server, no MCP server, no external API calls, no persistent database, no conversation-loop code (per spec).
- Plugin lives at `plugins/interviewer-bot/` and is registered in `.claude-plugin/marketplace.json` and the root `README.md`, following the exact conventions of `job-search-copilot` and `user-persona-generator`.
- All version fields (`plugin.json`, `marketplace.json` entry, `SKILL.md` frontmatter `metadata.version`) start at `0.1.0`.
- No `.mcp.json` for this plugin — it makes no external calls.
- Report save location: `interview-reviews/<company-slug>-<role-slug>-<YYYY-MM-DD>.md` in the user's working folder. If no folder is connected, ask once to connect one (via `request_cowork_directory`, matching `career-profile-setup`'s exact pattern); if declined, save to the outputs folder and tell the candidate to keep a copy.
- Hidden scoring (the 4-vector rubric tally) must never be printed, hinted at, or leaked in-character during the session — only revealed in the final report.
- `interviewer-bot/README.md` must be written at a 7th-grade reading level: short sentences, plain words, no unexplained jargon.
- One question at a time during Phase 1/2 — never batch or preview upcoming questions.
- `/exit` must work at any point and jump straight to report generation.

---

### Task 1: Plugin manifest

**Files:**
- Create: `plugins/interviewer-bot/.claude-plugin/plugin.json`

**Interfaces:**
- Produces: plugin identity `name: interviewer-bot`, `version: 0.1.0` — referenced by Task 8's marketplace entry, which must match exactly.

- [ ] **Step 1: Write the manifest**

```json
{
  "name": "interviewer-bot",
  "version": "0.1.0",
  "description": "An adaptive mock-interview coach: reads your resume and a job description, runs a realistic interview in the hiring company's voice, and hands you a private performance review with rewritten answers.",
  "author": {
    "name": "Craig"
  },
  "keywords": ["interview-prep", "mock-interview", "career", "behavioral-interview", "star-method"]
}
```

- [ ] **Step 2: Validate it's well-formed JSON**

Run (PowerShell):
```
Get-Content "plugins/interviewer-bot/.claude-plugin/plugin.json" -Raw | ConvertFrom-Json | Out-Null; if ($?) { "VALID" }
```
Expected output: `VALID`

- [ ] **Step 3: Commit**

```bash
git add plugins/interviewer-bot/.claude-plugin/plugin.json
git commit -m "feat(interviewer-bot): add plugin manifest"
```

---

### Task 2: Scoring rubric reference

**Files:**
- Create: `plugins/interviewer-bot/skills/interviewer/references/rubric.md`

**Interfaces:**
- Produces: the 4 vectors (Communication clarity, Alignment with job requirements, STAR completeness, Cultural fit), each 1–5 with anchors, plus a "Holding the tally" note format. Task 5 (`SKILL.md`) references this file by the exact relative path `references/rubric.md` and depends on these four vector names being spelled identically.

- [ ] **Step 1: Write the rubric**

```markdown
# Interview Scoring Rubric

Used silently during a session — never shown to the candidate until the final report. Every candidate answer gets weighed against these four vectors, 1–5 each. Anchors describe what a real answer at that score sounds like, not abstract adjectives.

Scale each anchor to the seniority level chosen in setup: a "5" for Intern is a lower bar than a "5" for Staff/Principal — read the "Scaling by seniority" note under each vector.

## 1. Communication clarity

1. Rambling, no structure, listener has to ask "what's the point?" Jumps between ideas mid-sentence.
2. Gets there eventually but with a lot of backtracking, filler, or over-explaining obvious things.
3. Organized and understandable, but answers run long or short of the natural landing point.
4. Clear structure (situation → point → detail), appropriately concise, easy to follow without effort.
5. Structured, concise, and adapts to the question's intent — leads with the answer, then evidence.

**Scaling:** Junior/Intern candidates are not penalized for a 3 that stays on-topic but is a little wordy; Senior/Staff candidates are expected to lead with the point (a 3 becomes the ceiling for someone who buries the lede at that level).

## 2. Alignment with job requirements

1. Answer has nothing to do with the skill/requirement the question targeted.
2. Superficial connection; name-drops a relevant tool/skill without evidence of real use.
3. Directly relevant experience, but at a shallower depth or scale than the JD implies.
4. Directly relevant, at the right depth, with specifics (numbers, systems, decisions).
5. Directly relevant, right depth, and reveals judgment beyond what the question asked for — trade-offs considered, edge cases anticipated.

**Scaling:** for Intern/Junior, "relevant coursework/personal project" counts as real evidence at level 3–4. For Senior/Staff, only production/team-scale evidence reaches 4–5.

## 3. STAR completeness (behavioral answers only — leave blank for technical questions)

1. No structure at all: describes a feeling or opinion, not an event.
2. Situation and Task present; Action is vague ("we worked on it"); no Result.
3. Situation, Task, Action all present; Result is asserted but has no metric or verifiable outcome.
4. Full STAR with a quantified or clearly observable Result.
5. Full STAR, quantified Result, and the candidate reflects on what they learned or would do differently.

**Scaling:** does not scale by seniority — a Staff candidate skipping Result is exactly as incomplete as a Junior candidate skipping it. Depth of the *Action* (vector 2's job) scales; STAR *structure* does not.

## 4. Cultural fit

1. Answer actively conflicts with the persona archetype's stated values (e.g., dismissive of collaboration at a mission-driven org).
2. Neutral/generic; could be answering for any company.
3. Shows awareness of the company's stated values or working style, applied loosely.
4. Answer is shaped around the specific company context (references the JD, company background, or persona's stated priorities).
5. Genuine, specific alignment — draws a real connecting line between the candidate's own experience and this company's specific mission/style, not a rehearsed line.

**Scaling:** does not scale by seniority; scales by how much company background was provided. If no company background was given, score this vector against generic professionalism only, and say so in the report rather than penalizing the candidate for something they couldn't have researched.

## Holding the tally

Keep a running per-question note in this shape (mental working memory — never printed during the session):

```
Q1 (icebreaker) — no formal score
Q2 (behavioral: conflict resolution) — Clarity 3, Alignment 4, STAR 2 (no Result), Fit 3
Q3 (technical: system design) — Clarity 4, Alignment 5, STAR n/a, Fit 3
```

At report time, average each vector across the questions where it applies (STAR only averages over behavioral questions) and translate to the report's 1–5 display plus the qualitative writeup.
```

- [ ] **Step 2: Verify required structure is present**

Run:
```bash
grep -c "^## " plugins/interviewer-bot/skills/interviewer/references/rubric.md
grep -E "Communication clarity|Alignment with job requirements|STAR completeness|Cultural fit" plugins/interviewer-bot/skills/interviewer/references/rubric.md | wc -l
```
Expected: first command outputs `5` (the 4 vector headings plus "Holding the tally"); second command outputs at least `4` (each vector name appears at least once).

- [ ] **Step 3: Commit**

```bash
git add plugins/interviewer-bot/skills/interviewer/references/rubric.md
git commit -m "feat(interviewer-bot): add scoring rubric reference"
```

---

### Task 3: Persona library reference

**Files:**
- Create: `plugins/interviewer-bot/skills/interviewer/references/persona-library.md`

**Interfaces:**
- Produces: 5 named archetypes — `Fast-paced startup founder`, `Formal enterprise HR panel`, `Technical peer / bar-raiser`, `Mission-driven nonprofit / public-sector`, `Neutral professional default` — and a signal-based selection table. Task 5 (`SKILL.md`) references this file by relative path `references/persona-library.md` and depends on these five names being spelled identically (used in the calibration summary line).

- [ ] **Step 1: Write the persona library**

```markdown
# Persona Library

Pick one archetype after reading the Company Background input (or default to Neutral when that input is absent). State the chosen persona once, in the calibration summary — never re-explain it mid-interview.

## How to choose

Scan the company background text for signals:

| Signals | Archetype |
|---|---|
| "move fast", "own it", small team, founder quotes, informal blog/careers page tone, seed/Series A/B stage | Fast-paced startup founder |
| Structured "Diversity & Inclusion", "process", "career ladder", large enterprise, Glassdoor mentions of formal panels | Formal enterprise HR panel |
| Engineering blog, architecture deep-dives, "bar raiser", competitive/prestige technical brand | Technical peer / bar-raiser |
| Nonprofit, ".org", public-sector, "mission", "impact", "community" language | Mission-driven nonprofit / public-sector |
| No company background provided, or signals are mixed/unclear | Neutral professional default |

If signals conflict (e.g. a technical role at a mission-driven org), blend the two nearest archetypes' tone but keep only one question style — pick the one that matches the *role*, not the org, since the candidate is being evaluated on the job, not the mission statement.

## 1. Fast-paced startup founder

- **Tone:** informal, first-name, occasional dry humor. Uses "we" a lot.
- **Pacing:** quick; doesn't pad with pleasantries; ready to move on fast.
- **Question style:** short, sometimes half-formed ("walk me through a time it broke"), comfortable with the candidate asking for clarification.
- **Follow-up aggressiveness:** high — interrupts a vague answer sooner than the other archetypes would, wants to get to the real story fast.

## 2. Formal enterprise HR panel

- **Tone:** polite, professional, slightly scripted — like reading from a competency framework.
- **Pacing:** measured; a beat of acknowledgment ("Thank you, that's helpful") before the next question.
- **Question style:** fully formed, often explicitly behavioral ("Tell me about a time when...").
- **Follow-up aggressiveness:** lower — gives the candidate more room to finish before probing, but still probes when Result is missing.

## 3. Technical peer / bar-raiser

- **Tone:** direct, curious, treats the candidate as a future colleague rather than a subordinate.
- **Pacing:** can slow way down on one topic if it's interesting, then move fast through the rest.
- **Question style:** technical depth, "why" chained several times, pushes on trade-offs and edge cases, skeptical of buzzwords without substance.
- **Follow-up aggressiveness:** highest on technical vagueness specifically ("what would happen under load" / "what did you consider and reject"); lower on behavioral polish.

## 4. Mission-driven nonprofit / public-sector

- **Tone:** warm, values-forward, asks about motivation as much as skill.
- **Pacing:** relaxed, gives space for the candidate's "why."
- **Question style:** blends behavioral with values questions ("why this cause", "how do you handle doing more with less").
- **Follow-up aggressiveness:** moderate; probes on genuineness more than technical depth.

## 5. Neutral professional default

- **Tone:** friendly, professional, no strong stylistic lean.
- **Pacing:** standard — a normal-paced professional interview.
- **Question style:** balanced behavioral/technical per the chosen focus mode, no persona-flavored phrasing.
- **Follow-up aggressiveness:** moderate, consistent.
- **When used:** no Company Background was provided. State this plainly in the calibration summary, e.g. "no company background provided, so I'll interview you in a neutral professional tone."
```

- [ ] **Step 2: Verify all five archetypes are present**

Run:
```bash
grep -E "^## [0-9]\." plugins/interviewer-bot/skills/interviewer/references/persona-library.md | wc -l
```
Expected: `5`

- [ ] **Step 3: Commit**

```bash
git add plugins/interviewer-bot/skills/interviewer/references/persona-library.md
git commit -m "feat(interviewer-bot): add persona library reference"
```

---

### Task 4: Report template reference

**Files:**
- Create: `plugins/interviewer-bot/skills/interviewer/references/report-template.md`

**Interfaces:**
- Produces: the exact markdown skeleton for the final "Interview Performance Review" (overall recommendation, vector breakdown, transcript deep-dive, top-3 priorities). Task 5 (`SKILL.md`) references this file by relative path `references/report-template.md` and instructs filling every `{{placeholder}}`.

- [ ] **Step 1: Write the report template**

````markdown
# Interview Performance Review — Template

Fill every `{{placeholder}}`. Do not leave any section empty — if a section has nothing notable (e.g., no company background so cultural fit is thin), say so explicitly rather than omitting the section.

```markdown
# Interview Performance Review

**Role:** {{role title}} at {{company name}}
**Date:** {{YYYY-MM-DD}}
**Interviewer persona:** {{persona archetype}}
**Format:** {{seniority level}} · {{focus mode}} · {{N}} core questions

## Overall Recommendation: {{Strong Hire | Lean Hire | No Hire}}

{{One paragraph rationale — reference the two or three factors that drove this call, in plain language, as a real hiring debrief would.}}

## Vector Breakdown

### Communication clarity — {{score}}/5
{{2-4 sentences: specific strengths, specific weaknesses, tied to moments in the interview.}}

### Alignment with job requirements — {{score}}/5
{{2-4 sentences, referencing specific JD requirements the candidate did or didn't demonstrate.}}

### STAR completeness — {{score}}/5
{{2-4 sentences on behavioral-answer structure specifically. If fewer than 2 behavioral questions were asked, say this score has limited signal.}}

### Cultural fit — {{score}}/5
{{2-4 sentences. If no company background was provided, say the score reflects generic professionalism only.}}

## Transcript Deep-Dive

{{3-5 of these blocks, each built from an actual candidate quote from this session:}}

### On "{{the interviewer's question, short form}}"

**You said:** "{{verbatim candidate quote}}"

**Stronger version:** "{{rewritten answer}}"

**Why it lands better:** {{1-2 sentences tying the improvement to a specific vector above.}}

## Top 3 Priorities Before the Real Interview

1. {{Most impactful, specific, actionable priority}}
2. {{Second priority}}
3. {{Third priority}}
```
````

- [ ] **Step 2: Verify the four required sections are present**

Run:
```bash
grep -E "Overall Recommendation|Vector Breakdown|Transcript Deep-Dive|Top 3 Priorities" plugins/interviewer-bot/skills/interviewer/references/report-template.md | wc -l
```
Expected: `4` or more

- [ ] **Step 3: Commit**

```bash
git add plugins/interviewer-bot/skills/interviewer/references/report-template.md
git commit -m "feat(interviewer-bot): add report template reference"
```

---

### Task 5: Core skill (SKILL.md)

**Files:**
- Create: `plugins/interviewer-bot/skills/interviewer/SKILL.md`

**Interfaces:**
- Consumes: `references/rubric.md` (Task 2, four vector names), `references/persona-library.md` (Task 3, five archetype names), `references/report-template.md` (Task 4, section names).
- Produces: the skill named `interviewer`, version `0.1.0`, triggered by phrases including "run a mock interview" / "practice for an interview" — Task 6's slash command points at this skill by name.

- [ ] **Step 1: Write the skill**

```markdown
---
name: interviewer
description: >
  This skill should be used when the user wants to "practice for an
  interview", "run a mock interview", "do a mock interview for this job",
  or asks Claude to interview them for a role. It reads a job description
  and resume (plus an optional cover letter and company background), runs
  an adaptive three-phase interview in a persona matched to the company's
  culture, and produces a private Interview Performance Review saved to
  the working folder.
metadata:
  version: "0.1.0"
---

# Interviewer

Claude plays a real interviewer, start to finish. Stay in character for the
entire session: never narrate what phase you're in, never reveal a score,
never break the fourth wall to explain mechanics. The candidate should feel
like they're in a real interview, not operating a tool.

## Phase 0 — Context ingestion

Collect, in this order:

1. **Job Description** (required) — text, markdown, or file
2. **Candidate Resume** (required) — text, markdown, or PDF
3. **Cover Letter** (optional)
4. **Company Background** (optional) — "About" page text, Glassdoor snippets, etc.

Accept each as an uploaded file or pasted text. Read PDFs inline where
possible. If a PDF genuinely can't be read, say so once and ask for pasted
text instead — never guess at its contents.

- **Missing required input:** ask once, concisely, naming exactly which
  input is missing. Do not start the interview without both the job
  description and the resume.
- **Missing optional input:** proceed, and say explicitly what's reduced —
  e.g. "no company background provided, so I'll interview you in a neutral
  professional tone" or "no cover letter, so I won't reference one."

## Phase 0b — Session setup

Infer smart defaults from the job description:

- **Seniority / rigor:** Intern · Junior · Mid · Senior · Staff/Principal —
  infer from the title, years-of-experience language, and scope language
  ("mentor", "own the roadmap", "individually execute").
- **Focus mode:** Full mock (balanced behavioral + technical) ·
  Behavioral-only · Technical/systems-design-only · Rapid-fire. Default:
  Full mock.
- **Question count (Phase 2):** default 5.

Present these three as a compact, labelled list with the inferred default
marked, and invite a one-line reply (e.g. "Senior, technical-only, 8") or
simply "defaults" to accept all three as-is.

Read `references/persona-library.md` and choose an interviewer persona from
the Company Background text using its selection table (default: Neutral
professional, if no company background was given).

Then show a one-line calibration summary and wait for confirmation before
Phase 1 begins:

> "Interviewing you as a [persona archetype] for [role] at [company] —
> [level], [focus mode], [N] questions. Say 'go' to start, or tell me what
> to change."

## Phase 1 — Icebreaker

Ask 1–2 warm opening questions, in persona, one at a time.

## Phase 2 — Core

Ask the chosen number of questions (default 5). Rules:

- **One question at a time.** Never batch or preview upcoming questions.
- Draw questions from the job description's stated requirements —
  prioritize must-haves and any gaps or ambiguities visible in the resume.
- Shape the mix by focus mode:
  - **Full mock:** alternate behavioral (STAR-eliciting) and technical
    questions, roughly balanced
  - **Behavioral-only:** every question is behavioral
  - **Technical/systems-design-only:** every question is technical or
    systems-design
  - **Rapid-fire:** short, high-volume questions; less follow-up depth per
    question, but still one at a time
- Scale difficulty and follow-up depth to the chosen seniority level.
- **Probe adaptively:** if an answer is vague, or an incomplete STAR
  (missing Result, no metrics), ask one natural follow-up before moving on
  — as a real interviewer would. Never ask more than two follow-ups on the
  same question; a real interviewer eventually moves on.
- After each substantive answer, silently score it per
  `references/rubric.md` (see Hidden evaluation below).

## Phase 3 — Candidate's turn

Invite the candidate to ask questions about the company. Answer in
persona, grounded in the Company Background if provided. If none was
provided, answer honestly in a neutral tone and say plainly that detailed
culture specifics aren't available to you.

## Hidden evaluation — discipline

Read `references/rubric.md` once at the start of the session. After every
substantive answer (skip small talk), silently note per-vector scores in
the "Holding the tally" shape from that file. This tally is your own
working memory:

- **Never print it.** No scores, no "that's a 4/5", no visible critique.
- **Never hint at it.** "Great answer" is fine; anything that implies a
  grade is not.
- If the candidate directly asks how they're doing, stay in character and
  decline gracefully — e.g. "I'll share my full thoughts at the end, let's
  keep going" — never leak a mid-session assessment.

## Ending the interview

The interview ends naturally after Phase 3, or early if the candidate
types `/exit` at any point in any phase. Either way, stop the interviewer
character and move straight to report generation — don't ask for
confirmation first.

## Generating the report

Read `references/report-template.md` and fill every `{{placeholder}}`
exactly. Pull 3–5 real quotes from this session's transcript for the
Transcript Deep-Dive section — never invent or paraphrase a quote there.
Average each vector's tally across the questions where it applied (STAR
only averages over behavioral questions).

## Saving the report

Check whether the user has a working folder connected. If one exists, save
there. If no folder is connected, ask the user to connect one (via
`request_cowork_directory`) so the report persists across sessions; if
they decline, save to the outputs folder and tell them to keep a copy.

Save to:

```
interview-reviews/<company-slug>-<role-slug>-<YYYY-MM-DD>.md
```

Confirm the saved path to the candidate, offer brief encouragement, and
offer to run another mock interview.

## Error handling

- Required input missing → ask once, specifically, don't guess.
- PDF unreadable → ask for pasted text once, explicitly.
- No working folder at save time → ask once, per "Saving the report"
  above, before the report is lost.
- No company background → proceed in the Neutral persona, and say so
  plainly in the calibration summary — never a silent degradation.
```

- [ ] **Step 2: Verify required structure and discipline language are present**

Run:
```bash
grep -c "^## Phase" plugins/interviewer-bot/skills/interviewer/SKILL.md
grep -c "references/rubric.md\|references/persona-library.md\|references/report-template.md" plugins/interviewer-bot/skills/interviewer/SKILL.md
grep -c "/exit" plugins/interviewer-bot/skills/interviewer/SKILL.md
grep -c "Never print it" plugins/interviewer-bot/skills/interviewer/SKILL.md
```
Expected: first command outputs `5` (headings `Phase 0`, `Phase 0b`, `Phase 1`, `Phase 2`, `Phase 3` all match `^## Phase`); second command outputs `3` or more (all three reference files are cited); third command outputs `2` or more; fourth command outputs `1`.

- [ ] **Step 3: Commit**

```bash
git add plugins/interviewer-bot/skills/interviewer/SKILL.md
git commit -m "feat(interviewer-bot): add core interviewer skill"
```

---

### Task 6: Slash command

**Files:**
- Create: `plugins/interviewer-bot/commands/interview.md`

**Interfaces:**
- Consumes: skill name `interviewer` (Task 5).
- Produces: the `/interview` command referenced in Task 7's README.

- [ ] **Step 1: Write the command**

```markdown
---
description: Start a mock interview session with Interviewer Bot
---

Start an Interviewer Bot session by following the `interviewer` skill
(`skills/interviewer/SKILL.md`) exactly: collect the job description and
resume (plus any optional cover letter or company background), run the
session-setup menu, then conduct the three-phase interview in persona,
ending with a saved Interview Performance Review. If the user has already
provided some of the required inputs earlier in this conversation, reuse
them instead of asking again.
```

- [ ] **Step 2: Verify frontmatter and skill reference are present**

Run:
```bash
grep -c "^description:" plugins/interviewer-bot/commands/interview.md
grep -c "interviewer" plugins/interviewer-bot/commands/interview.md
```
Expected: first command outputs `1`; second command outputs `2` or more.

- [ ] **Step 3: Commit**

```bash
git add plugins/interviewer-bot/commands/interview.md
git commit -m "feat(interviewer-bot): add /interview slash command"
```

---

### Task 7: Plugin README (7th-grade reading level)

**Files:**
- Create: `plugins/interviewer-bot/README.md`

**Interfaces:**
- Consumes: plugin name/version (Task 1), `/interview` command (Task 6).
- Produces: the plugin's install/usage doc, linked from the root README in Task 8.

- [ ] **Step 1: Write the README**

```markdown
# Interviewer Bot

Practice for a real job interview before the real thing. Interviewer Bot
asks you interview questions, listens to your answers, and gives you a
private report at the end. It runs right inside Claude — there is no extra
app to install.

## What you need

Before you start, have these ready:

1. **The job description.** Copy and paste it, or upload the file. (Required)
2. **Your resume.** Copy and paste it, or upload a PDF or Word file. (Required)
3. **A cover letter.** Only if you wrote one. (Optional)
4. **Info about the company.** Their "About Us" page, a Glassdoor review,
   anything like that. (Optional — the interview will just sound more
   general without it.)

## How to start

Type:

```
/interview
```

Or just say something like "Can you run a mock interview for me?" Claude
will ask for your job description and resume if you have not shared them
yet.

## What happens next

1. **Claude reads your files** and asks a couple of quick setup questions,
   like how hard the questions should be and how many questions you want.
   You can just say "defaults" to skip all of that and start right away.
2. **The interview begins.** Claude plays the part of a real interviewer at
   that company. It asks one question at a time and listens closely to
   your answer.
3. **If your answer is a little thin, Claude will ask a follow-up** — just
   like a real interviewer would. This is normal. It means Claude is
   paying attention.
4. **Near the end, you get to ask questions too**, like you would in a real
   interview.

Claude stays "in character" the whole time. It will not tell you how you
are doing partway through — that is on purpose. Real interviewers do not
grade you out loud either.

## Ending early

Type `/exit` at any point and Claude will stop the interview and skip
straight to your report.

## Your report

When the interview ends (on its own, or because you typed `/exit`), Claude
writes you a report called an "Interview Performance Review" and saves it
as a file you can keep. It includes:

- **An overall grade** — Strong Hire, Lean Hire, or No Hire — with a short
  explanation
- **A breakdown** of how you did in four areas: how clearly you spoke, how
  well your experience matched the job, how complete your stories were,
  and how well you seemed to fit the company
- **A few of your real answers**, rewritten to be stronger, with an
  explanation of why the new version works better
- **Your top 3 things to work on** before the real interview

The first time Claude saves a report, it will ask you to connect a folder
(sometimes called a "working folder"), so your reports stick around after
the chat ends.

## Try it with sample inputs

Want to test it out first? Paste this pretend job description and resume.

**Sample job description:**

```
Customer Support Specialist — Acme Software
We're looking for someone to answer customer emails and chat messages,
solve simple technical problems, and hand off harder issues to
engineering. 2+ years in a customer-facing role preferred. Must be a
clear writer and comfortable using a help-desk tool like Zendesk.
```

**Sample resume:**

```
Jordan Lee
2 years as a retail sales associate at a mid-size electronics store.
Handled customer questions in person and by phone. Trained two new
hires. Comfortable with basic computer systems; no formal help-desk
software experience.
```

Paste both in, say "defaults" when Claude asks about setup, and answer a
few questions to see how it works.

## Changelog

- **0.1.0** — first release: context ingestion, adjustable setup
  (seniority, focus, question count), a three-phase interview with
  adaptive follow-ups, five persona styles matched to company culture,
  hidden four-vector scoring, and a saved Interview Performance Review.

*To update an installed plugin, see [How do I get the latest version?](../../docs/GETTING-STARTED.md#troubleshooting--faq)*
```

- [ ] **Step 2: Verify required sections are present**

Run:
```bash
grep -E "^## " plugins/interviewer-bot/README.md | wc -l
grep -c "/interview" plugins/interviewer-bot/README.md
grep -c "/exit" plugins/interviewer-bot/README.md
```
Expected: first command outputs `7` or more; second and third each output `1` or more.

- [ ] **Step 3: Spot-check reading level**

Open the file and confirm no sentence exceeds roughly 25 words and no
paragraph exceeds 4 sentences. Fix any that do — this is a manual read,
not a scripted check, since there's no linter for reading level in this
repo.

- [ ] **Step 4: Commit**

```bash
git add plugins/interviewer-bot/README.md
git commit -m "docs(interviewer-bot): add plugin README"
```

---

### Task 8: Marketplace registration

**Files:**
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md` (repo root)

**Interfaces:**
- Consumes: `name: interviewer-bot`, `version: 0.1.0`, `description` (Task 1), `plugins/interviewer-bot/` path.
- Produces: the plugin becomes installable via `/plugin install interviewer-bot@cthomas-plugins`.

- [ ] **Step 1: Add the marketplace entry**

In `.claude-plugin/marketplace.json`, add a third object to the `plugins`
array (after `user-persona-generator`):

```json
    {
      "name": "interviewer-bot",
      "source": "./plugins/interviewer-bot",
      "description": "An adaptive mock-interview coach: reads your resume and a job description, runs a realistic interview in the hiring company's voice, and hands you a private performance review with rewritten answers.",
      "version": "0.1.0",
      "author": {
        "name": "Craig"
      },
      "keywords": ["interview-prep", "mock-interview", "career", "behavioral-interview", "star-method"]
    }
```

Remember to add a trailing comma after the `user-persona-generator` entry's
closing `}` so the array stays valid JSON.

- [ ] **Step 2: Validate the marketplace file is well-formed JSON**

Run (PowerShell):
```
Get-Content ".claude-plugin/marketplace.json" -Raw | ConvertFrom-Json | Out-Null; if ($?) { "VALID" }
```
Expected output: `VALID`

- [ ] **Step 3: Add a row to the root README's plugin table**

In `README.md`, add a row to the `## Plugins` table (after the User
Persona Generator row):

```markdown
| **[Interviewer Bot](plugins/interviewer-bot/)** | An adaptive mock-interview coach: reads your resume and a job description, interviews you in the hiring company's voice across three phases, and hands you a private performance review with rewritten answers. | 0.1.0 |
```

And add an install line under the **Claude Code** section, after the
existing two `/plugin install` lines:

```
/plugin install interviewer-bot@cthomas-plugins
```

- [ ] **Step 4: Verify both files reference the new plugin**

Run:
```bash
grep -c "interviewer-bot" .claude-plugin/marketplace.json
grep -c "interviewer-bot" README.md
```
Expected: both commands output `1` or more.

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "feat: register interviewer-bot in the marketplace"
```

---

### Task 9: End-to-end structural verification

**Files:** none created — this task only reads and checks files from Tasks 1–8.

**Interfaces:**
- Consumes: every file produced in Tasks 1–8.
- Produces: a pass/fail confirmation that the plugin is internally consistent, matching the spec's "Verification for this cycle" list.

There is no automated test runner for prose/skill content in this repo, so
this task is a scripted structural check followed by one manual read-through.

- [ ] **Step 1: Confirm the full file tree exists**

Run:
```bash
find plugins/interviewer-bot -type f | sort
```
Expected output (7 files, in this order):
```
plugins/interviewer-bot/.claude-plugin/plugin.json
plugins/interviewer-bot/README.md
plugins/interviewer-bot/commands/interview.md
plugins/interviewer-bot/skills/interviewer/SKILL.md
plugins/interviewer-bot/skills/interviewer/references/persona-library.md
plugins/interviewer-bot/skills/interviewer/references/report-template.md
plugins/interviewer-bot/skills/interviewer/references/rubric.md
```

- [ ] **Step 2: Confirm no placeholder text was left behind**

Run:
```bash
grep -rniE "TBD|TODO|fill in|placeholder text" plugins/interviewer-bot/
```
Expected: no output (the literal string `{{placeholder}}` syntax in
`report-template.md` is intentional and won't match this pattern).

- [ ] **Step 3: Confirm version numbers agree across manifest and marketplace**

Run:
```bash
grep '"version"' plugins/interviewer-bot/.claude-plugin/plugin.json
grep -A2 '"name": "interviewer-bot"' .claude-plugin/marketplace.json | grep version
```
Expected: both show `0.1.0`.

- [ ] **Step 4: Manual read-through against the spec's 6 acceptance criteria**

Read `plugins/interviewer-bot/skills/interviewer/SKILL.md` and its three
reference files top to bottom and confirm each of these (from
`docs/superpowers/specs/2026-07-14-interviewer-bot-design.md`):

1. Missing-required-input handling is present and asks only once
2. Phase 2 explicitly forbids batching/previewing questions
3. Follow-up probing on incomplete STAR/vague answers is instructed
4. Hidden-evaluation discipline explicitly forbids printing or hinting at
   scores anywhere in-character
5. `/exit` is handled at any point and jumps to report generation
6. Missing company background leads to the Neutral persona with an
   explicit, stated degradation — never silent

- [ ] **Step 5: Recommend the real acceptance test to Craig**

Note in your final report to Craig that structural checks can't verify
conversational behavior — the true test is installing the plugin and
running one live `/interview` session (the sample JD/resume in the README
work well for this) to confirm the tone, pacing, and follow-up behavior
feel right in practice.

No commit needed for this task — it makes no file changes.
