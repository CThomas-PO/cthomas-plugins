# App Profile Template

Copy this structure exactly when writing `ux-testing/app-profile.md`.
Written once per project; every persona and test session reads it.

---

# App Profile: {App Name}

Last updated: {YYYY-MM-DD}

## What it does

{One paragraph: what the app does and for whom.}

## Domain

{e.g., consumer fintech, B2B logistics SaaS, healthcare scheduling}

## Primary user segments

- {segment 1}
- {segment 2}

## Platform

{browser | native-desktop | native-mobile}
{If native: "Note: v1 automated test runs are browser-only. Personas can
be used for manual testing."}

## Test environment

- **URLs / allowed origins:** {test-env URLs — personas must not navigate
  outside these origins}
- **Access approach:** {warm-session — tester logs in before the persona
  takes over | env vars: VAR_NAMES — names only, never values}

## Destructive-action guardrails

Actions a persona must never take without pausing to confirm with the
tester:
- {e.g., anything on a payment screen, sending invitations, deleting records}
