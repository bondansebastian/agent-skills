---
name: user-guide-documents
description: "Use whenever the user asks to write, create, draft, or update a guide, documentation, user manual, help center article, how-to article, or any end-user-facing documentation for an application or feature — covers writing in plain, non-technical business language for a non-technical end-user audience, and never referencing ticket numbers, JIRA IDs, feature flags, internal service/class/table names, or other internal identifiers in the guide."
version: 1.5.0
---

# User Guide Documents Skill

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

## Language

Before drafting any content, determine what language the guide should be written in. See `references/language-preference.md` for the full rule: if the user hasn't already stated a language, check this skill's `MEMORY.md` for a remembered default first; if none is saved, ask the user, then save their answer to `MEMORY.md` so future guides use it automatically without asking again.

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

For each step, include a screenshot of the actual screen/state the user sees at that point whenever you're able to capture or generate one (e.g. you have access to the running app, a browser, or existing product screenshots to pull from):

- Place the screenshot immediately after the step it illustrates, not batched at the end.
- Capture only what's relevant to that step — crop or point to the specific button/field rather than a whole cluttered screen when possible.
- If you cannot produce a real screenshot (no access to the app, no design assets, etc.), do not fabricate or describe a fake one — write the step clearly in text and note that a screenshot should be added, rather than inventing image content.
- Screenshots must follow the same rules as the rest of the guide: no internal tool chrome, debug panels, ticket numbers, or internal identifiers visible in the captured image — crop or redact them out.

Steps that are purely informational (a note, a warning, "good to know") don't need a screenshot — reserve them for actions the user takes or state changes they need to visually confirm.

### If You Hit a Login Page While Capturing Screenshots

If reaching the screen you need to screenshot requires signing in first, don't guess credentials or skip the screenshot silently. See `references/handling-authentication.md` for the full rule: check this skill's `MEMORY.md` for saved credentials first, otherwise ask the user for the login credentials, and offer to save their answer to `MEMORY.md` for next time.

---

## Writing to Notion

If the guide is being published or updated in Notion, never assume which page to write to. See `references/writing-to-notion.md` for the full rule: check this skill's `MEMORY.md` for a known target page first, ask the user explicitly when none is found, and offer to save their answer to `MEMORY.md` for next time.

---

## Quick Reference

| Situation | Action |
|---|---|
| Starting any guide-writing task | Check `MEMORY.md` for a remembered language preference before drafting; if none, ask the user and save their answer |
| Writing steps for a feature | Describe screens, buttons, and outcomes the user sees — not the backend flow, as a numbered step-by-step sequence with a screenshot per step where possible |
| No access to the app/assets to capture a real screenshot | Write the step in text and note a screenshot should be added — never fabricate one |
| Login page blocks screenshot capture | Check `MEMORY.md` for saved credentials; if none, ask the user for login credentials — never guess or skip silently |
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
