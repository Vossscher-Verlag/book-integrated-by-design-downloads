# HANDOVER-EXTERN — Cross-Session Tasks

Tasks identified for this project from outside its own session. Read this at session start before starting new work. Resolve or explicitly defer each open item.

Each entry: **Origin**, **Severity**, **Context**, **Action**, **Acceptance**. Completed items move to `## Resolved` (log, not deleted).

---

## Open

### config.yml contact-link URL: update to vossscher-verlag.com

- **Origin:** Voss'scher Verlag session, 2026-04-20
- **Severity:** Medium — not release-critical for the book's 2026-04-23 launch, but the current contact link sends readers to the author's personal site (`vvoss.net`), not the publisher's brand.
- **Context:** Publisher identity was consolidated under Voss'scher Verlag in April 2026. The issue-template contact-link should align with the publisher brand once the publisher website is live and stable.
- **Affected file:** `.github/ISSUE_TEMPLATE/config.yml`
- **Current:**
  ```yaml
  url: https://vvoss.net
  about: Visit the author's website for general questions and updates.
  ```
- **Target:**
  ```yaml
  url: https://vossscher-verlag.com
  about: Visit the publisher's website for general questions and updates.
  ```
- **Dependency:** `https://vossscher-verlag.com` must resolve to a real publisher landing page. Defer this change until the Voss'scher Verlag Website project is in production and the root URL serves a real page (not placeholder / 404 / "coming soon").
- **Action:**
  1. Verify `https://vossscher-verlag.com` is live and serves the publisher landing page.
  2. Update `.github/ISSUE_TEMPLATE/config.yml` to the new URL and wording.
  3. Commit and push directly to `main` (this repo does not operate under a Leitwerk workflow; simple descriptive commit message is sufficient).
- **Acceptance:**
  - `config.yml` points to `https://vossscher-verlag.com`.
  - GitHub issue-template creation flow in the browser shows the new contact-link.

---

## Resolved

(none yet)
