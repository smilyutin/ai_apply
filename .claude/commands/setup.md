---
description: Interview the user and set up or update their profile and job search preferences
---

# /setup

Goal: make sure `profile/profile.yaml`, `profile/preferences.yaml`, and
`profile/cover_letter_voice.md` accurately reflect the user before any scraping
or applying happens.

## Steps

1. Read the three files above if they exist. Summarize what's already captured
   in a few bullet points so the user can see the starting point.
2. Ask the user (don't assume) about anything missing or that looks stale:
   - New job titles/companies/dates not yet in `experience`
   - Changes to `locations` / `work_authorization` in preferences.yaml — this
     project is scoped to Vancouver, BC plus remote-from-Canada roles (including
     US remote roles that explicitly allow working from Canada). Confirm this is
     still correct before proceeding.
   - Any deal-breakers or must-haves that changed
   - Whether the cover letter voice notes in `cover_letter_voice.md` still match
     how they want to sound
3. Check that `.venv` exists and has `python-docx` + `pyyaml` installed
   (`.venv/bin/python -c "import docx, yaml"`). If missing, run:
   ```
   python3 -m venv .venv && .venv/bin/pip install -r scripts/requirements.txt
   ```
4. Update the YAML/Markdown files directly based on the conversation — don't
   just describe the changes, make them.
5. Confirm with a short summary of what changed.

Do not fabricate experience. If the user mentions something vague ("I did some
automation work at X"), ask a follow-up before writing it into profile.yaml as
a concrete bullet.
