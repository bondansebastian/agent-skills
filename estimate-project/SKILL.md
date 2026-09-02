---
name: estimate-project
description: "Use when creating, naming, renaming, or filling in the metadata table of a project estimate document under docs/estimates/ — covers date-prefixed filenames keyed to the Date of assessment field, the required AI Estimate metadata row (never a separate Estimate or Human Estimate row), the required Scope/Assumptions/Breakdown document structure, and remembering this project's client name in .agents/contexts/estimate-project/MEMORY.md (shared with the writing-quotations skill) so it isn't asked for on every new estimate. Always trigger when the user asks to estimate a project, size up a task, scope out how long something will take, or write/draft/create an estimate document — even if the request doesn't mention filenames, metadata, or docs/estimates/ directly. For turning the estimate into a client-facing price or quotation, tracking pricing variables, or Zoho Books estimates, see the writing-quotations skill instead."
version: 1.1.0
---

# Estimate Project Skill

## When to Use This Skill

Load this skill when you are:

- Creating a new client estimate document
- Renaming an estimate document after its `Date of assessment` changes
- Writing or reviewing an estimate document's metadata table, scope, assumptions, or breakdown

**This skill must always trigger whenever the user asks the agent to estimate, scope, or size up a project or task** — even if the request doesn't mention filenames, metadata, or `docs/estimates/` directly.

Once the `AI Estimate` is written, turning it into a client-facing price or quotation, tracking pricing variables in `docs/QUOTES.md`, or creating/updating a Zoho Books estimate is covered by the **writing-quotations** skill, not this one.

---

## Where This Skill Stores Context

This skill remembers non-sensitive, project-specific context across invocations instead of re-asking every time. Store and read it at:

```
<project-root>/.agents/contexts/estimate-project/MEMORY.md
```

Take `<project-root>` as the root of the project you're currently working in — never the skill's own folder, so this works the same whether the skill is installed locally or globally. Create the folder and file if they don't exist yet; don't wait for one to already be there. Re-derive `<project-root>` whenever the active project changes within a session.

Store the **client name** for this project once it's known. Most repos belong to a single client, so once you learn it — from the user, or from an existing document under `docs/estimates/`— save it here so future estimates in this project don't need to ask again.

**Resolving the client name for a new estimate:** check this skill's `MEMORY.md` first. If it's empty, also check `.agents/contexts/writing-quotations/MEMORY.md` — the **writing-quotations** skill may have already recorded this project's client name from a prior quotation. Only ask the user if neither has it, then save the answer back to this skill's `MEMORY.md`.

---

## Filename Convention

Estimate document filenames in `docs/` must always be prefixed with the date, using the **Date of assessment** field from the document's own metadata table:

```
docs/estimates/YYYY-MM-DD-<client>-<short-slug>.md
```

- The date is `Date of assessment` — not the file's creation date and not an approval date.
- If `Date of assessment` changes (e.g. the assessment is revisited before approval), rename the file (`git mv`) to match. Don't leave a stale date in the filename.
- Linked-file folders use the same dated basename as the file they contain, so the folder and file stay matched: `docs/estimates/YYYY-MM-DD-<client>-<short-slug>/`.

---

## Document Structure

Every estimate document must follow this structured format, in order:

1. **Metadata table** — see [Metadata: AI Estimate](#metadata-ai-estimate) below.
2. **Scope** — what work is being estimated, in plain terms.
3. **Assumptions** — see [Assumptions](#assumptions) below. Required even if short.
4. **Breakdown** — the tasks or phases that make up the estimate, each with its own time figure, summing to the top-level `AI Estimate`.
5. **Pricing** (only when a client-facing quote is requested) — handled by the **writing-quotations** skill, not this one. Load it before writing a price or quotation.

Don't skip or reorder sections. A document missing an Assumptions section is incomplete, even if the metadata table and breakdown are otherwise correct.

---

## Assumptions

Every estimate document must state the assumptions held while writing the estimate — the conditions the estimate depends on that, if false, would change the number. Put these in an **Assumptions** section immediately after Scope, as a bullet list.

- Capture things like: existing code/infra the work builds on, access or credentials assumed to be available, scope boundaries (what's explicitly *not* included), third-party dependencies assumed stable, and any open questions being estimated optimistically.
- Write assumptions as falsifiable statements ("Assumes the existing auth middleware is reused unmodified"), not hedges ("might need more time").
- If there are truly no assumptions beyond the stated scope, say so explicitly (`No assumptions beyond the stated scope.`) rather than omitting the section.

---

## Metadata: AI Estimate

Every estimate document's metadata table must report an **AI Estimate** in place of the `Estimate` row (do not include a separate `Human Estimate` row):

- **AI Estimate** — wall-clock time for an AI coding agent (e.g. Claude Code) to complete the same scope in an active session, e.g. `45 minutes`, `3 hours`. This is elapsed session time, not effort-days — agents don't work in man-day units.

---

## Quick Reference

| Situation | Action |
|---|---|
| Creating a new estimate | Resolve the client name from `.agents/contexts/estimate-project/MEMORY.md` (or writing-quotations' context) before asking; write to `docs/estimates/YYYY-MM-DD-<client>-<slug>.md` using today's `Date of assessment` |
| `Date of assessment` changes | `git mv` the file (and its linked folder, if any) to the new date |
| Filling in the metadata table | Include one `AI Estimate` row; omit `Estimate` and `Human Estimate` |
| Writing the document body | Follow Metadata → Scope → Assumptions → Breakdown → Pricing (if quoted), in that order |
| Stating assumptions | List falsifiable conditions the estimate depends on, or note none exist |
| Pricing the estimate for a client, or a Zoho Books estimate | Load the **writing-quotations** skill |

## Common Mistakes

- Dating the filename by creation or approval date instead of `Date of assessment`.
- Leaving a stale date in the filename after the assessment is revised.
- Including both an `Estimate` row and an `AI Estimate` row, or adding a `Human Estimate` row.
- Omitting the Assumptions section, or burying assumptions inside the breakdown instead of stating them up front.
- Writing assumptions as vague hedges instead of falsifiable statements.
- Writing a client-facing price or quotation directly in this skill instead of loading **writing-quotations** for the pricing formula and quotation style.
- Re-asking for the client name every time instead of checking `.agents/contexts/estimate-project/MEMORY.md` (and writing-quotations' context) first.
