# Job Search Copilot for Claude

**An AI job-search assistant that runs inside Claude.** Six skills that share one career profile — explain yourself once, then: get your LinkedIn profile rewritten for recruiter search, find and fit-score fresh job postings, tailor your resume to any job description without keyword stuffing, map warm intros into target companies, and run a 90-day LinkedIn content plan that builds authority before you start outreach.

![Job Search Copilot in action](docs/images/06-job-scout-results.png)

## What's inside

| Skill | Say something like | You get |
|---|---|---|
| **Career profile setup** | "Set up my career profile" | A one-time intake — resume, target role, preferences — every other skill reuses |
| **LinkedIn profile optimizer** | "Optimize my LinkedIn profile" | Gap analysis + headline/About rewrites, optimized for recruiter search |
| **Job scout** | "Find product manager jobs posted this week" | Ranked table of fresh postings, fit-scored 1–10 against your resume, top 10 flagged |
| **ATS resume optimizer** | "Tailor my resume to this JD" | ATS keyword extraction, honest bullet rewrites, before/after match score |
| **Network mapper** | "Who do I know at [company]?" | 1st-degree contacts, warm-intro paths, ready-to-send messages from your LinkedIn connections export |
| **Content engine** | "Build my LinkedIn content plan" | 90 post ideas (hook + angle + format) across 4 pillars, sequenced over 90 days |

Every skill asks before it guesses, never invents facts about you, and is honest about its data's limits.

## Install

You'll need the [Claude desktop app](https://claude.ai/download) with Cowork mode.

1. Open **Customize → Plugins**
2. Click **+** → **Add from a repository**
3. Paste: `https://github.com/CThomas-PO/cthomas-plugins`
4. Install **job-search-copilot**, open a Cowork session, and say *"set up my career profile"*

Using Claude Code instead?

```
/plugin marketplace add CThomas-PO/cthomas-plugins
/plugin install job-search-copilot@cthomas-plugins
```

📖 **[Full illustrated guide →](docs/GETTING-STARTED.md)** — step-by-step setup with screenshots, including the one-time Apify connection for job scraping (free, no credit card).

## Costs

The plugin is free. Job scraping runs on [Apify](https://apify.com)'s free tier ($5 usage credit monthly, no card required — typical searches cost pennies). Everything else uses your existing Claude subscription.

## Changelog

- **0.4.0** — job-scout asks whether the user has found postings anywhere — feed, recruiter email, wherever — to include as seeds. One question folded into an existing checkpoint, no extra back-and-forth..
- **0.3.0** — job-scout adds a hard-requirements knockout gate: parses full job descriptions for mandatory gates (platforms, clearances, credentials, years), caps unmet-Required postings at 4/10 with quoted evidence, and adds Hard Requirements / Blockers / Stretch columns.
- **0.2.0** — job-scout now shows a checkbox picker of job sources (LinkedIn via Apify, Indeed, ZipRecruiter, Dice) with live connection status, plus multi-source dedup and a Source column in results.
- **0.1.0** — initial release: six skills, shared career profile, Apify-powered LinkedIn job scraping.

*To update an installed plugin, see [How do I get the latest version?](docs/GETTING-STARTED.md#troubleshooting--faq)*

## About this repository

This repo is a Claude plugin marketplace — add it once and you can install any plugin published here, with updates delivered on every sync. Plugin source lives in [`plugins/`](plugins/), and the catalog is [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json).
