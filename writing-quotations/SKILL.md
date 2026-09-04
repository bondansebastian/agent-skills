---
name: writing-quotations
description: "Use when computing a client-facing price/quotation from an AI Estimate, writing the actual client-facing quotation text or document, maintaining this project's pricing-variable ledger (buffer multiplier, man-day hours, base man-day rate, and currency), or creating/updating an estimate in Zoho Books. Covers the fully-variablized pricing formula — never assume $ or any other value, always read the saved ledger in .agents/contexts/writing-quotations/MEMORY.md or ask — writing the quotation in plain business bullet points with a clear Deliverables section, in Indonesian by default unless the user explicitly asks for another language (remembered per project in that same context file), always asking the client name and project name fresh for every quotation rather than reusing a remembered one, always saving it as a dated Markdown file under docs/quotations/ (the same naming convention as the estimate-project skill), only producing a polished .docx version when the user explicitly asks for one, the rule to only touch the sections the user asked about when editing a Zoho Books estimate, and always using service-type Zoho Books line items without exposing man-hour breakdowns unless explicitly requested. Always trigger when the user asks to price, quote, or create a client-facing quotation, or to create/update a Zoho Books estimate — even if they don't mention docs/quotations/ or Zoho Books by name. For sizing up the underlying work and writing the AI Estimate itself, see the estimate-project skill instead."
version: 1.5.0
---

# Writing Quotations Skill

## When to Use This Skill

Load this skill when you are:

- Computing a client-facing price/quotation from an `AI Estimate`
- Writing the actual client-facing quotation text or document
- Recording or updating this project's pricing-variable ledger (buffer multiplier, man-day hours, base man-day rate, currency)
- Creating or updating an estimate in Zoho Books

**This skill must always trigger whenever the user asks the agent to price, quote, or create a client-facing quotation** — even if the request doesn't mention pricing variables or Zoho Books directly.

This skill assumes an `AI Estimate` already exists for the work being priced. If one hasn't been written yet, load the **estimate-project** skill first to size up the work and produce it.

---

## Where This Skill Stores Context

This skill remembers non-sensitive, project-specific context across invocations instead of re-asking every time. Store and read it at:

```
<project-root>/.agents/contexts/writing-quotations/MEMORY.md
```

Take `<project-root>` as the root of the project you're currently working in — never the skill's own folder, so this works the same whether the skill is installed locally or globally. Create the folder and file if they don't exist yet; don't wait for one to already be there. Re-derive `<project-root>` whenever the active project changes within a session.

Store:

- **Pricing variables** — `buffer multiplier`, `man-day hours`, `base man-day rate`, `currency`. See Pricing Method below for the full read/ask/save rule.
- **Language preference** — only when the user explicitly asks for quotations in this project to default to a language other than Indonesian going forward. Don't write anything when Indonesian is simply used without comment; the absence of an entry means "use the Indonesian default."

**Never store the client name or the project name here (or anywhere else).** Both are asked fresh for every single quotation — see Quotation Documents below. Unlike pricing variables or a language default, the client and project a quotation is for can change from one quotation to the next even within the same repo, so a remembered value would risk silently mislabeling a quotation for the wrong client.

**Resolving the language:** check this skill's `MEMORY.md` for a saved preference before applying the Indonesian default described below.

---

## Pricing Method

When a client-facing quote is needed, derive the price from the `AI Estimate` with this formula. Every number in the formula is a named variable — none are hardcoded into the skill or the document:

- **Quoted time** = `buffer multiplier × AI Estimate` — client-facing buffer for review cycles, revisions, and coordination overhead not captured in raw active-session time. Default value: `6`.
- **Man-day hours** = length of one billable man-day. Typical value: `6 hours`.
- **Price** = `(Quoted time / man-day hours) × base man-day rate`, denominated in `currency`.

Variables:

| Variable | Meaning | Source | Default value |
|---|---|---|---|
| `AI Estimate` | Wall-clock active-session time, from the estimate document's metadata table | The estimate document | — |
| `Quoted time` | `buffer multiplier × AI Estimate` | Derived | — |
| `buffer multiplier` | How many times over the AI Estimate to quote, to cover review cycles, revisions, and coordination overhead | This skill's `MEMORY.md` (see Where This Skill Stores Context), or ask the user | `6` |
| `man-day hours` | Hours in one billable man-day | This skill's `MEMORY.md`, or ask the user | `6` |
| `base man-day rate` | Client/org day rate used to convert time into money | This skill's `MEMORY.md`, or ask the user | — |
| `currency` | Unit `base man-day rate` and `Price` are denominated in (e.g. `USD`, `IDR`, `EUR`) | This skill's `MEMORY.md`, or ask the user | — |

**Before writing a price, check this skill's `MEMORY.md` for existing values of `buffer multiplier`, `man-day hours`, `base man-day rate`, and `currency`.** For any of the four not yet recorded there, ask the user for it — do not assume, invent, or silently default a value, including the currency symbol/code, even the defaults above. When asking, explain what each is for:

- `buffer multiplier`: scales `AI Estimate` up into `Quoted time` to cover review cycles, revisions, and coordination overhead the raw session time doesn't capture.
- `man-day hours`: the divisor that converts `Quoted time` into a number of man-days.
- `base man-day rate`: the day rate that turns man-days into a final price.
- `currency`: the unit that rate and price are denominated in — never assume `$`/USD by default.

Once the user provides a value, save it to `MEMORY.md` so future quotations in this project don't need to ask again. Unlike the client and project name, these variables are genuinely stable for a project (they describe how *this* business prices *any* of its work), which is why they're the one thing in this skill worth remembering across quotations.

Show the full derivation in the estimate document, not just the final figure, so the price is auditable:

```
AI Estimate: 3 hours
Buffer multiplier: 6
Quoted time: 6 × 3 hours = 18 hours
Man-day hours: 6
Base man-day rate: 800 USD
Currency: USD
Price: (18 / 6) × 800 USD = 2,400 USD
```

This derivation is the internal audit trail for the estimate document — it is not what gets sent to the client. When writing the actual client-facing quotation text, read `references/writing-quotations.md` first.

---

## Writing Client Quotations

The quotation is the pricing text a client actually reads — not to be confused with this skill's internal pricing-variable context. Read `references/writing-quotations.md` before writing or editing any client-facing quotation: lead with bullet points and plain business language, not the internal derivation or technical terms.

Every quotation must also state **Deliverables** — the concrete things the client will receive (features shipped, documents handed over, environments set up), stated as outcomes, not as the internal task breakdown from the estimate document. A client reading the quotation should know exactly what they're getting for the price, not just how long it takes.

**Write the quotation in Indonesian by default.** Check this skill's `MEMORY.md` (see Where This Skill Stores Context above) for a saved language preference for this project first; if there isn't one, default to Indonesian. Only use another language when the user explicitly asks for it (e.g. the client is international, or the user says to write it in English) — and if they indicate this should apply to future quotations in this project too, save that preference to `MEMORY.md`. Don't infer the language from the client's name or domain.

---

## Quotation Documents

By default, write every client-facing quotation as its own dated Markdown document under `docs/quotations/`, using the same date-prefixed naming convention as the **estimate-project** skill uses for estimates:

```
docs/quotations/YYYY-MM-DD-<client>-<project-slug>.md
```

- The date is the date the quotation is written/issued.
- Linked-file folders use the same dated basename as the file they contain, so the folder and file stay matched: `docs/quotations/YYYY-MM-DD-<client>-<project-slug>/`.

**Before writing the file, ask the user for the client name and the project name** — they fill `<client>` and `<project-slug>`. Ask fresh every time, even if a previous quotation in this project named a client — never reuse or remember a prior answer (see Where This Skill Stores Context above for why). If the user doesn't answer either one (they move on, say "you pick," or otherwise leave it open), don't block on it or ask again: derive a sensible value yourself from the quotation's own content — the scope description, prior correspondence, or the estimate document it's priced from — rather than leaving a placeholder.

**Output format**: write the quotation as a `.md` file by default. Only build a `.docx` version when the user explicitly asks for a Word document/docx — don't produce one preemptively "just in case." When a docx is requested, generate it from the same Markdown content (don't hand-author a separate copy that can drift from it) using whatever document-creation tooling is available in the current environment — an installed docx-generation skill/tool, or `pandoc` — to produce a genuinely polished document: proper heading styles, real bullet lists, and readable typography, not a bare text dump styled as "Normal" throughout.

---

## Zoho Books Estimates

Creating or updating an estimate in Zoho Books (e.g. via `create_estimate` or `update_estimate`) has its own scoped-editing and line-item rules — read `references/zoho-books.md` first. This covers touching only the sections the user asked to change, always using `service`-type line items, and not exposing man-hour breakdowns unless explicitly requested.

---

## Quick Reference

| Situation | Action |
|---|---|
| Computing a client price | `Quoted time = buffer multiplier × AI Estimate`; `Price = (Quoted time / man-day hours) × base man-day rate`, in `currency`; get all four variables from this skill's `MEMORY.md`, or ask the user |
| Writing the client-facing quotation text | See `references/writing-quotations.md` — bullet points, plain business language, outputs only (no internal derivation or jargon), always including a Deliverables list |
| Choosing the language | Check `.agents/contexts/writing-quotations/MEMORY.md` for a saved preference; otherwise Indonesian by default, another language only if the user explicitly asks |
| Asking the client name and project name | Always ask fresh for every quotation — never read from or write to `MEMORY.md` |
| Saving the quotation document | Ask for the client name and the project name, then write `docs/quotations/YYYY-MM-DD-<client>-<project-slug>.md` as `.md` by default |
| No answer on client/project name | Derive it from the quotation's own content (scope, prior correspondence, or source estimate) — don't block or leave a placeholder |
| Producing a Word version | Only when explicitly requested — generate the `.docx` from the same Markdown content, don't hand-author a separate copy |
| Updating a Zoho Books estimate | See `references/zoho-books.md` — `get_estimate` first, then `update_estimate` with only the fields the user asked to change |
| Creating/adding a Zoho Books line item | See `references/zoho-books.md` — use `service` item type; describe the deliverable, not man-hours, unless explicitly requested |
| Recording a pricing variable | Save it to `.agents/contexts/writing-quotations/MEMORY.md` once confirmed by the user |

## Common Mistakes

- Writing a hardcoded price without showing the `AI Estimate` → `Quoted time` → `base man-day rate` derivation.
- Assuming, inventing, or silently defaulting `buffer multiplier`, `man-day hours`, `base man-day rate`, or `currency` instead of reading them from `MEMORY.md` or asking the user — including quietly using the default values without confirming them, or assuming `$`/USD by default.
- Sending a client the internal derivation or jargon (`AI Estimate`, `buffer multiplier`, etc.) instead of a plain-language, bulleted quotation — see `references/writing-quotations.md`.
- **Remembering or reusing a client name or project name across quotations** instead of asking fresh every time — this is the opposite of the pricing variables, which genuinely are worth remembering.
- Skipping the `docs/quotations/` file and only pasting the quotation text into the conversation.
- Building a `.docx` by default without being asked, or hand-writing a docx that can drift from the `.md` source instead of generating it from that same content.
- Blocking on, or repeatedly re-asking for, the client name or project name instead of falling back to a content-based value when the user doesn't answer.
- Re-asking for a pricing variable every time instead of checking `.agents/contexts/writing-quotations/MEMORY.md` first.
- Silently reusing a non-Indonesian language for a new quotation in the same project without it having been saved to `MEMORY.md` as this project's preference.
- Omitting a Deliverables section, or describing deliverables as internal tasks/hours instead of outcomes the client will receive.
- Writing the quotation in English (or any language) by default instead of Indonesian, without the user having asked for it.
- Overwriting or reformatting unrelated sections of a Zoho Books estimate when the user only asked to change one part of it — see `references/zoho-books.md`.
- Using a `goods`/inventory item type for a Zoho Books line item instead of `service`, or exposing man-hour breakdowns by default when the user never asked for them.
