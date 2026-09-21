---
name: estimate-project
description: "Use when creating, naming, renaming, or filling in the metadata table of a project estimate document under docs/estimates/ — covers date-prefixed filenames keyed to the Date of assessment field, the required AI Estimate metadata row (never a separate Estimate or Human Estimate row), and the required Scope/Assumptions/Breakdown document structure with a unique index on every section and sub-section (mirrored by the client quotation). Always asks the client name fresh for every new estimate rather than remembering it. Always trigger when the user asks to estimate a project, size up a task, scope out how long something will take, or write/draft/create an estimate document — even if the request doesn't mention filenames, metadata, or docs/estimates/ directly. For turning the estimate into a client-facing price or quotation, tracking pricing variables, or Zoho Books estimates, see the writing-quotations skill instead."
version: 1.4.0
---

# Estimate Project Skill

## When to Use This Skill

Load this skill when you are:

- Creating a new client estimate document
- Renaming an estimate document after its `Date of assessment` changes
- Writing or reviewing an estimate document's metadata table, scope, assumptions, or breakdown

**This skill must always trigger whenever the user asks the agent to estimate, scope, or size up a project or task** — even if the request doesn't mention filenames, metadata, or `docs/estimates/` directly.

Once the `AI Estimate` is written, turning it into a client-facing price or quotation, tracking pricing variables, or creating/updating a Zoho Books estimate is covered by the **writing-quotations** skill, not this one.

This skill does not remember the client name (or any other context) across invocations — always ask for it fresh when starting a new estimate, since a project/repo can involve more than one client or project over time. See **writing-quotations**' own context rules if you need the pattern for what genuinely is safe to remember (pricing variables) versus what isn't (client/project identity).

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

Every estimate document must follow this structured format, in order. **Every section and sub-section carries a unique index** (see [Section Indexing](#section-indexing)):

- **Metadata table** — unnumbered header; see [Metadata: AI Estimate](#metadata-ai-estimate) below.
1. **Scope** — what work is being estimated, in plain terms.
2. **Assumptions** — see [Assumptions](#assumptions) below. Required even if short.
3. **Breakdown** — the tasks or phases that make up the estimate, each with its own time figure, summing to the top-level `AI Estimate`. Each task/phase is a sub-section (`3.1`, `3.2`, …), and its own parts are nested further (`3.1.1`, `3.1.2`, …).
4. **Pricing** (only when a client-facing quote is requested) — handled by the **writing-quotations** skill, not this one. Load it before writing a price or quotation.

Don't skip or reorder sections. A document missing an Assumptions section is incomplete, even if the metadata table and breakdown are otherwise correct.

### Section Indexing

- Use hierarchical decimal indices: top-level sections are `1`, `2`, `3`…; sub-sections `3.1`, `3.2`…; deeper levels `3.1.1`… Put the index in the heading or at the start of the bullet/row (`### 3.1 Login page`, `- 2.1 Assumes …`), so any item can be cited by index alone.
- **Every** section and sub-section gets an index — including each individual assumption (`2.1`, `2.2`, …) and each breakdown item. No unnumbered items, no duplicate indices.
- Indices are **stable**: when adding an item, take the next free index at that level; when removing one, don't renumber the others or reuse its index (note it as `3.2 (removed)` only if needed). References from confirmations, quotations, and Zoho Books must stay valid.
- **The client quotation mirrors this structure** (see the **writing-quotations** skill): same top-level numbering (`1` Scope, `2` Assumptions, `3` Breakdown ↔ Deliverables, `4` Pricing), and each quotation deliverable reuses the index of the breakdown item it is priced from (quotation `3.1` ↔ estimate `3.1`). When the estimate's structure changes, flag that the quotation needs the matching change.

---

## Confirm Changes Before Editing

Before changing an existing estimate document (adding, removing, or resizing scope, breakdown items, assumptions, or the `AI Estimate`), **always present the upcoming changes to the user in a table first, and only edit the document after they confirm.** Never edit the estimate and describe the change afterward.

The table has one row per change:

| Index | Section / Item | Change | Before | After | Effort change |
|---|---|---|---|---|---|
| 3.1 | Breakdown: Login page | Modified | 1 hour | 1.5 hours | +30 minutes |
| 3.4 | Breakdown: Audit log | Added | — | 45 minutes | +45 minutes |
| 2.2 | Assumptions: SSO | Removed | Assumes SSO is out of scope | — | — |
| | **Total AI Estimate** | | 3 hours | 4 hours 15 minutes | **+1 hour 15 minutes** |

- Always include the **Index** column (the item's index in the document; the next free index for additions), the **Effort change** column (signed, e.g. `+30 minutes`, `-1 hour`; `—` for changes that don't affect time) and a final row with the total `AI Estimate` before and after.
- Show every change that will be made, and nothing that won't be — the table must match the edit exactly.
- If the user adjusts the proposal, present the revised table again before editing.
- If the estimate is being created from scratch, present the proposed breakdown in the same table form (Before shown as `—`) before writing the file.

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
| Creating a new estimate | Ask for the client name fresh (never remembered); write to `docs/estimates/YYYY-MM-DD-<client>-<slug>.md` using today's `Date of assessment` |
| `Date of assessment` changes | `git mv` the file (and its linked folder, if any) to the new date |
| Changing an existing estimate | Present the changes in a table (with Effort change column and total AI Estimate before/after) and get confirmation before editing |
| Filling in the metadata table | Include one `AI Estimate` row; omit `Estimate` and `Human Estimate` |
| Writing the document body | Follow Metadata → 1 Scope → 2 Assumptions → 3 Breakdown → 4 Pricing (if quoted), in that order, with a unique index on every section and sub-section |
| Adding/removing an item | Next free index when adding; never renumber or reuse indices; keep the quotation's matching index in sync |
| Stating assumptions | List falsifiable conditions the estimate depends on, or note none exist |
| Pricing the estimate for a client, or a Zoho Books estimate | Load the **writing-quotations** skill |

## Common Mistakes

- Dating the filename by creation or approval date instead of `Date of assessment`.
- Leaving a stale date in the filename after the assessment is revised.
- Including both an `Estimate` row and an `AI Estimate` row, or adding a `Human Estimate` row.
- Omitting the Assumptions section, or burying assumptions inside the breakdown instead of stating them up front.
- Writing assumptions as vague hedges instead of falsifiable statements.
- Writing a client-facing price or quotation directly in this skill instead of loading **writing-quotations** for the pricing formula and quotation style.
- Leaving any section, sub-section, assumption, or breakdown item without an index, duplicating an index, or renumbering existing items so old references break.
- Letting the estimate's structure drift from the client quotation's (different top-level sections, or deliverables that don't map to a breakdown index).
- Editing the estimate document before showing the user the upcoming changes in a table, or leaving out the effort change / total `AI Estimate` delta.
- Remembering or reusing a client name across estimates instead of asking fresh every time.
