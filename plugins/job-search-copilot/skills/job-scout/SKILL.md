---
name: job-scout
description: >
  This skill should be used when the user asks to "find jobs", "scrape
  LinkedIn jobs", "what roles were posted this week", "search for [role]
  postings", or wants a ranked list of recent job postings matched and
  fit-scored against their background.
metadata:
  version: "0.6.0"
---

# Job Scout

Find fresh job postings for the user's target role, filter to their preferences, score each against their resume, and flag the top 10 to apply to immediately.

## Inputs

Load `career-profile.md` from the working folder for: target role titles, domain, company-size preference, locations, and the resume. If missing, gather the minimum conversationally: role, location/remote, company size, domain, and ask for their resume (needed for fit scoring — without it, say scores will be keyword-only and less reliable).

**Broaden title variants by default.** A single title under-searches: postings for the same job carry different labels ("Product Owner" vs "Product Manager" vs "Technical Product Manager"; "Data Analyst" vs "Business Intelligence Analyst"). Build the query set from every role title in the career profile PLUS common synonyms and seniority-prefixed variants of each. Show the user the expanded list in the parameter confirmation so they can prune it; deduplication (below) absorbs the overlap between queries. Narrow only if the user explicitly asks for exact-title matching.

**Seed URLs.** Accept a list of specific LinkedIn job URLs from the user ("also score these"). Fetch each posting's full description, run it through the same fit scoring and hard-requirements gate, and include it in the ranked table with Source = "seed". Seeds are always deep-parsed (the user is explicitly considering them), are exempt from the posted-within window (flag their age instead), and count toward Top 10 eligibility like any other posting.

## Source selection

Before searching, detect which sources are actually available in this session, then let the user choose with a multi-select AskUserQuestion (checkboxes).

**Step 0 — Technology-professional check (Dice eligibility).** Dice is a tech-focused board and is only offered to users who identify as technology professionals. Check `career-profile.md`'s Target section for a "Technology professional" field:

- **Present** — read it silently; no question asked.
- **Absent** — ask a single yes/no question in the same batch as source selection: "Are you a technology professional? This determines whether Dice — a tech-focused job board — is offered as a source." If answered, write `- Technology professional (for Dice eligibility): yes/no` into `career-profile.md`'s Target section immediately. If skipped or declined, don't persist anything — treat as unknown for this run only (Dice hidden this run; ask again next run).

**Step 1 — Detect availability.** Check the session's available tools:

- **LinkedIn (via Apify)**: available if the plugin's Apify MCP tools are loaded and authenticated (tools from the bundled `apify` server, e.g. actor search/call tools). If the server is present but unauthenticated, treat as "requires one-time setup".
- **Indeed / ZipRecruiter / Dice**: available if their connector tools (e.g. `search_jobs`) are loaded. If not connected, treat as "requires connecting" — these are free official connectors from the connector directory. Dice is further gated by Step 0 — only check its availability at all if the user is a known or newly-confirmed technology professional.

**Step 2 — Ask.** Present one multiSelect question, "Which job sources should I search?", with an option per source. Omit Dice entirely (not greyed-out, not listed as unavailable — simply absent) unless Step 0 resolved to "yes" for this run. Reflect live status in each remaining label and description — for example:

- "LinkedIn (via Apify) ✓ connected" / "LinkedIn (via Apify) — needs one-time setup (free)". Description: broadest coverage; scraping costs pennies per run, estimated before running. If setup is needed: selecting this starts a one-time free Apify connection (no credit card).
- "Indeed ✓ connected" / "Indeed — needs connecting (free, official)". Similar for ZipRecruiter and, when eligible, Dice.

Mark connected sources as recommended. Never present an unavailable source as silently ready — the status must be in the label so there are no surprises after selection.

**Step 3 — Handle the selection.**

- Connected sources: proceed.
- LinkedIn selected but Apify not set up: walk through the one-time connection (OAuth via the bundled Apify server; free account, no credit card — see `references/scraper-setup.md`). If the user declines or gets stuck, continue with any other selected sources and say what was skipped.
- Job board selected but not connected: suggest the connector via the connector directory tools, then proceed once connected.
- Nothing selected or nothing connectable: offer the manual fallback — the user pastes postings or URLs, and ranking proceeds normally.

**Searching LinkedIn via Apify**: search the Apify store for a LinkedIn jobs actor; prefer pay-per-result actors that don't require LinkedIn cookies. Pass role, location, and posted-time filter. Surface expected cost to the user BEFORE running (see `references/scraper-setup.md` for actor selection and cost guidance).

Confirm search parameters before spending scraper credits: role title(s) including the expanded variant list, posted-within window (default 7 days), location, company size, result cap (default 100). In the same confirmation, ask whether the user has any specific postings they've already found — links from their LinkedIn feed, a recruiter email, anywhere — to include as seed URLs for scoring.

**Company-size filter caveat**: job scrapers rarely return employee counts. Apply the size filter via the company data the scraper does return; where absent, look up ambiguous companies with web search before excluding them, and mark size as "unverified" rather than guessing.

**Multi-source runs**: deduplicate postings that appear on multiple boards (same company + title + location); keep the row once and note all sources in it.

## Fit scoring (1–10)

Score each posting against the resume with this rubric — apply it consistently so scores are comparable:

- **Skills & keywords match (0–4)**: fraction of the posting's must-have skills present in the resume.
- **Domain match (0–2)**: same industry/domain = 2; adjacent = 1; unrelated = 0.
- **Seniority & title match (0–2)**: level fits their trajectory (neither a step down nor an unrealistic jump).
- **Logistics (0–1)**: location/remote and company size fit stated preferences.
- **Freshness (0–1)**: posted ≤3 days = 1 (early applicants get disproportionate recruiter attention).

State the score drivers in one short phrase per job ("9/10 — exact title, IoT domain, posted yesterday").

This rubric measures **overlap** — what the resume and posting share. It cannot see **gating** — mandatory requirements the user does not meet. Every rubric score must therefore pass through the hard-requirements gate below before it is final.

## Hard-requirements gate (knockout pass)

Keyword overlap makes a posting look good; one unmet line in its Required section can make it an auto-reject. Titles hide gates — a "Product Manager" posting may require "3+ years ServiceNow" in its body. Read the body.

**Efficiency — don't deep-parse everything.** First compute preliminary rubric scores for all results from title/snippet data. Then deep-parse the full `jobDescription` for the top ~30 by preliminary score (only they can reach the Top 10). If full descriptions are already in hand for all results, additionally run a cheap keyword prefilter across the rest — platform names, "clearance", "citizen", "certified", "license", "CPA", "PMP", "PhD", "years of" — and deep-parse anything it flags. A knockout hiding at preliminary rank 40 still deserves its cap.

**Step 1 — Extract.** From the full `jobDescription`, pull every hard requirement and tag its `type`:

- `platform` — named tools/platforms (ServiceNow, Salesforce, SAP, Workday, Guidewire, Pega, NetSuite, and similar)
- `clearance` — security clearance or citizenship/work-authorization requirements
- `regulatory` — mandated regulatory/domain knowledge (GAAP, ASC 606, IFRS, HIPAA, FDA)
- `credential` — hard credentials (CPA, PMP, MBA, specific degree or PhD, professional license)
- `years` — minimum years in a *specific* area ("5+ years pricing analytics")
- `location` — hidden onsite/location constraints in the body that contradict the listing header
- `industry` — mandated industry experience ("must have P&C insurance background")

**Step 2 — Section.** Record where each requirement appeared: `required` (Required/Qualifications/Minimum sections, or "must have" phrasing) vs `preferred` (Preferred/Nice-to-have/Bonus). Only Required items can block; unmet Preferred items are stretch, never blockers.

**Step 3 — Classify** each requirement against `career-profile.md`: `met`, `partial` (has it, but short of the stated bar), `unmet`, or `unknown`. If the profile doesn't address it, use `unknown` — **never assume met**. For every `unmet` Required item, quote the exact line from the posting as `evidence`.

**Step 4 — Knockout.** Record per posting:

```json
{
  "hard_requirements": [
    {"text": "3+ yrs ServiceNow (APM/CSM/ITSM/HRSD)", "type": "platform",
     "section": "required", "status": "unmet",
     "evidence": "3+ years of proven experience in ServiceNow"}
  ],
  "blockers": ["No ServiceNow — hard platform gate in Required section"],
  "stretch": [],
  "knockout": true,
  "capped_score": 4
}
```

If a posting has one or more `unmet` Required hard gates: set `knockout: true` and **cap the fit score at 4** (final = min(rubric score, 4)), regardless of keyword match. `unknown` and `partial` items do NOT trigger knockout — list them in the Hard Requirements column with `?` / `~` markers so the user can judge. Postings with no unmet Required gates keep their rubric score untouched — the gate only caps, never boosts or re-weights.

Knocked-out postings never appear in the Top 10. In the Why column, lead with the blocker ("capped 4/10 — requires ServiceNow, unmet"), not the overlap.

## Travel-radius filter

Applied whenever `career-profile.md` has both a zip code and a travel-distance radius on file (populated only for hybrid/on-site users — see career-profile-setup). If either field is missing, skip this filter entirely; it never applies to fully remote profiles.

- **Remote postings always bypass this filter** — a remote role has no location constraint regardless of the user's zip.
- **Hybrid/on-site postings**: estimate the distance between the user's zip code and the posting's stated city/area using your own geographic knowledge. No geocoding tool or web search call — an approximate straight-line estimate is sufficient for a radius cutoff, not turn-by-turn precision.
- **Beyond the stated radius** — exclude the posting from the ranked table entirely, same as any other hard filter.
- **Location too vague to estimate** (e.g., posting only says "United States," or omits location) — do not guess-exclude. Keep the posting in the table and mark its Distance column as "unverified," the same treatment the company-size filter above uses when data is missing.
- **Distance column values**: "remote" for remote postings, the estimated distance (e.g., "12 mi") for in-radius hybrid/on-site postings, "unverified" for vague/missing locations.

Never apply this filter silently: track how many postings were excluded so the count can be disclosed in Output.

## Output

1. Ranked table (all results): Company | Role | Location | Distance | Salary (or "not listed") | Posted | Source | Size | Fit score | Why | Hard Requirements | Blockers (unmet required) | Stretch (unmet preferred).
2. **Top 10 — apply now**: flagged subset with a one-line action note each (e.g., "referral possible — run network-mapper for Siemens Energy"). Knockouts are ineligible.
3. Save as `job-scout-YYYY-MM-DD.xlsx` (use the xlsx skill) with the full table plus a Top 10 sheet; present the file.
4. **Coverage caveat — always include** (in the About sheet and when presenting results): keyword search cannot see everything the user sees on LinkedIn while logged in. Promoted listings and personalized "recommended for you" roles surface through LinkedIn's paid placement and recommendation systems, not keyword search — so a role the user spotted in their own feed may legitimately be absent here. Suggest pasting such postings as seed URLs to get them scored. If the travel-radius filter excluded any postings this run, state the count here too — nothing about that filter is silent.

Never fabricate postings, salaries, or posting dates. If a field wasn't returned, say "not listed". Offer follow-ups: run ats-resume-optimizer against a top posting's JD, run network-mapper on top companies, or schedule this search to re-run weekly.
