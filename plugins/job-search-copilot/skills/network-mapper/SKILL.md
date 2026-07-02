---
name: network-mapper
description: >
  This skill should be used when the user asks "who do I know at [company]",
  "find me a warm intro to [company]", "map my network", "analyze my LinkedIn
  connections", or wants outreach message templates for contacts at a target
  company. Works from the user's LinkedIn connections export (Connections.csv).
metadata:
  version: "0.1.0"
---

# Network Mapper

Given a target company, mine the user's LinkedIn connections export for 1st-degree contacts, plausible 2nd-degree warm paths, and per-contact message templates grounded in real shared history.

## Step 0 — Get the data

Look for `Connections.csv` in the working folder (also accept a full LinkedIn data archive; the file lives at its root). If absent, walk the user through the export, then continue in a later session or once they attach it:

1. LinkedIn → **Settings & Privacy** → **Data privacy** → **Get a copy of your data**
2. Choose **"Want something in particular?"** → check **Connections** (fast, ~10 minutes) — or **Download larger data archive** for everything (up to 24h; also unlocks messages/invitations history for richer templates)
3. LinkedIn emails a download link → save the CSV/ZIP into the connected folder

Note: the CSV includes First Name, Last Name, URL, Email (only if the contact allowed it), Company, Position, Connected On. The first ~3 rows are a notes header — skip them when parsing. Company/Position reflect the contact's CURRENT role as of export, and exports go stale: if the file is older than ~3 months, suggest a fresh one.

## Step 1 — 1st-degree contacts at the target

Parse the CSV (pandas; handle the header-notes offset and UTF-8 BOM). Match the target company with fuzzy logic: subsidiaries, abbreviations, "Inc/GmbH/AG" suffixes, and obvious rebrands. List every match: name, position, connected-on date, profile URL. Rank by usefulness — recruiters/talent team, hiring-manager-adjacent roles in the user's target function, then seniority, then recency of connection.

## Step 2 — 2nd-degree warm paths

Be honest about the data's limits: the export contains no 2nd-degree information. Approximate warm paths from what it does contain, and label them as inferences:

- **Alumni bridges**: 1st-degree contacts who previously held roles at the target (Position strings sometimes reveal this; also cross-check former-colleague overlap: contacts whose Company history matches the user's own past employers).
- **Ecosystem bridges**: contacts at the target's close partners, major vendors/customers, or direct competitors in the same domain — people statistically likely to know insiders.
- **Recruiter bridges**: agency/internal recruiters in the network who cover the target's industry.

For each bridge, state WHY they plausibly know someone inside and what to ask for. Tell the user the ground truth check: open the target company's LinkedIn page → "Connections that work here" shows true mutual connections; they can paste names back in for templates.

## Step 3 — Message templates

For each recommended contact, draft a message grounded in the shared history the data supports: connected-on era ("we connected back in 2019 around..."), shared employer, same function, or same domain. Use the four patterns in `references/message-templates.md` (reconnect-then-ask, direct ask, intro request, recruiter note). Rules: under 100 words, one clear ask, no "I hope this finds you well", no fake familiarity — if the data shows no real shared history, the template must honestly say "we're connected on LinkedIn and I'm reaching out because...". Respect the confidentiality flag in career-profile.md (no "I'm actively looking" language if the search is confidential).

## Output

Save `network-map-<company>.md` to the working folder: 1st-degree table, warm-path inferences with reasoning, and ready-to-send templates per contact. Offer to run the next target company — the parsed CSV makes reruns instant.
