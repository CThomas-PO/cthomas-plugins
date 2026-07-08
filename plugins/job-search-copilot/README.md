# Job Search Copilot

A conversational job-search assistant for any job seeker. Six skills that share one career profile, so you explain yourself once and every skill builds on it.

## Skills

| Skill | What it does | Say something like |
|---|---|---|
| **career-profile-setup** | One-time intake: resume, target role, domain, preferences. Saves `career-profile.md` that every other skill reuses. | "Set up my career profile" |
| **linkedin-profile-optimizer** | Gap analysis of headline/About/Experience (missing keywords, identity framing, buried credentials), then recruiter-search-optimized rewrites. | "Optimize my LinkedIn profile" |
| **job-scout** | Scrapes recent LinkedIn postings for your role (via Apify), filters by company size and domain, fit-scores each 1–10 against your resume, flags the top 10. | "Find product owner jobs posted this week" |
| **ats-resume-optimizer** | Parses a job description like an ATS, rewrites your bullets to mirror its language honestly, scores before/after match, flags keyword stuffing. | "Tailor my resume to this JD" |
| **network-mapper** | From your LinkedIn connections export: 1st-degree contacts at a target company, inferred warm paths, per-contact message templates. Includes the data-export walkthrough. | "Who do I know at Siemens Energy?" |
| **content-engine** | 10 post ideas across 4 pillars (hook + angle + format), sequenced over 4 weeks so authority-building precedes outreach. | "Build my LinkedIn content plan" |

## Setup

1. **Connect a working folder** — the plugin saves your career profile, rewrites, and calendars there so they persist.
2. **Apify (for job-scout)** — the plugin bundles Apify's hosted MCP server (`https://mcp.apify.com`). First use prompts an OAuth login; a free Apify account works. LinkedIn job scrapes typically cost well under $1 per run. Without Apify, job-scout falls back to official Indeed/ZipRecruiter/Dice connectors or manually pasted postings.
3. **LinkedIn data export (for network-mapper)** — the skill walks you through Settings → Data privacy → Get a copy of your data.

## Suggested flow

career-profile-setup → linkedin-profile-optimizer → job-scout → ats-resume-optimizer (per application) → network-mapper (per target company) → content-engine (running throughout).

## Principles

Every skill asks clarifying questions rather than guessing, never fabricates facts about you, and tells you when data has limits (e.g., a connections export can't truly see 2nd-degree networks — it says so and shows you how to verify).

## Changelog

- **0.9.0** — content-engine now generates 10 LinkedIn post ideas sequenced over 4 weeks (was 90 over 90 days) — same 4 pillars, less overwhelming to act on.
- **0.8.1** — job-scout now explicitly asks the user to connect a working folder before saving output if none is connected yet, since saved job descriptions only persist across sessions with one.
- **0.8.0** — job-scout now saves the full job description for every posting to job-descriptions/ in the working folder, keyed by a stable Job ID shown in the results table; ats-resume-optimizer reads from that store first instead of asking you to re-paste a JD it already pulled.
- **0.7.0** — job-scout fit-scoring now requires the full job description (no more scoring off truncated snippets), weights core-role fit far above surface keyword overlap so a genuine core gap can't produce an inflated score, and shows the drivers and gaps behind every score.
- **0.6.0** — hybrid/on-site users can set a zip code and travel radius; job-scout filters out-of-radius postings and discloses how many were excluded.
- **0.5.0** — Dice is now offered as a job-scout source only for users who identify as technology professionals (asked once, saved to career profile).
- **0.4.0** — job-scout asks whether the user has found postings anywhere — feed, recruiter email, wherever — to include as seeds. One question folded into an existing checkpoint, no extra back-and-forth.
- **0.3.0** — job-scout adds a hard-requirements knockout gate: parses full job descriptions for mandatory gates (platforms, clearances, credentials, years), caps unmet-Required postings at 4/10 with quoted evidence, and adds Hard Requirements / Blockers / Stretch columns.
- **0.2.0** — job-scout now shows a checkbox picker of job sources (LinkedIn via Apify, Indeed, ZipRecruiter, Dice) with live connection status, plus multi-source dedup and a Source column in results.
- **0.1.0** — initial release: six skills, shared career profile, Apify-powered LinkedIn job scraping.

*To update an installed plugin, see [How do I get the latest version?](../../docs/GETTING-STARTED.md#troubleshooting--faq)*
