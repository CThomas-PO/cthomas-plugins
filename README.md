# Craig's Claude Plugins

A [Claude plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) —
add this repo once and you can install any plugin published here, with updates
delivered on every sync.

## Plugins

| Plugin | What it does | Version |
|---|---|---|
| **[Job Search Copilot](plugins/job-search-copilot/)** | An AI job-search assistant: six skills sharing one career profile — LinkedIn profile optimization, fresh-posting scouting with honest fit scores, ATS resume tailoring, warm-intro mapping, and a 4-week content plan. | 0.9.0 |
| **[User Persona Generator](plugins/user-persona-generator/)** | Simulated UX testing for teams that can't recruit real users: interview-built personas, live browser test sessions with think-aloud transcripts, and severity-ranked findings reports backed by verbatim evidence. | 0.3.0 |
| **[Interviewer Bot](plugins/interviewer-bot/)** | An adaptive mock-interview coach: reads your resume and a job description, interviews you in the hiring company's voice across three phases, and hands you a private performance review with rewritten answers. | 0.1.0 |

Each plugin's README covers its skills, setup, and costs.

## Install

**Claude desktop app (Cowork):**

1. Open **Customize → Plugins**
2. Click **+** → **Add from a repository**
3. Paste: `https://github.com/CThomas-PO/cthomas-plugins`
4. Install the plugin you want and open a session

**Claude Code:**

```
/plugin marketplace add CThomas-PO/cthomas-plugins
/plugin install job-search-copilot@cthomas-plugins
/plugin install user-persona-generator@cthomas-plugins
/plugin install interviewer-bot@cthomas-plugins
```

📖 New to plugins? **[The illustrated guide](docs/GETTING-STARTED.md)** walks
through setup with screenshots (written for Job Search Copilot; the steps
apply to any plugin here).

## Design principles

Every plugin here follows the same rules: ask before guessing, never invent
facts, cite evidence for claims, keep secrets out of files, and interrupt the
user only when an action is destructive or truly ambiguous.

## Repository layout

- [`plugins/`](plugins/) — plugin source, one folder per plugin
- [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) — the catalog
- [`docs/`](docs/) — guides, plus design specs and implementation plans
