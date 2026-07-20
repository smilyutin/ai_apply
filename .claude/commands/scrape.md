---
description: Search LinkedIn jobs for postings that match profile/preferences.yaml and present fit-rated matches
---

# /scrape

Goal: find live LinkedIn job postings that match `profile/preferences.yaml`,
rate each one's fit, and hand back a short list the user can pick from to run
`/apply <url>` next. This command does not draft anything — it only finds and
ranks candidates.

## Steps

1. Read `profile/preferences.yaml`. Note `target_roles`, `locations`,
   `work_authorization`, `must_haves`, `nice_to_haves`, `deal_breakers`, and
   `portals`.

2. Build search queries by combining target roles with the accepted
  locations, scoped to LinkedIn Jobs via `site:` search operators, e.g.:
  - `site:linkedin.com/jobs QA Engineer Vancouver`
  - `site:linkedin.com/jobs Junior QA Analyst Remote Canada`
  - `site:linkedin.com/jobs "QA Team Lead" Vancouver`
  - `site:linkedin.com/jobs Manual QA Tester Vancouver`
  - `site:linkedin.com/jobs QA Automation Engineer Remote Canada`

   `target_roles` in preferences.yaml spans the full seniority range (Junior
   through Lead) and both manual and automation QA — cast a wide net across
   that whole range rather than narrowing to a couple of titles. Don't
   restrict searches to "Senior" just because that's the candidate's actual
   level; a posting titled "Intermediate QA Analyst" or "QA Tester" is
   still in scope. Group queries efficiently (e.g. one query can omit a level
   qualifier and let results span levels) rather than running every
  role-level x location permutation — aim for broad coverage in roughly
  10-15 queries, not one query per exact title variant. Stick to LinkedIn
  Jobs only; skip other portals and `Company career pages`.

3. Use WebSearch for each query. Collect candidate postings: title, company,
   location, portal, URL. Deduplicate by company + title (search results may
   return the same LinkedIn listing multiple times).

4. For candidates where the search snippet doesn't give enough to judge fit
  (seniority, remote policy, core responsibilities), WebFetch the posting URL
  to pull more detail. Skip this for postings that are obviously out of scope
  from the title/location alone (e.g. rejected locations) — don't waste fetches
  on those. Prefer recently posted openings; if a LinkedIn result is clearly
  stale/expired, exclude it rather than rating it.

5. Validate that the company is legit before rating fit. For each candidate
   remaining after step 4, check for scam/fraudulent-recruiter signals:
   - No findable presence beyond the job listing itself — WebSearch the
     company name; if there's no real company website and no LinkedIn
     company page (or one with essentially no history/employees), that's a
     red flag, not proof on its own, but weigh it with the others below.
   - The posting or any contact info asks for payment, a deposit, or
     purchase of "starter kit" equipment/software at any stage.
   - It asks for bank details, SIN/SSN, or ID/passport scans before any
     interview has happened.
   - Contact is routed only through a personal email address (gmail/yahoo/
     outlook, not the company's own domain) or a messaging app (WhatsApp/
     Telegram/Signal) instead of a normal application process.
   - Compensation is dramatically above market for the stated role/location
     with no other specific detail about the job.
   - The listing reads as a generic template with the company name swapped
     in and no company- or role-specific detail anywhere.
   - A staffing/recruiting firm that itself can't be verified — no
     discoverable business presence, reviews, or registration.
   One or two weak signals alone (e.g. thin LinkedIn presence for a small
   real company) aren't disqualifying — use judgment. Multiple signals, or
   any hard one (payment/deposit request, bank/SIN details, ID scans before
   an interview), means exclude the posting entirely regardless of fit —
   don't rate it, don't list it in the fit tables. Record it instead under
   "Excluded — suspected scam" (see step 7) with the specific signal(s)
   found, so the exclusion is auditable rather than silent.

6. Rate each remaining (validated) candidate's fit as High / Medium / Low
   against `preferences.yaml`:
   - Reject outright (don't list) anything hitting a `deal_breaker` or a
     `rejected` location.
   - For "Remote - US" postings, per `work_authorization`: only treat as a
     match if the posting explicitly allows working from Canada; otherwise
     mark fit as "confirm eligibility" instead of a hard reject.
   - High: hits all `must_haves` and several `nice_to_haves`, right seniority.
   - Medium: hits `must_haves` but few/no `nice_to_haves`, or seniority is a
     stretch in either direction.
   - Low: borderline on a `must_have` or seniority mismatch, but not a
     deal-breaker — include for completeness but flag why.

7. Present results as a markdown table, sorted High → Medium → Low, columns:
   Title | Company | Location | Portal | Fit | Why | URL. Keep the "Why"
   column to one short clause. Follow it with an "Excluded — suspected scam"
   table (if any) — same columns plus "Red flag(s)" instead of "Fit", so
   the user can see what was screened out and why without it cluttering the
   fit tables.

8. Write the same tables to
  `applications/scrape_<YYYY-MM-DD>.md` (create `applications/` if needed)
  so the list persists after the conversation ends. If a scrape file for
  today already exists, append new candidates rather than overwriting, and
  skip re-listing ones already recorded (match on URL). Keep this list to
  newly surfaced LinkedIn openings only; don't carry forward older results
  unless they are genuinely new to today's search.

9. Close with a one-line pointer: tell the user to run `/apply <url>` on
   whichever posting they want to pursue.

Do not fabricate postings or details. If a search returns nothing usable for
a query, say so rather than inventing a plausible-looking listing.
