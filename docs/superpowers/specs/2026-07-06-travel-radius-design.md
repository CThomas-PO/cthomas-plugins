# Travel-radius filtering for hybrid/on-site job seekers

**Date**: 2026-07-06
**Status**: Approved, pending implementation
**Plugin**: job-search-copilot

## Problem

career-profile-setup captures a "Locations / remote" preference (city, remote/hybrid/onsite), but nothing about how far a hybrid or on-site user is actually willing to commute. job-scout's Logistics scoring component (0–1 point) currently judges location fit only loosely, with no way to hard-exclude postings that are geographically out of reach.

## Goal

Let hybrid/on-site users specify a zip code and a travel-distance radius, and have job-scout exclude postings outside that radius — while staying fully transparent about what was filtered out and why.

## Capture (career-profile-setup)

- Trigger: only when the user's location/remote preference is **hybrid** or **on-site**. Fully-remote users are never asked — a commute radius is meaningless without a commute.
- Two new lines added to `career-profile.md`'s `## Target` section, populated only when applicable:
  ```
  - Locations / remote: ...
  - Zip code (for travel-radius filtering): 60601
  - Willing to travel: 25 miles
  ```
- Existing profiles that already say hybrid/on-site but predate this change: career-profile-setup's update flow (not job-scout) asks for the missing zip/radius the next time the user opens the profile for edits. It does not retroactively interrupt other skills mid-run.

## Usage (job-scout)

Applied as a hard filter, alongside the existing hard-requirements gate, whenever `career-profile.md` has both a zip code and a travel radius on file:

- **Remote postings always bypass the filter** — a remote role has no location constraint regardless of the user's zip.
- **Hybrid/on-site postings**: estimate the distance between the user's zip code and the posting's stated city/area using the model's own geographic knowledge. No geocoding tool or web search call — approximate is sufficient for a radius cutoff, not turn-by-turn precision.
- **Beyond the stated radius** → excluded from the ranked table entirely, same as any other hard filter.
- **Location too vague to estimate** (e.g. posting only says "United States," or omits location) → do not guess-exclude. Keep the posting in the table and mark its distance as "unverified," consistent with how the existing company-size filter already handles missing data.

## Transparency

Nothing about this filter is silent:

- job-scout's existing Coverage caveat in Output gains one addition: state how many postings were excluded by the travel-radius filter on this run.
- This follows the plugin's existing principle (already used for the coverage caveat and the hard-requirements gate's quoted evidence) of never hiding what was filtered or why.

## Out of scope

- No geocoding API integration — estimation is conversational/LLM-driven only.
- ZipRecruiter/Indeed/Dice/LinkedIn source selection is unaffected; this filter applies uniformly to postings from any source once fetched.
- No change to the Logistics (0–1) scoring rubric component itself — the radius filter is a pre-filter, not a rescoring of Logistics.

## Versioning

- `career-profile-setup/SKILL.md`: 0.2.0 → 0.3.0 (intake behavior changed)
- `job-scout/SKILL.md`: 0.5.0 → 0.6.0 (new hard filter + disclosure requirement)
- `bump.ps1 0.6.0` syncs `plugin.json` and `marketplace.json`
- `README.md` changelog: "0.6.0 — hybrid/on-site users can set a zip code and travel radius; job-scout filters out-of-radius postings and discloses how many were excluded."
