# Travel-Radius Filtering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let hybrid/on-site job seekers set a zip code and travel-distance radius in their career profile, and have job-scout hard-exclude postings outside that radius while disclosing the exclusion count.

**Architecture:** This plugin has no application code — each "component" is a prose instruction file (`SKILL.md`) that Claude reads and follows at conversation time. Implementation means editing those instructions precisely, plus the plugin/marketplace version manifests. There is no test runner; "testing" a task means reading the edited section back and confirming it says exactly what was intended, and checking file-wide consistency (versions match, no orphaned references).

**Tech Stack:** Markdown instruction files (`SKILL.md` with YAML frontmatter), JSON plugin manifests, `bump.ps1` (PowerShell), Git.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-06-travel-radius-design.md` — every requirement in it must map to a task below.
- Zip/radius question is asked **only** when the user's location/remote preference is hybrid or on-site; never for fully remote.
- Remote postings always bypass the travel-radius filter regardless of the user's zip.
- Vague/missing posting location → mark "unverified," never guess-exclude (matches the existing company-size filter precedent in job-scout).
- The travel-radius filter must never be silent — excluded-count is always disclosed in Output.
- No geocoding API/tool — distance estimation is conversational (the model's own geographic knowledge).
- Per-skill `SKILL.md` frontmatter versions bump independently: career-profile-setup 0.2.0 → 0.3.0, job-scout 0.5.0 → 0.6.0. `bump.ps1` sets the plugin-level version (0.6.0) in `plugin.json` and `marketplace.json`'s job-search-copilot entry only — `marketplace.json`'s top-level `metadata.version` (0.1.0) is never touched by `bump.ps1`.

---

### Task 1: career-profile-setup — capture zip code + travel radius

**Files:**
- Modify: `plugins/job-search-copilot/skills/career-profile-setup/SKILL.md`

**Interfaces:**
- Produces: `career-profile.md`'s `## Target` section gains two new optional lines, `Zip code (for travel-radius filtering)` and `Willing to travel`, positioned directly after `Locations / remote`. Task 2 (job-scout) reads these two lines by that exact label text.

- [ ] **Step 1: Update the "Before starting" section to handle existing profiles missing the new fields**

Open `plugins/job-search-copilot/skills/career-profile-setup/SKILL.md`. Find this exact paragraph under `## Before starting`:

```
Check the user's working folder for an existing `career-profile.md`. If one exists, summarize it and ask whether to update it rather than starting over. If no folder is connected, ask the user to connect one (via request_cowork_directory) so the profile persists across sessions; if they decline, save to the outputs folder and tell them to keep a copy.
```

Replace it with:

```
Check the user's working folder for an existing `career-profile.md`. If one exists, summarize it and ask whether to update it rather than starting over. If the existing profile already states a hybrid or on-site preference but has no zip code / travel-distance on file (e.g., saved before this field existed), ask for it as part of this update rather than leaving it missing. If no folder is connected, ask the user to connect one (via request_cowork_directory) so the profile persists across sessions; if they decline, save to the outputs folder and tell them to keep a copy.
```

- [ ] **Step 2: Update item 6 in "What to gather" to add the conditional follow-up question**

Find this exact line:

```
6. **Location & remote** — cities, willingness to relocate, remote/hybrid/onsite.
```

Replace it with:

```
6. **Location & remote** — cities, willingness to relocate, remote/hybrid/onsite. If hybrid or on-site, also ask for their zip code and how far they're willing to travel (e.g., "25 miles"). Skip this follow-up entirely for fully remote users — a commute radius is meaningless without a commute.
```

- [ ] **Step 3: Add the two new fields to the `career-profile.md` output schema**

Find this exact block inside the ` ```markdown ` fenced template under `## Output`:

```
## Target
- Roles: ...
- Domain: ...
- Seniority: ...
- Locations / remote: ...
- Company size: ...
```

Replace it with:

```
## Target
- Roles: ...
- Domain: ...
- Seniority: ...
- Locations / remote: ...
- Zip code (for travel-radius filtering): ... (only if hybrid/on-site — omit this line entirely for fully remote users)
- Willing to travel: ... miles (only if hybrid/on-site — omit this line entirely for fully remote users)
- Company size: ...
```

- [ ] **Step 4: Bump the skill's frontmatter version**

Find:

```
metadata:
  version: "0.2.0"
---
```

Replace with:

```
metadata:
  version: "0.3.0"
---
```

- [ ] **Step 5: Verify the edits landed correctly**

Run:
```
grep -n "Zip code\|Willing to travel\|version:" plugins/job-search-copilot/skills/career-profile-setup/SKILL.md
```
Expected output includes:
```
10:  version: "0.3.0"
30:6. **Location & remote** — ... zip code and how far they're willing to travel ...
54:- Zip code (for travel-radius filtering): ...
55:- Willing to travel: ... miles ...
```
(exact line numbers may shift slightly — confirm the four pieces of content are present, not the literal numbers)

- [ ] **Step 6: Commit**

```bash
git add plugins/job-search-copilot/skills/career-profile-setup/SKILL.md
git commit -m "career-profile-setup 0.3.0: capture zip code and travel radius for hybrid/on-site users"
```

---

### Task 2: job-scout — travel-radius hard filter + disclosure

**Files:**
- Modify: `plugins/job-search-copilot/skills/job-scout/SKILL.md`

**Interfaces:**
- Consumes: `career-profile.md`'s `Zip code (for travel-radius filtering)` and `Willing to travel` lines from Task 1's schema (exact label text — read whichever of the two is present; if either is absent, the filter does not apply).
- Produces: an exclusion count for out-of-radius postings, consumed by the Output section's Coverage caveat in Step 3 below.

- [ ] **Step 1: Add the new "Travel-radius filter" section**

Find this exact block (the end of the Hard-requirements gate section, immediately before `## Output`):

```
Knocked-out postings never appear in the Top 10. In the Why column, lead with the blocker ("capped 4/10 — requires ServiceNow, unmet"), not the overlap.

## Output
```

Replace it with:

```
Knocked-out postings never appear in the Top 10. In the Why column, lead with the blocker ("capped 4/10 — requires ServiceNow, unmet"), not the overlap.

## Travel-radius filter

Applied whenever `career-profile.md` has both a zip code and a travel-distance radius on file (populated only for hybrid/on-site users — see career-profile-setup). If either field is missing, skip this filter entirely; it never applies to fully remote profiles.

- **Remote postings always bypass this filter** — a remote role has no location constraint regardless of the user's zip.
- **Hybrid/on-site postings**: estimate the distance between the user's zip code and the posting's stated city/area using your own geographic knowledge. No geocoding tool or web search call — an approximate straight-line estimate is sufficient for a radius cutoff, not turn-by-turn precision.
- **Beyond the stated radius** — exclude the posting from the ranked table entirely, same as any other hard filter.
- **Location too vague to estimate** (e.g., posting only says "United States," or omits location) — do not guess-exclude. Keep the posting in the table and mark its distance as "unverified," the same treatment the company-size filter above uses when data is missing.

Never apply this filter silently: track how many postings were excluded so the count can be disclosed in Output.

## Output
```

- [ ] **Step 2: Verify the new section's placement**

Run:
```
grep -n "^## " plugins/job-search-copilot/skills/job-scout/SKILL.md
```
Expected: `## Travel-radius filter` appears once, between `## Hard-requirements gate (knockout pass)` and `## Output`.

- [ ] **Step 3: Add exclusion-count disclosure to the Coverage caveat**

Find this exact line inside `## Output`, item 4:

```
4. **Coverage caveat — always include** (in the About sheet and when presenting results): keyword search cannot see everything the user sees on LinkedIn while logged in. Promoted listings and personalized "recommended for you" roles surface through LinkedIn's paid placement and recommendation systems, not keyword search — so a role the user spotted in their own feed may legitimately be absent here. Suggest pasting such postings as seed URLs to get them scored.
```

Replace it with:

```
4. **Coverage caveat — always include** (in the About sheet and when presenting results): keyword search cannot see everything the user sees on LinkedIn while logged in. Promoted listings and personalized "recommended for you" roles surface through LinkedIn's paid placement and recommendation systems, not keyword search — so a role the user spotted in their own feed may legitimately be absent here. Suggest pasting such postings as seed URLs to get them scored. If the travel-radius filter excluded any postings this run, state the count here too — nothing about that filter is silent.
```

- [ ] **Step 4: Bump the skill's frontmatter version**

Find:

```
metadata:
  version: "0.5.0"
---
```

Replace with:

```
metadata:
  version: "0.6.0"
---
```

- [ ] **Step 5: Verify the edits landed correctly**

Run:
```
grep -n "Travel-radius filter\|excluded any postings\|version:" plugins/job-search-copilot/skills/job-scout/SKILL.md
```
Expected output includes the new section heading, the disclosure sentence appended to item 4, and `version: "0.6.0"`.

- [ ] **Step 6: Commit**

```bash
git add plugins/job-search-copilot/skills/job-scout/SKILL.md
git commit -m "job-scout 0.6.0: add travel-radius hard filter with exclusion disclosure"
```

---

### Task 3: Version bump (plugin/marketplace) and changelog

**Files:**
- Modify: `plugins/job-search-copilot/.claude-plugin/plugin.json` (via `bump.ps1`)
- Modify: `.claude-plugin/marketplace.json` (via `bump.ps1`)
- Modify: `README.md`

**Interfaces:**
- Consumes: `bump.ps1` at repo root (already fixed this session — text-replace only, no JSON reformatting; verified safe to run repeatedly).

- [ ] **Step 1: Run the version bump**

From the repo root:
```
powershell -NoProfile -File .\bump.ps1 0.6.0
```
Expected output:
```
plugin.json       : 0.5.0 -> 0.6.0
marketplace.json  : 0.5.0 -> 0.6.0

Both files staged. Reminder: add a changelog line to README.md, then:
  git add README.md
  git commit -m "bump to 0.6.0"
  git push
```

- [ ] **Step 2: Verify only the version lines changed (no reformatting)**

Run:
```
git diff --staged -- plugins/job-search-copilot/.claude-plugin/plugin.json .claude-plugin/marketplace.json
```
Expected: each file shows exactly one changed line (`"version": "0.5.0"` → `"version": "0.6.0"`), no BOM, no reindentation, no other lines touched. `marketplace.json`'s `metadata.version` (0.1.0) must not appear in the diff at all.

- [ ] **Step 3: Add the changelog entry**

In `README.md`, find:

```
## Changelog

- **0.5.0** — Dice is now offered as a job-scout source only for users who identify as technology professionals (asked once, saved to career profile).
```

Replace with:

```
## Changelog

- **0.6.0** — hybrid/on-site users can set a zip code and travel radius; job-scout filters out-of-radius postings and discloses how many were excluded.
- **0.5.0** — Dice is now offered as a job-scout source only for users who identify as technology professionals (asked once, saved to career profile).
```

- [ ] **Step 4: Verify version consistency across the whole repo**

Run:
```
grep -rn "version" plugins/job-search-copilot/.claude-plugin/plugin.json .claude-plugin/marketplace.json plugins/job-search-copilot/skills/job-scout/SKILL.md plugins/job-search-copilot/skills/career-profile-setup/SKILL.md
```
Expected:
```
plugin.json:                          "version": "0.6.0"
marketplace.json (plugin entry):      "version": "0.6.0"
marketplace.json (metadata):          "version": "0.1.0"   <- unchanged, expected
job-scout/SKILL.md:                   version: "0.6.0"
career-profile-setup/SKILL.md:        version: "0.3.0"
```

- [ ] **Step 5: Commit**

```bash
git add plugins/job-search-copilot/.claude-plugin/plugin.json .claude-plugin/marketplace.json README.md
git commit -m "bump to 0.6.0: travel-radius filtering"
```

---

### Task 4: Final consistency pass

**Files:** none modified — read-only verification across the whole plugin.

- [ ] **Step 1: Re-read both edited SKILL.md files in full**

Read `plugins/job-search-copilot/skills/career-profile-setup/SKILL.md` and `plugins/job-search-copilot/skills/job-scout/SKILL.md` top to bottom. Confirm:
- No leftover placeholder text or contradictory instructions.
- The zip-code/radius field names are spelled identically in both files (`Zip code (for travel-radius filtering)` and `Willing to travel`) — a mismatch here means job-scout silently fails to find the fields career-profile-setup wrote.

- [ ] **Step 2: Confirm working tree is clean**

Run:
```
git status --short
```
Expected: no output (everything committed) other than the two prior spec/plan doc commits already in history.

- [ ] **Step 3: Report back to the user**

Summarize what changed and the new version numbers, and confirm the branch is ready for the push the user asked for at the start of this session.
