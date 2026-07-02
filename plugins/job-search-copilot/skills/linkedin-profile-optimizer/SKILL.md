---
name: linkedin-profile-optimizer
description: >
  This skill should be used when the user asks to "optimize my LinkedIn
  profile", "review my LinkedIn", "rewrite my headline", "improve my About
  section", "why am I not showing up in recruiter searches", or wants a gap
  analysis of their LinkedIn headline, About, and Experience sections.
metadata:
  version: "0.1.0"
---

# LinkedIn Profile Optimizer

Audit a LinkedIn profile against the user's target role, find the gaps that hide them from recruiters, then rewrite the headline and About section for recruiter search.

## Inputs

1. Load `career-profile.md` from the working folder. If missing, offer to run career-profile-setup first (strongly recommended — the audit is only as good as the target).
2. Get the profile content. Ask the user to either paste their headline, About, and Experience sections, or attach their profile PDF (LinkedIn: profile page → More → Save to PDF). Do not attempt to scrape their profile.

## Phase 1 — Gap analysis

Audit three sections against the target role. Recruiters find candidates via LinkedIn Recruiter keyword search, so think like the search engine first and the human reader second.

**Headline (220 chars):**
- Missing keywords: does it contain the exact target job title and top 3–5 skills recruiters search? Title synonyms count ("Product Manager" ≠ "Product Owner" in search).
- Identity framing: does it declare the CURRENT identity or the TARGET identity? "Aspiring X" and employer-centric framing ("Product Owner at Siemens") both underperform capability framing.
- Wasted characters: buzzwords ("passionate", "results-driven"), emoji chains, vague slogans.

**About:**
- First 3 lines (visible before "see more"): do they hook and position, or warm up slowly?
- Keyword coverage: About is fully indexed by recruiter search — list target-role keywords that are absent.
- Buried credentials: quantified wins, certifications, notable employers/products hidden in paragraph 4+ or missing entirely. Cross-reference the signature accomplishments in career-profile.md.
- Identity framing: written as autobiography ("I started my career in...") vs. positioning ("I do X for Y, evidenced by Z").

**Experience:**
- Each role: title-only vs. accomplishment bullets; keywords per role; numbers.
- Do job titles match searchable titles? (Internal titles like "Product Owner III – Stream Alpha" can be reframed within honesty limits, e.g. "Product Owner (Senior)".)

Present findings as a scorecard: each section rated ⚠️ gaps found / ✅ strong, with the specific missing keywords listed. Be direct — a polite audit is a useless audit.

## Phase 2 — Rewrite

Rewrite headline and About (Experience bullets only if the user asks — offer it).

**Headline formula:** `Target Title | Domain + scale proof | Top skills/keywords`. Front-load the target title. Use all ~220 chars. No "aspiring", no "seeking opportunities" (unless search is public and user prefers the Open-to-Work signal — ask).

**About structure:**
1. Hook (lines 1–3): sharpest positioning claim + biggest number. Must survive the "see more" fold.
2. Proof: 2–3 signature accomplishments with metrics, naturally weaving in target keywords.
3. How they work / domain POV: 1 short paragraph.
4. Keyword-rich specialties line ("Specialties: ...") — this is legitimate for search, keep it to one line.
5. CTA appropriate to their search status (open to conversations vs. quietly exploring — check confidentiality flag in career-profile.md).

**Rules:**
- Every claim traces to the resume or user-provided facts. Never inflate.
- Voice: first person, plain language, no third-person corporate bio.
- Show before/after side by side and explain WHY each change helps recruiter search, so the user learns the mechanics.

## Output

Save `linkedin-profile-rewrite.md` to the working folder containing: the gap-analysis scorecard, before/after headline, before/after About, and a keyword checklist for Experience. Offer to also rewrite Experience bullets or run job-scout next.
