---
name: job-scout
description: >
  This skill should be used when the user asks to "find jobs", "scrape
  LinkedIn jobs", "what roles were posted this week", "search for [role]
  postings", or wants a ranked list of recent job postings matched and
  fit-scored against their background.
metadata:
  version: "0.1.0"
---

# Job Scout

Find fresh job postings for the user's target role, filter to their preferences, score each against their resume, and flag the top 10 to apply to immediately.

## Inputs

Load `career-profile.md` from the working folder for: target role titles, domain, company-size preference, locations, and the resume. If missing, gather the minimum conversationally: role, location/remote, company size, domain, and ask for their resume (needed for fit scoring — without it, say scores will be keyword-only and less reliable).

Confirm search parameters before spending scraper credits: role title(s), posted-within window (default 7 days), location, company size, result cap (default 100).

## Data source ladder

Work down this ladder; never silently skip a rung:

1. **Apify MCP connected** (tools named `mcp__apify__*` or similar): use a LinkedIn jobs actor. Search the Apify store for a LinkedIn jobs scraper (e.g. "linkedin jobs scraper"), prefer pay-per-result actors. Pass role, location, and posted-time filter. See `references/scraper-setup.md` for actor selection and cost guidance — surface expected cost to the user BEFORE running.
2. **Apify not connected**: tell the user LinkedIn scraping needs the Apify connector and point to the setup steps in `references/scraper-setup.md`. Offer the alternatives below in the meantime.
3. **Official job-board connectors**: Indeed, ZipRecruiter, and Dice MCP connectors are free and official (no LinkedIn coverage). Suggest connecting one via the connector directory.
4. **Manual**: user pastes job listings or URLs; proceed with ranking only.

**Company-size filter caveat**: job scrapers rarely return employee counts. Apply the size filter via the company data the scraper does return; where absent, look up ambiguous companies with web search before excluding them, and mark size as "unverified" rather than guessing.

## Fit scoring (1–10)

Score each posting against the resume with this rubric — apply it consistently so scores are comparable:

- **Skills & keywords match (0–4)**: fraction of the posting's must-have skills present in the resume.
- **Domain match (0–2)**: same industry/domain = 2; adjacent = 1; unrelated = 0.
- **Seniority & title match (0–2)**: level fits their trajectory (neither a step down nor an unrealistic jump).
- **Logistics (0–1)**: location/remote and company size fit stated preferences.
- **Freshness (0–1)**: posted ≤3 days = 1 (early applicants get disproportionate recruiter attention).

State the score drivers in one short phrase per job ("9/10 — exact title, IoT domain, posted yesterday").

## Output

1. Ranked table (all results): Company | Role | Location | Salary (or "not listed") | Posted | Size | Fit score | Why.
2. **Top 10 — apply now**: flagged subset with a one-line action note each (e.g., "referral possible — run network-mapper for Siemens Energy").
3. Save as `job-scout-YYYY-MM-DD.xlsx` (use the xlsx skill) with the full table plus a Top 10 sheet; present the file.

Never fabricate postings, salaries, or posting dates. If a field wasn't returned, say "not listed". Offer follow-ups: run ats-resume-optimizer against a top posting's JD, run network-mapper on top companies, or schedule this search to re-run weekly.
