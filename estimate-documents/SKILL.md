---
name: estimate-documents
description: "Use when creating, naming, renaming, or filling in the metadata table of estimate documents under docs/estimates/ — covers date-prefixed filenames keyed to the Date of assessment field, the required AI Estimate metadata row, the required Scope/Assumptions/Breakdown structure, and the fully-variablized pricing formula (buffer multiplier, man-day hours, base man-day rate, currency — never assume $) for client-facing quotations. Always trigger when the user asks to write, draft, or create an estimate."
version: 1.5.0
---

# Estimate Documents Skill

## When to Use This Skill

Load this skill when you are:

- Creating a new client estimate document
- Renaming an estimate document after its `Date of assessment` changes
- Writing or reviewing an estimate document's metadata table
- Computing a client-facing price/quotation from an `AI Estimate`
- Adding an entry to `docs/QUOTES.md`

**This skill must always trigger whenever the user asks the agent to write, draft, or create an estimate** — even if the request doesn't mention filenames, metadata, or `docs/estimates/` directly.

---

## Filename Convention

Estimate document filenames in `docs/` must always be prefixed with the date, using the **Date of assessment** field from the document's own metadata table:

```
docs/estimates/YYYY-MM-DD-<client>-<short-slug>.md
```

- The date is `Date of assessment` — not the file's creation date and not an approval date.
- If `Date of assessment` changes (e.g. the assessment is revisited before approval), rename the file (`git mv`) to match. Don't leave a stale date in the filename.
- Linked-file folders use the same dated basename as the file they contain, so the folder and file stay matched: `docs/estimates/YYYY-MM-DD-<client>-<short-slug>/`.
- **`QUOTES.md` is excluded from this rule.** It's the append-only quotes ledger for the whole directory, not a per-client estimate document, so it keeps its plain filename — never rename it to a dated form.

---

## Document Structure

Every estimate document must follow this structured format, in order:

1. **Metadata table** — see [Metadata: AI Estimate](#metadata-ai-estimate) below.
2. **Scope** — what work is being estimated, in plain terms.
3. **Assumptions** — see [Assumptions](#assumptions) below. Required even if short.
4. **Breakdown** — the tasks or phases that make up the estimate, each with its own time figure, summing to the top-level `AI Estimate`.
5. **Pricing** (only when a client-facing quote is requested) — see [Pricing Method](#pricing-method) below.

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

## Pricing Method

When a client-facing quote is needed, derive the price from the `AI Estimate` with this formula. Every number in the formula is a named variable — none are hardcoded into the skill or the document:

- **Quoted time** = `buffer multiplier × AI Estimate` — client-facing buffer for review cycles, revisions, and coordination overhead not captured in raw active-session time. Typical value: `10`.
- **Man-day hours** = length of one billable man-day. Typical value: `6 hours`.
- **Price** = `(Quoted time / man-day hours) × base man-day rate`, denominated in `currency`.

Variables:

| Variable | Meaning | Source | Typical value |
|---|---|---|---|
| `AI Estimate` | Wall-clock active-session time, from the metadata table | This document | — |
| `Quoted time` | `buffer multiplier × AI Estimate` | Derived | — |
| `buffer multiplier` | How many times over the AI Estimate to quote, to cover review cycles, revisions, and coordination overhead | `docs/QUOTES.md`, or ask the user | `10` |
| `man-day hours` | Hours in one billable man-day | `docs/QUOTES.md`, or ask the user | `6` |
| `base man-day rate` | Client/org day rate used to convert time into money | `docs/QUOTES.md`, or ask the user | — |
| `currency` | Unit `base man-day rate` and `Price` are denominated in (e.g. `USD`, `IDR`, `EUR`) | `docs/QUOTES.md`, or ask the user | — |

**Before writing a price, check `docs/QUOTES.md` for existing values of `buffer multiplier`, `man-day hours`, `base man-day rate`, and `currency`.** For any of the four not yet recorded there, ask the user for it — do not assume, invent, or silently default a value, including the currency symbol/code, even the typical ones above. When asking, explain what each is for:

- `buffer multiplier`: scales `AI Estimate` up into `Quoted time` to cover review cycles, revisions, and coordination overhead the raw session time doesn't capture.
- `man-day hours`: the divisor that converts `Quoted time` into a number of man-days.
- `base man-day rate`: the day rate that turns man-days into a final price.
- `currency`: the unit that rate and price are denominated in — never assume `$`/USD by default.

Once the user provides a value, record it in `docs/QUOTES.md` so future estimates don't need to ask again.

Show the full derivation in the document, not just the final figure, so the price is auditable:

```
AI Estimate: 3 hours
Buffer multiplier: 10
Quoted time: 10 × 3 hours = 30 hours
Man-day hours: 6
Base man-day rate: 800 USD
Currency: USD
Price: (30 / 6) × 800 USD = 4,000 USD
```

---

## Quick Reference

| Situation | Action |
|---|---|
| Creating a new estimate | Write to `docs/estimates/YYYY-MM-DD-<client>-<slug>.md` using today's `Date of assessment` |
| `Date of assessment` changes | `git mv` the file (and its linked folder, if any) to the new date |
| Filling in the metadata table | Include one `AI Estimate` row; omit `Estimate` and `Human Estimate` |
| Writing the document body | Follow Metadata → Scope → Assumptions → Breakdown → Pricing (if quoted), in that order |
| Stating assumptions | List falsifiable conditions the estimate depends on, or note none exist |
| Computing a client price | `Quoted time = buffer multiplier × AI Estimate`; `Price = (Quoted time / man-day hours) × base man-day rate`, in `currency`; get all four variables from `docs/QUOTES.md`, or ask the user |
| Appending to the quotes ledger | Edit `docs/QUOTES.md` in place — never rename it |

## Common Mistakes

- Dating the filename by creation or approval date instead of `Date of assessment`.
- Leaving a stale date in the filename after the assessment is revised.
- Including both an `Estimate` row and an `AI Estimate` row, or adding a `Human Estimate` row.
- Renaming `QUOTES.md` to a dated form.
- Omitting the Assumptions section, or burying assumptions inside the breakdown instead of stating them up front.
- Writing assumptions as vague hedges instead of falsifiable statements.
- Writing a hardcoded price without showing the `AI Estimate` → `Quoted time` → `base man-day rate` derivation.
- Assuming, inventing, or silently defaulting `buffer multiplier`, `man-day hours`, `base man-day rate`, or `currency` instead of reading them from `docs/QUOTES.md` or asking the user — including quietly using the "typical" values without confirming them, or assuming `$`/USD by default.
