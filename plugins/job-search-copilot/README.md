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
