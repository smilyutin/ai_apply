---
description: Evaluate a job posting's fit, then draft, review, and generate a tailored resume + cover letter
argument-hint: <job posting URL>
---

# /apply

Goal: turn one job posting URL into a fit evaluation and, if it's worth
pursuing, a tailored resume and cover letter — drafted, critiqued by the
`application-reviewer` subagent, revised, and rendered to .docx.

Argument: `$ARGUMENTS` is the job posting URL. If missing, ask the user for
one (or point them at the most recent `applications/scrape_*.md` to pick
from).

## Steps

1. Read `profile/profile.yaml`, `profile/preferences.yaml`, and
   `profile/cover_letter_voice.md`.

2. WebFetch the posting URL. Extract: job title, company, location, remote
   policy, seniority, responsibilities, must-have requirements, nice-to-have
   requirements, and any application instructions or deadline. If the fetch
   fails (auth wall, JS-rendered page with no content), tell the user and
   stop rather than guessing at the posting's contents.

3. Derive a slug from company + title (lowercase, hyphenated, e.g.
   `semios-quality-assurance-engineer`). If `applications/<slug>/` already
   exists, tell the user and ask whether to overwrite or stop — don't
   silently clobber a previous application.

4. Create `applications/<slug>/job_posting.md`: the extracted details plus
   the source URL and today's date. This is the grounding document for
   every later step (and for the reviewer) — don't rely on memory of the
   posting once it's written.

5. Evaluate fit against `preferences.yaml` using the same rubric as
   `/scrape` (deal-breakers, must-haves, location/work authorization,
   seniority). Write the verdict and reasoning to
   `applications/<slug>/fit_evaluation.md`.
   - If it hits a `deal_breaker` or a `rejected` location: tell the user
     plainly and ask whether they still want to proceed before drafting
     anything.
   - If work authorization is unclear (e.g. a "Remote - US" posting that
     doesn't explicitly confirm remote-from-Canada): flag it and ask before
     proceeding — don't spend drafting effort on a role they may not be
     eligible for.

6. Draft `applications/<slug>/resume.yaml` from `profile.yaml` (same
   schema — see that file's structure). Tailoring means:
   - Reword the `headline` to mirror the posting's title/keywords, staying
     truthful.
   - Rewrite `summary` to foreground the overlap between the candidate's
     background and this posting.
   - Reorder (and, if needed, trim) `core_competencies` and
     `professional_strengths` so the most relevant items lead.
   - Reorder/reword `experience` bullets per role to foreground what's
     relevant to this posting. Never invent a bullet, tool, or metric that
     isn't already in `profile.yaml` — tailoring is emphasis and phrasing,
     not new content.
   - Leave `tools_and_technologies` and `education` intact (reorder only if
     it helps relevance).

7. Draft `applications/<slug>/cover_letter.yaml` following the structure and
   tone in `cover_letter_voice.md` (see `applications/_example/cover_letter.yaml`
   for the schema). Paragraph 3 (why this company) is the highest
   fabrication-risk part — only reference specifics confirmed in
   `job_posting.md` or the company's own site, and WebFetch the company's
   About/product page if you need one more concrete detail and the posting
   doesn't have enough. Don't invent a detail to fill the paragraph.

8. Launch the `application-reviewer` subagent (via the Agent tool) with the
   paths to `job_posting.md`, `profile.yaml`, `preferences.yaml`,
   `cover_letter_voice.md`, and the two drafts. Run it in the foreground —
   its findings are needed before continuing.

9. Revise `resume.yaml` and `cover_letter.yaml` based on the reviewer's
   findings. Use judgment: fix real fabrication/tone/alignment issues;
   findings that don't hold up don't need to be applied, but don't ignore a
   fabrication flag without checking `profile.yaml` yourself first.

10. Generate the final documents:
    ```
    .venv/bin/python scripts/generate_docx.py resume applications/<slug>/resume.yaml applications/<slug>/resume.docx
    .venv/bin/python scripts/generate_docx.py cover-letter applications/<slug>/cover_letter.yaml applications/<slug>/cover_letter.docx
    ```

11. Summarize for the user: fit verdict, the two file paths, and what the
    reviewer flagged and how it was resolved. Remind them to proofread
    before submitting and to fill in any placeholder details you couldn't
    confirm (e.g. hiring manager name, if the posting didn't name one).

Do not fabricate experience at any step. If the posting doesn't map well
enough to `profile.yaml` to draft an honest resume, say so instead of
padding the draft.
