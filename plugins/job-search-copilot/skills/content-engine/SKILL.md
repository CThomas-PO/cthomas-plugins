---
name: content-engine
description: >
  This skill should be used when the user asks for "LinkedIn post ideas",
  "a content plan for my job search", "10 post ideas", "build my LinkedIn
  presence", or wants a sequenced content calendar that builds authority
  with target companies before outreach begins.
metadata:
  version: "0.2.0"
---

# Content Engine

Generate 10 LinkedIn post ideas across four pillars, sequenced over 4 weeks so the first 1–2 weeks build authority before outreach to target companies begins.

## Inputs

Load `career-profile.md` for target role, target companies, domain, signature accomplishments, and the confidentiality flag. Then confirm two things with AskUserQuestion:

1. **Posting days** — which 2–3 days per week they want to post (10 ideas over 4 weeks averages to 2–3 posts/week). This sets calendar dates.
2. **Search visibility** — if the career profile marks the search confidential (or the user is employed and quiet about leaving), pillar 4 as "behind-the-scenes of my job search" would out them to their employer. Offer the safe swap: replace pillar 4 with "career lessons & reflections" (same vulnerability, zero flight-risk signal). Do not generate public job-search content for a confidential search without an explicit OK.

## The four pillars

Distribute ideas roughly 3/3/2/2 across the pillars below — 10 total:

1. **Builder credibility** — real things they've shipped, decisions made, metrics moved. Mine signature accomplishments; each accomplishment yields 3–5 ideas (the decision, the mistake, the metric, the teardown, the "what I'd do differently").
2. **Lessons from current role** — observations that only someone in their seat could make. Sanitize employer-confidential specifics.
3. **Domain POVs** — opinions about where their industry/discipline is going. These attract exactly the hiring managers at the target companies; angle several toward debates those companies visibly care about.
4. **Behind-the-scenes of the job search** (or the confidential-safe swap) — what they're learning, systems they've built, honest moments. Highest engagement pillar; sequence it late.

## Idea format

Every idea has exactly three parts:

- **Hook** — the actual first line, written out verbatim. It must survive the feed: specific, tension-carrying, no "I'm excited to share". Vary hook types (contrarian claim, number, confession, question, mini-story cold open).
- **Angle** — 1–2 sentences: the argument or story and why the target audience cares.
- **Format** — text post, text + image, carousel/document, poll, or short video. Match format to content (frameworks → carousel; opinions → text; decisions → poll).

## Sequencing

- **Weeks 1–2 (authority phase)**: pillars 1–3 only. Goal: when a hiring manager checks their profile post-outreach, the feed says "credible practitioner", not "job seeker". Start with 2–3 safest-but-strong builder posts, escalate toward POVs.
- **Weeks 3–4 (outreach phase)**: blend in pillar 4; keep pillars 1–3 running. Note in the calendar where network-mapper outreach waves should slot in, so posts and DMs reinforce each other.
- Weekly texture: don't stack two heavy formats back-to-back; place polls/questions before high-effort posts to warm engagement.

## Output

Save `content-calendar.xlsx` (use the xlsx skill): columns Day/Date | Pillar | Hook | Angle | Format | Phase, one sheet as the full calendar, one summarizing the strategy. Present the file, then offer: draft the first week's posts in full, or adjust pillar balance. Never invent accomplishments for post ideas — every builder-credibility idea must trace to the career profile.
