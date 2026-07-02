# Craig's Claude Plugin Marketplace

A plugin marketplace for Claude (Cowork and Claude Code).

## Install

**Claude desktop / Cowork:** Customize → Plugins → + → **Add from a repository** → paste this repo's URL.

**Claude Code:**

```
/plugin marketplace add <your-github-username>/craig-plugins
/plugin install job-search-copilot@craig-plugins
```

## Plugins

### job-search-copilot

Six skills for job seekers, sharing one reusable career profile:

- **career-profile-setup** — one-time intake (resume, target role, preferences)
- **linkedin-profile-optimizer** — gap analysis + recruiter-search-optimized rewrites
- **job-scout** — scrape recent postings (Apify), fit-score 1–10, flag top 10
- **ats-resume-optimizer** — ATS keyword extraction, honest bullet rewrites, before/after match score
- **network-mapper** — warm paths into target companies from your LinkedIn connections export
- **content-engine** — 90 sequenced post ideas across 4 pillars

See the [plugin README](plugins/job-search-copilot/README.md) for setup (Apify connector, LinkedIn data export).
