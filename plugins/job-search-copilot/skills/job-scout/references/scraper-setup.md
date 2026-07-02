# Scraper setup & cost guidance

## Apify MCP (primary — LinkedIn coverage)

The plugin bundles the Apify hosted MCP server (`https://mcp.apify.com`). On first use the user authenticates via OAuth with a free Apify account (apify.com — free tier includes monthly platform credit).

### Choosing an actor

Search the Apify store for "linkedin jobs scraper". Selection criteria, in order:
1. Pay-per-result pricing (predictable; typical range $0.40–$1.50 per 1,000 job results as of mid-2026).
2. No LinkedIn session cookies required (avoid actors that ask for the user's LinkedIn login — account-ban risk).
3. Supports filters: keyword/title, location, date-posted window, and ideally company attributes.

Known-good candidates (verify in-store before running; actors change):
- `valig/linkedin-jobs-scraper` (~$0.40/1k)
- `curious_coder/linkedin-jobs-scraper`
- `fetchclub/linkedin-jobs-scraper` (rental model, ~$19.99/mo — better above ~3k results/month)

### Cost etiquette

Always tell the user the estimated cost before a run ("100 results ≈ $0.04–$0.15"). Cap results by default (100). Never loop a scraper unbounded.

### Terms-of-service note

Scraping LinkedIn is against LinkedIn's ToS even when done via third-party actors that access public data. Actors that don't use the user's cookies keep THEIR account out of the loop, but the user should know the data source operates in a gray area. Mention this once, briefly, the first time they use job-scout; don't nag.

## Official job-board connectors (fallback — free, official)

Available in the Claude connector directory; suggest via connector suggestion tools:
- **Indeed** — `search_jobs`, `get_job_details`
- **ZipRecruiter** — `search_jobs`
- **Dice** — `search_jobs` (tech roles)

These are official APIs: free, ToS-clean, but no LinkedIn postings and generally no company-size filter (apply that filter post-hoc, same as with Apify).

## Manual fallback

The user pastes job posting text or URLs; fetch URLs with web fetch where permitted, then rank normally. Ranking quality is identical — only sourcing differs.
