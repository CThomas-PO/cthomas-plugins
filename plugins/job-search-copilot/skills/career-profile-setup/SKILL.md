---
name: career-profile-setup
description: >
  This skill should be used when the user wants to "set up my career profile",
  "start my job search", "get me set up", or runs any job-search-copilot skill
  for the first time without an existing career profile. It captures their
  resume, target role, domain, and preferences once, saving a reusable
  career-profile.md that all other job-search-copilot skills read.
metadata:
  version: "0.3.0"
---

# Career Profile Setup

Build a single source of truth about the job seeker so no other skill in this plugin has to re-ask the basics.

## Before starting

Check the user's working folder for an existing `career-profile.md`. If one exists, summarize it and ask whether to update it rather than starting over. If the existing profile already states a hybrid or on-site preference but has no zip code / travel-distance on file (e.g., saved before this field existed), ask for it as part of this update rather than leaving it missing. If no folder is connected, ask the user to connect one (via request_cowork_directory) so the profile persists across sessions; if they decline, save to the outputs folder and tell them to keep a copy.

## What to gather

Collect conversationally — batch related questions with AskUserQuestion, never interrogate one field at a time. Infer everything possible from documents before asking.

1. **Resume** — ask them to attach it (PDF, docx, or pasted text). Parse it fully: roles, dates, accomplishments, skills, education, certifications.
2. **Target role(s)** — exact titles they want (e.g., "Senior Product Manager", "Head of Product"). Capture 1–3 title variants.
3. **Domain/industry** — where their background gives them an edge (e.g., industrial IoT, fintech, healthcare SaaS).
4. **Seniority level** — IC, senior IC, manager, director+.
5. **Company preferences** — size range (employee count), stage, named target companies if any.
6. **Location & remote** — cities, willingness to relocate, remote/hybrid/onsite. If hybrid or on-site, also ask for their zip code and how far they're willing to travel (e.g., "25 miles"). Skip this follow-up entirely for fully remote users — a commute radius is meaningless without a commute.
7. **Compensation** — target base/total range (optional; note if declined).
8. **Timeline & confidentiality** — actively applying vs. exploring; is the search confidential from a current employer? (This changes advice in content-engine and network-mapper.)
9. **Differentiators** — 2–3 career wins they're proudest of, with numbers if possible.
10. **LinkedIn profile URL** (optional, used by linkedin-profile-optimizer).

## Output

Write `career-profile.md` to the user's working folder with these exact sections so other skills can parse it reliably:

```markdown
# Career Profile
Last updated: YYYY-MM-DD

## Target
- Roles: ...
- Domain: ...
- Seniority: ...
- Locations / remote: ...
- Zip code (for travel-radius filtering): ... (only if hybrid/on-site — omit this line entirely for fully remote users)
- Willing to travel: ... miles (only if hybrid/on-site — omit this line entirely for fully remote users)
- Company size: ...
- Target companies: ...
- Compensation target: ...
- Timeline: ...
- Confidential search: yes/no
- Technology professional (for Dice eligibility): yes/no (optional — populated lazily by job-scout the first time it's needed, not asked during this intake)

## Background summary
(3–5 sentence positioning summary written from the resume)

## Key skills & keywords
(comma-separated, ordered by relevance to target role)

## Signature accomplishments
- ...

## Resume
- Filename/location of the resume file

## LinkedIn
- Profile URL: ...
```

After saving, confirm to the user and suggest logical next steps: linkedin-profile-optimizer to fix their profile, or job-scout to find fresh postings.

## Rules

- Never invent facts about the user. Everything in the profile traces to their resume or their answers.
- If the resume and their stated target role are far apart (e.g., engineer targeting product management), note the gap in the Background summary — other skills use this for repositioning.
