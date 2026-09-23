---
name: estimate-project
description: "Use when creating, naming, renaming, or filling in the metadata table of a project estimate document under docs/estimates/ — covers date-prefixed filenames keyed to the Date of assessment field, the required AI Estimate metadata row (never a separate Estimate or Human Estimate row), and the required Scope/Assumptions/Breakdown document structure with a unique index on every section and sub-section (traceable, but not mirrored index-for-index, from the client quotation's Deliverables groups via back-references). Always asks the client name fresh for every new estimate rather than remembering it. Always trigger when the user asks to estimate a project, size up a task, scope out how long something will take, or write/draft/create an estimate document — even if the request doesn't mention filenames, metadata, or docs/estimates/ directly. For turning the estimate into a client-facing price or quotation, tracking pricing variables, or Zoho Books estimates, see the writing-quotations skill instead."
version: 1.5.0
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
- **Every** section and sub-section gets an index — including each individual assumption (`2.1`, `2.2`, …) and each breakdown item — except under the single sub-item rule below. No duplicate indices.
- **Single sub-item rule:** a section with only one sub-item gets no sub-index — the sub-item's text *is* the section's description (e.g. `## 2 Assumptions` followed by the one assumption as plain text, not `2.1`). Sub-indices exist only when a section has two or more sub-items. When a later change adds a second item, the agent **must restructure that section**: the existing description becomes `x.1`, the new item becomes `x.2`. The same applies in reverse when removal leaves one item — but only for sections whose remaining item has no index cited elsewhere; otherwise keep the sub-index to avoid breaking references.
- Indices are **stable**: when adding an item, take the next free index at that level; when removing one, don't renumber the others or reuse its index (note it as `3.2 (removed)` only if needed). References from confirmations, quotations, and Zoho Books must stay valid.
- **The client quotation does not mirror this structure index-for-index** (see the **writing-quotations** skill) — it has its own fixed structure (`1` Lingkup Pekerjaan, `2` Deliverables, `3` Catatan, `4` Estimasi Waktu & Investasi), including sections with no equivalent here at all (`3.1 Keputusan Teknis`, `3.2 Perlu Konfirmasi` — this is also where quotation-side assumptions live, since the quotation has no standalone Assumptions section). Traceability instead runs through the quotation's `2.x` Deliverables groups: each one carries a back-reference in parentheses to the specific Breakdown item(s) here that it summarizes (e.g. quotation `2.1` `— (estimasi dari 3.1, 3.2)`), and one `2.x` group may summarize several Breakdown items at once — it is a back-reference, not a shared index. When this document's Breakdown items change in a way that affects a `2.x` group's back-reference, flag that the quotation needs the matching change.

---

## Refresh Before Working — Latest Version Is the Source of Truth

Before making a new estimate for an existing project, or writing anything into an estimate document, **re-read the current estimate file from disk first** (and the matching quotation under `docs/quotations/`, if one exists). Never work from an earlier read, from conversation memory, or from a copy you wrote earlier in the session — the user or another agent may have edited the file since.

- Treat the **latest version on disk as the source of truth.** If it differs from what you remember or what the user described, the file wins; mention the difference instead of silently overwriting it.
- Compare the file's metadata `Version`/last-modified state (and the quotation's `Versi` stamp, if present) when deciding what is current; if the estimate and quotation disagree, flag it and tell the user which document needs the matching change.
- Build the confirmation table below from the freshly read content, so the Before column reflects what is actually in the file.
- Re-read again if time passed or other edits may have happened between confirmation and writing.

**Explicit refresh command:** when the user says "refresh the data" — or any similar phrasing with the same intent (e.g. "reload the docs", "sync with the file", "re-read the latest", "I edited the file, update your context") — treat it as an instruction to re-read the estimate document(s) in context (and the matching quotation) from disk right now, discard whatever earlier copy is held in context, and treat the latest physical document as the truth from then on. Confirm briefly what was refreshed and note any differences from the earlier copy; don't make edits as part of the refresh unless the user also asked for them.

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
| User says "refresh the data" (or similar) | Re-read the estimate/quotation documents in context from disk, drop the earlier copy, treat the latest physical file as the truth; report differences, don't edit |
| Before a new estimate or any write to the document | Re-read the latest file (and matching quotation) from disk; the latest version is the source of truth |
| Changing an existing estimate | Present the changes in a table (with Effort change column and total AI Estimate before/after) and get confirmation before editing |
| Filling in the metadata table | Include one `AI Estimate` row; omit `Estimate` and `Human Estimate` |
| Writing the document body | Follow Metadata → 1 Scope → 2 Assumptions → 3 Breakdown → 4 Pricing (if quoted), in that order, with a unique index on every section and sub-section |
| Adding/removing an item | Next free index when adding; never renumber or reuse indices; flag the quotation if the change affects a `2.x` group's back-reference to this item |
| Stating assumptions | List falsifiable conditions the estimate depends on, or note none exist |
| Pricing the estimate for a client, or a Zoho Books estimate | Load the **writing-quotations** skill |

## Common Mistakes

- Ignoring a "refresh the data" (or similar) request and continuing from the copy already in context instead of re-reading the documents from disk.
- Editing or re-estimating from a stale earlier read or from memory instead of re-reading the latest file first, or overriding newer on-disk content with an older copy.
- Dating the filename by creation or approval date instead of `Date of assessment`.
- Leaving a stale date in the filename after the assessment is revised.
- Including both an `Estimate` row and an `AI Estimate` row, or adding a `Human Estimate` row.
- Omitting the Assumptions section, or burying assumptions inside the breakdown instead of stating them up front.
- Writing assumptions as vague hedges instead of falsifiable statements.
- Writing a client-facing price or quotation directly in this skill instead of loading **writing-quotations** for the pricing formula and quotation style.
- Giving a section a lone sub-item (`2.1` with no `2.2`) instead of making it the section description, or adding a second item without restructuring the section.
- Leaving any section, sub-section, assumption, or breakdown item without an index, duplicating an index, or renumbering existing items so old references break.
- Omitting a `2.x` back-reference in the quotation when a Breakdown item it summarizes changes, or expecting the quotation's top-level sections to match this document's (they don't — see Section Indexing).
- Editing the estimate document before showing the user the upcoming changes in a table, or leaving out the effort change / total `AI Estimate` delta.
- Remembering or reusing a client name across estimates instead of asking fresh every time.
