# ai_apply

A Claude Code project that finds QA/SDET job postings matching a target
profile, rates fit, and drafts a tailored resume + cover letter per
posting. A scheduled morning job automates the "find + draft" part; the
user always applies manually.

## Project tree

```
ai_apply/
├── README.md
├── .claude/
│   ├── settings.json                  # tool permission allow-list
│   ├── agents/
│   │   └── application-reviewer.md    # reviews a drafted resume/cover letter before finalizing
│   └── commands/
│       ├── setup.md                   # /setup  — interview the user, write profile/*
│       ├── scrape.md                  # /scrape — search portals, rate fit, list candidates
│       ├── apply.md                   # /apply  — draft resume + cover letter for one posting URL
│       └── daily.md                   # /daily  — unattended: new postings only, auto-draft High/Medium
├── profile/
│   ├── profile.yaml                   # source of truth: experience, skills, education
│   ├── preferences.yaml               # target roles, locations, must/nice-to-haves, deal-breakers
│   └── cover_letter_voice.md          # tone/voice guide for cover letters
├── applications/
│   ├── _example/
│   │   └── cover_letter.yaml          # schema reference
│   ├── scrape_<YYYY-MM-DD>.md         # daily search results (all fit levels, one file per day)
│   ├── report_<YYYY-MM-DD>.md         # /daily's morning report (new postings + drafted docs)
│   └── <company-title-slug>/          # one folder per posting that got drafted
│       ├── job_posting.md             # extracted posting details + source URL
│       ├── fit_evaluation.md          # verdict against preferences.yaml
│       ├── resume.yaml                # tailored resume (source)
│       ├── resume.docx                # rendered resume
│       ├── cover_letter.yaml          # tailored cover letter (source)
│       └── cover_letter.docx          # rendered cover letter
├── scripts/
│   ├── generate_docx.py               # renders resume/cover_letter yaml -> .docx
│   ├── daily_run.sh                   # launchd entrypoint, runs `claude -p "/daily"`
│   └── requirements.txt               # python-docx, pyyaml
├── logs/                              # daily_run.sh output (gitignored)
└── .venv/                             # local python env for generate_docx.py
```

A macOS launchd agent (`~/Library/LaunchAgents/com.aiapply.dailyscrape.plist`,
outside this repo) runs `scripts/daily_run.sh` every morning at 8:00 AM.

## Flow

### One-time / occasional setup

```
/setup
   │
   ▼
profile/profile.yaml, preferences.yaml, cover_letter_voice.md
(source of truth for every later step)
```

### Manual search → apply

```
/scrape
   │  read preferences.yaml → search portals → rate fit (High/Medium/Low)
   ▼
applications/scrape_<date>.md   (table of candidates + URLs)
   │  user picks a URL
   ▼
/apply <url>
   │  fetch posting → fit_evaluation.md
   │  draft resume.yaml + cover_letter.yaml from profile.yaml
   │  application-reviewer subagent → revise
   │  generate_docx.py → resume.docx + cover_letter.docx
   ▼
applications/<slug>/   (ready to review and submit manually)
```

### Automated morning run

```
launchd (8:00 AM daily)
   │
   ▼
scripts/daily_run.sh
   │  cd repo; claude -p "/daily" --dangerously-skip-permissions
   ▼
/daily
   │  1. collect every URL already in scrape_*.md and */job_posting.md
   │  2. search (same as /scrape), keep only URLs not seen before
   │  3. write today's applications/scrape_<date>.md
   │  4. for each NEW High/Medium fit posting: run the /apply flow in full
   │     (Low fit is listed, not drafted)
   ▼
applications/report_<date>.md
   (Title | Company | Fit | URL | resume.docx path | cover_letter.docx path)
   │
   ▼
user reads the report, opens the docx files, applies manually
```

`/daily` never submits an application — it only finds postings and prepares
documents. Applying is always a manual, human step.

## Permissions note

`/scrape` and `/apply` run interactively under the normal permission
prompts (`.claude/settings.json` allow-lists common WebFetch domains). The
scheduled `/daily` run is unattended, so `scripts/daily_run.sh` invokes
Claude Code with `--dangerously-skip-permissions`, scoped to this repo
directory only.
