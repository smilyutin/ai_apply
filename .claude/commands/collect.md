---
description: Collect a job posting into an application folder without drafting resume or cover letter files yet
argument-hint: <job posting URL>
---

# /collect

Goal: capture one job posting as a grounded `job_posting.md` file first, so the
posting can be reviewed later before any fit evaluation or document drafting
happens.

Argument: `$ARGUMENTS` is the job posting URL. If missing, ask the user for one.

## Steps

1. WebFetch the posting URL. Extract: job title, company, location, remote
   policy, seniority, responsibilities, must-have requirements, nice-to-have
   requirements, and any application instructions or deadline. If the fetch
   fails (auth wall, JS-rendered page with no content), tell the user and stop.

2. Derive a slug from company + title (lowercase, hyphenated, e.g.
   `semios-quality-assurance-engineer`). If `applications/<slug>/` already
   exists, tell the user and ask whether to overwrite or stop.

3. Create `applications/<slug>/job_posting.md` with the extracted details, the
   source URL, and today's date.

4. Stop there. Do not draft `fit_evaluation.md`, `resume.yaml`,
   `cover_letter.yaml`, or any `.docx` files yet.

5. Summarize for the user with the folder path and remind them that fit
   evaluation and document drafting can be done later for any chosen companies.

Do not fabricate posting details.