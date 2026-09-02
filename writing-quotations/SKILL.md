---
name: writing-quotations
description: "Use when computing a client-facing price/quotation from an AI Estimate, writing the actual client-facing quotation text, maintaining docs/QUOTES.md (the internal pricing-variable ledger of buffer multiplier, man-day hours, base man-day rate, and currency), or creating/updating an estimate in Zoho Books. Covers the fully-variablized pricing formula — never assume $ or any other value, always read docs/QUOTES.md or ask — writing the quotation in plain business bullet points (distinct from docs/QUOTES.md), the rule to only touch the sections the user asked about when editing a Zoho Books estimate, and always using service-type Zoho Books line items without exposing man-hour breakdowns unless explicitly requested. Always trigger when the user asks to price, quote, or create a client-facing quotation, or to create/update a Zoho Books estimate — even if they don't mention docs/QUOTES.md or Zoho Books by name. For sizing up the underlying work and writing the AI Estimate itself, see the estimate-project skill instead."
version: 1.0.1
---

# Writing Quotations Skill

## When to Use This Skill

Load this skill when you are:

- Computing a client-facing price/quotation from an `AI Estimate`
- Writing the actual client-facing quotation text (not `docs/QUOTES.md`, the internal pricing-variable ledger)
- Adding an entry to `docs/QUOTES.md`
- Creating or updating an estimate in Zoho Books

**This skill must always trigger whenever the user asks the agent to price, quote, or create a client-facing quotation** — even if the request doesn't mention `docs/QUOTES.md` or Zoho Books directly.

This skill assumes an `AI Estimate` already exists for the work being priced. If one hasn't been written yet, load the **estimate-project** skill first to size up the work and produce it.

---

## Pricing Method

When a client-facing quote is needed, derive the price from the `AI Estimate` with this formula. Every number in the formula is a named variable — none are hardcoded into the skill or the document:

- **Quoted time** = `buffer multiplier × AI Estimate` — client-facing buffer for review cycles, revisions, and coordination overhead not captured in raw active-session time. Typical value: `10`.
- **Man-day hours** = length of one billable man-day. Typical value: `6 hours`.
- **Price** = `(Quoted time / man-day hours) × base man-day rate`, denominated in `currency`.

Variables:

| Variable | Meaning | Source | Typical value |
|---|---|---|---|
| `AI Estimate` | Wall-clock active-session time, from the estimate document's metadata table | The estimate document | — |
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

Once the user provides a value, record it in `docs/QUOTES.md` so future estimates don't need to ask again. `QUOTES.md` is the append-only pricing-variable ledger for the whole directory, not a per-client document — edit it in place, never rename it.

Show the full derivation in the estimate document, not just the final figure, so the price is auditable:

```
AI Estimate: 3 hours
Buffer multiplier: 10
Quoted time: 10 × 3 hours = 30 hours
Man-day hours: 6
Base man-day rate: 800 USD
Currency: USD
Price: (30 / 6) × 800 USD = 4,000 USD
```

This derivation is the internal audit trail for the estimate document — it is not what gets sent to the client. When writing the actual client-facing quotation text, read `references/writing-quotations.md` first.

---

## Writing Client Quotations

The quotation is the pricing text a client actually reads — not to be confused with `docs/QUOTES.md`, the internal ledger of pricing variables. Read `references/writing-quotations.md` before writing or editing any client-facing quotation: lead with bullet points and plain business language, not the internal derivation or technical terms.

---

## Zoho Books Estimates

Creating or updating an estimate in Zoho Books (e.g. via `create_estimate` or `update_estimate`) has its own scoped-editing and line-item rules — read `references/zoho-books.md` first. This covers touching only the sections the user asked to change, always using `service`-type line items, and not exposing man-hour breakdowns unless explicitly requested.

---

## Quick Reference

| Situation | Action |
|---|---|
| Computing a client price | `Quoted time = buffer multiplier × AI Estimate`; `Price = (Quoted time / man-day hours) × base man-day rate`, in `currency`; get all four variables from `docs/QUOTES.md`, or ask the user |
| Writing the client-facing quotation text | See `references/writing-quotations.md` — bullet points, plain business language, outputs only (no internal derivation or jargon) |
| Updating a Zoho Books estimate | See `references/zoho-books.md` — `get_estimate` first, then `update_estimate` with only the fields the user asked to change |
| Creating/adding a Zoho Books line item | See `references/zoho-books.md` — use `service` item type; describe the deliverable, not man-hours, unless explicitly requested |
| Appending to the quotes ledger | Edit `docs/QUOTES.md` in place — never rename it |

## Common Mistakes

- Writing a hardcoded price without showing the `AI Estimate` → `Quoted time` → `base man-day rate` derivation.
- Assuming, inventing, or silently defaulting `buffer multiplier`, `man-day hours`, `base man-day rate`, or `currency` instead of reading them from `docs/QUOTES.md` or asking the user — including quietly using the "typical" values without confirming them, or assuming `$`/USD by default.
- Sending a client the internal derivation or jargon (`AI Estimate`, `buffer multiplier`, etc.) instead of a plain-language, bulleted quotation — see `references/writing-quotations.md`.
- Confusing the client-facing quotation with `docs/QUOTES.md`, which only tracks internal pricing variables and is never client-facing.
- Renaming `QUOTES.md` to a dated form.
- Overwriting or reformatting unrelated sections of a Zoho Books estimate when the user only asked to change one part of it — see `references/zoho-books.md`.
- Using a `goods`/inventory item type for a Zoho Books line item instead of `service`, or exposing man-hour breakdowns by default when the user never asked for them.
