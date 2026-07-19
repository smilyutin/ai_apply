---
description: Morning job — find NEW postings since the last run, auto-draft resume + cover letter for High/Medium fit, write a single actionable report
---

# /daily

Goal: an unattended morning run. Find job postings that were not already
surfaced in a previous run, rate their fit, and — for anything High or
Medium fit — go all the way through the `/apply` drafting flow so a
tailored resume and cover letter already exist by the time the user reads
the report. The user applies manually; this command never submits anything
on any site. Low-fit postings are listed but not drafted.

This command is invoked headlessly (no one is available to answer
clarifying questions or approve tool prompts). Where `/scrape` or `/apply`
would normally stop and ask the user something, use the documented
defaults/judgment calls instead and note the assumption in the report
rather than blocking.

## Step 1 — Build the "already seen" set

Before searching, collect every URL already known from prior runs so
today's search only surfaces genuinely new postings:

- All URLs appearing in any `applications/scrape_*.md` file (any date,
  including today's if one already exists).
- The `source URL` recorded in every `applications/<slug>/job_posting.md`.

Any candidate URL found in step 2 that matches one of these (exact match,
or same posting reachable via a redirect/tracking-parameter variant of a
known URL) is already seen — drop it before rating, and don't recreate an
`applications/<slug>/` that already exists.

## Step 2 — Search

Follow `.claude/commands/scrape.md` steps 1-6 exactly (read
`profile/preferences.yaml`, build queries, WebSearch, dedupe candidates,
WebFetch where needed for fit detail, rate High/Medium/Low) — but restrict
the result set to postings NOT in the "already seen" set from Step 1.

## Step 3 — Record today's scrape

Write/append `applications/scrape_<YYYY-MM-DD>.md` exactly as `/scrape`
step 7 describes, containing only today's newly-found candidates (High,
Medium, and Low). This keeps tomorrow's "already seen" set accurate even
for postings that don't get drafted.

## Step 4 — Auto-draft for High and Medium fit

For every new candidate rated High or Medium in Step 2, run the full
`/apply` flow (`.claude/commands/apply.md` steps 1, 3-10) against its URL:
fit evaluation, `resume.yaml` + `cover_letter.yaml` drafts, the
`application-reviewer` subagent pass, revisions, and `.docx` generation.

Judgment calls that would normally prompt the user — apply the safer
default and note it in the report instead of stopping:
- Hits a `deal_breaker` or rejected location → skip drafting, list it as
  Low/excluded with the reason instead.
- "Remote - US" without explicit remote-from-Canada language → treat as
  Medium at best and note "confirm eligibility" rather than drafting, since
  drafting effort would be wasted if it's a hard no.
- `applications/<slug>/` already exists (shouldn't happen given Step 1, but
  as a safety net) → skip drafting, don't overwrite.

Low-fit candidates are never auto-drafted — list them in the report with
their URL and the reason for the Low rating only.

## Step 5 — Write the report

Write `applications/report_<YYYY-MM-DD>.md`, the single file the user
reads each morning:

```markdown
# Daily job report — <date>

<N> new posting(s) found, <M> drafted.

## Ready to apply

| Title | Company | Fit | URL | Resume | Cover Letter |
|---|---|---|---|---|---|
| ... | ... | High/Medium | <url> | applications/<slug>/resume.docx | applications/<slug>/cover_letter.docx |

## Found but not drafted (Low fit / flagged)

| Title | Company | Fit | URL | Why |
|---|---|---|---|---|
| ... | ... | Low | <url> | <reason> |
```

Sort the "Ready to apply" table High before Medium. Use paths relative to
the repo root so they're clickable/openable directly. If nothing new was
found, still write the file with "0 new postings found today" so the run's
history is visible.

## Step 6 — Close

Do not print a long transcript — the report file is the deliverable. End
with one line: how many new postings were found and how many were drafted,
and the path to today's report.

Do not fabricate postings, fit ratings, or resume/cover-letter content at
any step — same fabrication constraints as `/scrape` and `/apply`.
