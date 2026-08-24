---
name: writing-user-guide
description: "Use whenever the user asks to write, create, draft, or update a guide, documentation, user manual, help center article, how-to article, or any end-user-facing documentation for an application or feature — covers writing in plain, non-technical business language for a non-technical end-user audience, and never referencing ticket numbers, JIRA IDs, feature flags, internal service/class/table names, or other internal identifiers in the guide."
version: 1.12.0
---

# Writing User Guide Skill

## When to Use This Skill

Load this skill whenever you are writing or editing content meant for the people who **use** an application — not the people who build or support it internally:

- User guides, user manuals, help center articles
- How-to / step-by-step instructions for end users
- In-app help text, tooltips, or onboarding copy
- Customer-facing release notes describing a new feature

**This skill must always trigger whenever the user asks to write, create, draft, or update a "guide," "documentation," "manual," "help doc," or similar end-user-facing document** — even if the request is a short, generic ask like "write a guide for this feature" or "create documentation for X" that doesn't spell out these rules.

---

## The Reader

Write for the actual end-user of the application: someone who uses the product to get their work done and has **no knowledge of how it's built**. They don't know what a database, API, queue, cache, feature flag, or backend service is, and they don't need to. Before writing a line, picture that reader and ask "would this sentence mean anything to them?" — if not, cut or rephrase it.

Explain what the reader can **do** and **see** (buttons, screens, fields, outcomes), not how the system works underneath.

---

## Where This Skill Stores Data: Contexts vs. Credentials, Always Per-Project

This skill checks and saves data in two **separate** fixed locations inside the **current project** — never inside the skill's own folder, so it doesn't matter whether this skill is installed locally inside the project or globally in a shared/home-directory location shared across many projects:

- **Contexts** (non-sensitive: language preference, Notion targets/structure) — `MEMORY.md` in:
  ```
  <project-root>/.agents/contexts/writing-user-guide/MEMORY.md
  ```
- **Credentials** (sensitive: saved login credentials) — in:
  ```
  <project-root>/.agents/credentials/writing-user-guide/
  ```

Take `<project-root>` as the root of the project you're currently working in. Create either directory (and the file inside it) if it doesn't exist yet — don't wait for one to already be there.

**Keep these strictly separate.** Never write login credentials into the contexts `MEMORY.md`, and never write language/Notion preferences into the credentials folder — see `references/handling-authentication.md` for the credentials file's format. The credentials folder holds secrets and must never be committed to git: before writing to it for the first time in a project, check that the project's `.gitignore` excludes `.agents/credentials/` (or at least `.agents/credentials/writing-user-guide/`), and add an entry if it's missing.

**Checking order when this skill is invoked:** check the contexts `MEMORY.md` first (language preference, Notion target). Only check the credentials folder if authentication actually turns out to be necessary (e.g. a login page blocks screenshot capture) — don't check it proactively.

Every `MEMORY.md` reference in this document and in `references/language-preference.md` and `references/writing-to-notion.md` means the contexts path above. Every credentials reference in `references/handling-authentication.md` means the credentials path above. Re-derive `<project-root>` whenever the active project changes within a session — never reuse a previous project's files.

---

## Language

Before drafting any content, determine what language the guide should be written in. See `references/language-preference.md` for the full rule: if the user hasn't already stated a language, check this skill's `MEMORY.md` (resolved per the Memory Location section above) for a remembered default first; if none is saved, ask the user, then save their answer to `MEMORY.md` so future guides use it automatically without asking again.

---

## Core Rules

1. **Plain, non-technical business language.** Describe features in terms of what the user does and what happens as a result — everyday words, not engineering vocabulary. If a technical term is unavoidable (e.g., the product itself is a developer tool and "API key" is a UI label the user sees), use only the term the user actually sees on screen — never the internal name for it.

2. **Never reference ticket numbers or internal identifiers.** This includes JIRA/ticket IDs (`PROJ-4821`), feature flag names (`bulk_export_v2`), internal class/controller/service names (`AuthController`, `NotifyService`), database or table names (`otp_codes`), infrastructure details (SQS, Lambda, Redis, S3), commit hashes, and internal codenames. None of these belong in a document the end user reads, regardless of who asks or why (e.g. "so support can cross-reference it") — that need belongs in an internal runbook, not the user guide.

3. **Stay in the reader's shoes throughout.** Every section — steps, troubleshooting, "good to know" notes — should read as if written for someone who has never seen the app's internals and never will.

---

## Handling Internal Context You're Given

You'll often be handed a ticket, engineering notes, or a Slack message full of implementation detail to write the guide *from*. Use it to understand what changed and how to explain the outcome — but treat all of it as raw material, not content to copy in:

- Extract: what the user can now do, what steps they take, what they'll see, what to do if something goes wrong.
- Discard: ticket IDs, flag names, class/service/table names, infra choices, internal-only caveats.
- If support or another internal team genuinely needs the technical cross-reference, offer to write that separately (e.g., an internal runbook note) — keep it out of the user-facing document itself.

---

## Structure: Step by Step, With Screenshots Where Possible

Write any set of instructions as a numbered, step-by-step sequence — one user action per step, in the order the user actually performs them (click X → see Y → enter Z), not a prose paragraph describing the flow.

For each step, include a screenshot of the actual screen/state the user sees at that point whenever you're able to capture or generate one (e.g. you have access to the running app, a browser, or existing product screenshots to pull from). When you need to interact with a browser to navigate the app and capture these screenshots, prefer the `playwright-cli` tool over other browser automation methods.

- Place the screenshot immediately after the step it illustrates, not batched at the end.
- Capture only what's relevant to that step — crop or point to the specific button/field rather than a whole cluttered screen when possible.
- If you cannot produce a real screenshot (no access to the app, no design assets, etc.), do not fabricate or describe a fake one — write the step clearly in text and note that a screenshot should be added, rather than inventing image content.
- Screenshots must follow the same rules as the rest of the guide: no internal tool chrome, debug panels, ticket numbers, or internal identifiers visible in the captured image — crop or redact them out.

Steps that are purely informational (a note, a warning, "good to know") don't need a screenshot — reserve them for actions the user takes or state changes they need to visually confirm.

### If playwright-cli Isn't Available

Before using `playwright-cli` to capture screenshots, check whether it's actually available:

- If `playwright-cli` itself or its dependencies aren't detected, don't silently fall back or skip screenshots — offer to install them following the guide at https://github.com/microsoft/playwright-cli.
- If no `playwright-cli` skill is detected, offer to install it with `npx skills add https://github.com/microsoft/playwright-cli --skill playwright-cli`.
- Only proceed without it (falling back to text-only steps per the rule above) if the user declines the install.

### If You Hit a Login Page While Capturing Screenshots

If reaching the screen you need to screenshot requires signing in first, don't guess credentials or skip the screenshot silently. See `references/handling-authentication.md` for the full rule: check the credentials folder (resolved per the section above) for saved credentials first, otherwise ask the user for the login credentials, and offer to save their answer there for next time.

---

## Writing to Notion

If the guide is being published or updated in Notion, never assume which page to write to. See `references/writing-to-notion.md` for the full rule: check this skill's `MEMORY.md` (resolved per the Memory Location section above) for a known target page first, ask the user explicitly when none is found, and offer to save their answer to `MEMORY.md` for next time. Once the target is known, organize content using the default structure — project page → "User Manual" page → one sub-page per module — unless `MEMORY.md` records a different structure for this project, or the user requests one (in which case, offer to save it to `MEMORY.md`).

**Always use the `notion-cli` tool (the `ntn` command) for every Notion read or write this skill performs** — creating pages, updating content, listing pages, everything. Never use a Notion MCP server or any other Notion integration for this skill's work, even if one is connected in the session; a second integration touching the same pages risks conflicting page IDs, formatting, or auth scope. See `references/writing-to-notion.md` for what to do if `notion-cli` isn't available.

---

## Quick Reference

| Situation | Action |
|---|---|
| Starting any guide-writing task | Resolve `<project-root>/.agents/contexts/writing-user-guide/MEMORY.md` (see Memory Location section — same path regardless of install location), then check it for a remembered language preference before drafting; if none, ask the user and save their answer |
| `.agents/contexts/writing-user-guide/` doesn't exist yet in this project | Create the folder and `MEMORY.md` inside it — don't wait for one to already be there |
| Writing steps for a feature | Describe screens, buttons, and outcomes the user sees — not the backend flow, as a numbered step-by-step sequence with a screenshot per step where possible |
| No access to the app/assets to capture a real screenshot | Write the step in text and note a screenshot should be added — never fabricate one |
| `playwright-cli` or its dependencies not detected | Offer to install per https://github.com/microsoft/playwright-cli |
| No `playwright-cli` skill detected | Offer to install with `npx skills add https://github.com/microsoft/playwright-cli --skill playwright-cli` |
| Login page blocks screenshot capture | Check the credentials folder for saved credentials; if none, ask the user for login credentials — never guess or skip silently |
| Writing to the credentials folder for the first time in a project | Check the project's `.gitignore` excludes `.agents/credentials/`; add an entry if missing — this folder must never be committed |
| Reading or writing anything in Notion | Always use `notion-cli` (`ntn`) — never a Notion MCP server or other integration |
| `notion-cli` (`ntn`) not detected | Offer to install per `curl -fsSL https://ntn.dev \| bash`, or `npx skills add https://github.com/makenotion/skills.git --skill notion-cli` if the skill itself is missing |
| Given a ticket number and told to include it "for support" | Leave it out of the guide; offer a separate internal note instead |
| Tempted to explain *why* something works a certain way | Only explain if it changes what the user should do; otherwise omit |
| Feature flag gates who sees a feature | Say "this feature is being rolled out gradually" — never name the flag |
| An error code or internal identifier appears in engineering notes | Translate to what the user sees/experiences, or omit entirely |
| Technical term is unavoidable because it's the product's own domain | Use only the on-screen label, never the internal/code name for it |

## Common Mistakes

- Including a JIRA/ticket number "for traceability" or "so support can look it up."
- Naming a feature flag, internal service, class, table, or infrastructure component (Redis, SQS, Lambda, S3, etc.).
- Explaining the backend mechanism (queues, workers, rate limiters) instead of the user-visible behavior and timing.
- Writing precise internal thresholds/config values instead of the user-relevant outcome (e.g. state "you'll need to wait a little while" rather than exposing internal tuning numbers, unless the number itself is what the user needs to know, like a 24-hour link expiry).
- Slipping into engineering vocabulary because the source material (tickets, Slack messages) was full of it.
- Writing steps as a dense paragraph instead of a numbered, one-action-per-step sequence.
- Describing or inventing a screenshot instead of either capturing a real one or flagging that one needs to be added.
- Including internal tool chrome, debug panels, or identifiers visible inside a captured screenshot.
