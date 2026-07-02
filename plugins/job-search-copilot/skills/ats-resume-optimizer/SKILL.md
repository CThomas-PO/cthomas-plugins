---
name: ats-resume-optimizer
description: >
  This skill should be used when the user asks to "tailor my resume to this
  job description", "run an ATS check", "will my resume pass the ATS",
  "match my resume to this JD", or provides a resume plus a job posting and
  wants keyword extraction, rewritten bullets, and a match score.
metadata:
  version: "0.1.0"
---

# ATS Resume Optimizer

Act as an ATS parser first, an editor second, and a human reviewer third. Extract what the system scans for, rewrite the resume to mirror that language naturally, and score the improvement — without fabricating anything or stuffing keywords.

## Inputs

Require both: (1) the resume — from `career-profile.md`'s stored location or attached fresh; (2) the job description — pasted or a URL to fetch. If either is missing, ask. If the user ran job-scout, offer to pull the JD from a flagged posting.

## Phase 1 — Parse like an ATS

Extract from the JD every token a screening system or recruiter keyword-search would use:

- **Hard skills & tools** (exact strings: "SAFe", "Jira", "SQL", "A/B testing")
- **Job titles** (the posted title + seniority markers)
- **Qualifications** (degrees, certifications, years of experience with numbers)
- **Domain terms** (industry vocabulary: "industrial automation", "claims processing")
- **Soft skills / competencies** (only ones stated in the JD)
- **Phrasing variants** that matter for exact-match scans ("Product Owner" vs "Product Manager", "stakeholder management" vs "stakeholder engagement")

Classify each as **must-have** (in requirements, repeated, or marked required) or **nice-to-have**. Present the extraction as a table before touching the resume.

## Phase 2 — Baseline match score

Score the current resume: percentage of must-have keywords present (exact or acceptable-variant match), plus nice-to-have coverage. Report as: `Before: 54% must-have (13/24), 30% nice-to-have`. List every missing must-have.

## Phase 3 — Rewrite

Rewrite resume bullets to close the gaps, under these constraints:

- **Truth is immovable.** Only claim skills/experience the user actually has. For each missing keyword, ask or infer from the resume whether they have real experience with it; if yes, work it into a real accomplishment; if no, leave it out and list it under "genuine gaps" (they may address it in a cover letter or interview).
- **Mirror the JD's exact phrasing** where the user's experience matches ("stakeholder engagement" → "stakeholder management" if that's the JD's term).
- **Keep accomplishments concrete**: action verb + what + measurable outcome. Don't flatten strong bullets into keyword soup.
- **Placement matters**: must-haves belong in the most recent 1–2 roles and the skills section, not buried in a 2015 job.
- Preserve the user's voice and any formatting constraints they state.

## Phase 4 — Score after + stuffing audit

1. Re-score: `After: 92% must-have (22/24)` and show the before/after delta.
2. **Keyword-stuffing audit** — flag anything a human reviewer would smell:
   - Any keyword appearing 3+ times
   - Bullets that list skills without an accomplishment attached
   - Phrasing that reads unnaturally ("Utilized Agile Scrum agile methodologies in an agile environment")
   - A skills section longer than ~2 lines of genuinely-held skills
   Rework flagged items before delivering; the goal is the highest match rate that still reads as written by a person.

## Output

Deliver: the keyword extraction table, before/after match scores, the rewritten resume as a .docx (use the docx skill; mirror the original's structure), a "genuine gaps" list, and the stuffing-audit notes (including what was reworked). Offer to repeat for the next JD — the Phase 1 extraction pattern makes reruns fast.
