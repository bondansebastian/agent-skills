---
name: writing-quotations
description: "Use when computing a client-facing price/quotation from an AI Estimate, writing the actual client-facing quotation text or document, maintaining this project's pricing-variable ledger (buffer multiplier, man-day hours, base man-day rate, and currency), or creating/updating an estimate in Zoho Books. Covers the fully-variablized pricing formula — never assume $ or any other value, always read the saved ledger in .agents/contexts/writing-quotations/MEMORY.md or ask — writing the quotation in plain business bullet points with a clear Deliverables section and a unique index on every section and sub-section, following this skill's fixed 4-section structure (Lingkup Pekerjaan, Deliverables, Catatan, Estimasi Waktu & Investasi) traceable back to the estimate document's Breakdown items via back-references, in Indonesian by default unless the user explicitly asks for another language (remembered per project in that same context file), always asking the client name and project name fresh for every quotation rather than reusing a remembered one, always saving it as a dated Markdown file under docs/quotations/ (the same naming convention as the estimate-project skill), always including a datetime-stamped Version in the quotation's meta that is refreshed on every update, only producing a polished .docx version when the user explicitly asks for one — never regenerating or auto-refreshing an existing docx off a later edit without a fresh explicit request each time — and, when a docx is generated, always writing it as a new file with the quotation's canonical `Versi` timestamp appended to the filename rather than overwriting any previously generated docx, the rule to only touch the sections the user asked about when editing a Zoho Books estimate, and always using service-type Zoho Books line items without exposing man-hour breakdowns unless explicitly requested. Always trigger when the user asks to price, quote, or create a client-facing quotation, or to create/update a Zoho Books estimate — even if they don't mention docs/quotations/ or Zoho Books by name. For sizing up the underlying work and writing the AI Estimate itself, see the estimate-project skill instead."
version: 1.10.0
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

**Every quotation section and sub-section carries a unique index.** The quotation has its own fixed four-section structure — it does not mirror the estimate document index-for-index — but Section 2 stays traceable back to the estimate's Breakdown items via explicit back-references (see below).

### Section 1 — Lingkup Pekerjaan (Scope)

Plain-language description of what's being built/delivered. Follows the single sub-item rule like every section: stays as one paragraph under index `1` until a second distinct point is needed, at which point it splits into `1.1`, `1.2`, .... A sub-item can itself carry further-nested clarifying notes when needed (e.g. `1.3` with `1.3.1`/`1.3.2` distinguishing two different meanings of an ambiguous term used in the scope).

### Section 2 — Deliverables

Opens with the line "Setelah proyek ini selesai, sistem akan memiliki:" (or the equivalent in the quotation's language). Deliverables are grouped by feature area, one group per `2.x` heading. Each group heading:

- carries an estimated effort figure in parentheses, e.g. `(~14,6 hari kerja)`
- references back, in parentheses, to the specific item indices in the source estimate document's Breakdown that this group summarizes, e.g. `(estimasi dari 3.1, 3.2 pada dokumen estimasi)` — so the two documents stay traceable to each other even though one `2.x` group can summarize several estimate Breakdown items at once

Under each group heading, individual deliverable bullets are indexed `2.x.1`, `2.x.2`, etc., stated as outcomes in plain client-facing language (no hours, no internal task names). Nesting goes arbitrarily deep when a deliverable bullet itself needs enumerated sub-points (`2.x.y.1`, `2.x.y.1.1`, `2.x.y.1.2`, ...) — depth is driven by content, never capped at a fixed level.

### Section 3 — Catatan (Notes)

A new section with no equivalent in the source estimate document. Always has exactly these two fixed subsections, in this order:

- **`3.1 Keputusan Teknis`** (Technical Decisions) — for each deliverable group from Section 2, a written explanation of the technical approach chosen to implement it, referencing back to that group's `2.x` index. Documents *how* each deliverable will be built, for transparency/audit — more detailed than the Deliverables section itself.
- **`3.2 Perlu Konfirmasi`** (Needs Confirmation) — an explicit list of open questions the client still needs to answer before or during the work, each indexed (`3.2.1`, `3.2.2`, ...). This replaces relying on chat history for open questions — they live in the document itself.

**There is deliberately no standalone "Asumsi" (Assumptions) section anymore.** Assumptions and design decisions are captured inside `3.1 Keputusan Teknis` instead, attached to the specific deliverable group they support rather than listed generically up front.

### Section 4 — Estimasi Waktu Pengerjaan & Investasi (Time & Investment)

- `4.1` — a single combined table showing total estimated working days **and** total price together (not split into a separate timeline index and a separate price index).
- `4.2`, `4.3`, `4.4`, ... — **"Opsi Tambahan"** (optional add-ons): each optional/extra scope item gets its own indexed subsection with (a) a prose description of what the option adds, (b) a before/after comparison table contrasting behavior without vs. with the option, and (c) the option's own incremental time and price figures, shown separately from the base estimate in `4.1`. These are priced items the client can accept or decline independently of the base quotation.
- final `4.x` (the next free index after the options) — **"Catatan Estimasi"** (Estimate Notes): a plain bullet list of exclusions and caveats (e.g. "tidak termasuk biaya hosting/infrastruktur", "tidak termasuk entri data awal").

### Indexing Rules (apply across all four sections)

- Use hierarchical decimal indices (`1`, `1.1`, `1.1.1`), written at the start of each heading/bullet, so any line can be cited by index alone. No duplicate indices, and no unnumbered sub-items except under the single sub-item rule below.
- **Single sub-item rule:** a section or sub-section with only one sub-item gets no sub-index — its text *is* the parent's own description (e.g. `1 Lingkup pekerjaan` followed by the one sentence, not `1.1`). Sub-indices exist only once a second item is added, at which point the agent **must restructure**: the existing description becomes `x.1` and the new item `x.2`.
- Indices are stable: new items take the next free index at that level; removed items' indices are never reused or renumbered.
- Reword everything for the client (outcomes, plain language, no hours anywhere in Sections 1–3 — time and price figures live only in Section 4).
- Whenever the estimate's Breakdown changes in a way that affects a `2.x` group's back-reference, tell the user the quotation needs the matching change (and vice versa).

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

**Output format**: write the quotation as a `.md` file by default. Only build a `.docx` version when the user explicitly asks for a Word document/docx **in that turn** — don't produce one preemptively "just in case," and don't regenerate or refresh an existing docx on your own initiative after editing the `.md` source; a docx is only (re)built in direct response to an explicit user request, every single time, even if one was generated earlier for the same quotation. When a docx is requested, generate it from the same Markdown content (don't hand-author a separate copy that can drift from it) using whatever document-creation tooling is available in the current environment — an installed docx-generation skill/tool, or `pandoc` — to produce a genuinely polished document: proper heading styles, real bullet lists, and readable typography, not a bare text dump styled as "Normal" throughout.

**Never overwrite an existing docx.** Each time a docx is generated (first time or any later regeneration), write it as a brand-new file rather than replacing a previously generated one — so earlier snapshots stay on disk and recoverable. Name it after the Markdown source with the quotation's current `Versi` timestamp (see Quotation Meta & Version below) appended, using the same dot-separated format:

```
docs/quotations/YYYY-MM-DD-<client>-<project-slug>.<Versi>.docx
```

e.g. `2026-09-21-acme-portal-redesign.2026.09.21.14.35.docx`. Re-read the quotation's current `Versi` stamp from the `.md` file immediately before naming the docx, so the timestamp in the filename always matches the content it was built from.

---

## Refresh Before Working — Latest Version Is the Source of Truth

Before writing a new quotation or writing into an existing one, **re-read the current quotation file from disk first** (`docs/quotations/...`) and the estimate document it is priced from (`docs/estimates/...`). Never work from an earlier read, from conversation memory, or from a copy you wrote earlier in the session — the user or another agent may have edited either file since.

- Treat the **latest version on disk as the source of truth.** If it differs from what you remember or what the user described, the file wins; mention the difference instead of silently overwriting it.
- Use the quotation's `Versi` stamp (below) to judge which copy is newest; price from the estimate's current `AI Estimate`, not a remembered figure. If the estimate and quotation have drifted apart, flag it and say which needs the matching change.
- Build the confirmation table from the freshly read content, so the Before column reflects what is actually in the file.
- Re-read again if time passed or other edits may have happened between confirmation and writing.

**Explicit refresh command:** when the user says "refresh the data" — or any similar phrasing with the same intent (e.g. "reload the docs", "sync with the file", "re-read the latest", "I edited the file, update your context") — treat it as an instruction to re-read the quotation document(s) in context (and the source estimate) from disk right now, discard whatever earlier copy is held in context, and treat the latest physical document as the truth from then on. Confirm briefly what was refreshed and note any differences from the earlier copy; don't make edits as part of the refresh unless the user also asked for them.

---

## Quotation Meta & Version

Every quotation must open with a small meta block (a table or bullet list at the top of the file) that **always includes a `Versi` (Version) field holding a datetime stamp**:

```
| Versi | 2026.09.21.14.35 |
```

- Format: `YYYY.MM.DD.HH.mm` in the user's local time, 24-hour, zero-padded (e.g. `2026.09.21.14.35`). Get the real current time (e.g. run `date`) — never guess or reuse an old value.
- **Set it when the quotation is first written, and update it every time the agent changes the quotation** (after the user confirms the changes per the section below). Update it in the same edit as the content change, so the stamp always reflects the last modification. Don't bump it if nothing changed.
- The version is a stamp, not a counter — replace the old value rather than appending a history.
- If a `.docx` is (re)generated for the quotation — only ever on an explicit user request, see Quotation Documents above — carry the same Version value into it and into the docx's filename (never overwrite a previously generated docx; each generation is a new, separately timestamped file). When the change is also mirrored into a Zoho Books estimate, leave the Zoho fields alone unless the user asked otherwise (see `references/zoho-books.md`).
- The Version row is not an indexed section; it sits in the meta block alongside the client and project name.

---

## Confirm Changes Before Editing

Before changing an existing quotation document (`docs/quotations/...`, or a `.docx` generated from it), **always present the upcoming changes to the user in a table first, and only edit after they confirm.** Never edit the quotation and describe the change afterward.

The table has one row per change, in client-facing terms:

| Index | Section / Item | Change | Before | After |
|---|---|---|---|---|
| 2.2.1 | Deliverables: Admin dashboard | Added | — | Dashboard admin untuk mengelola pengguna |
| 4.1 | Estimasi waktu & Investasi | Modified | ~2 minggu / 2.400.000 IDR | ~2,5 minggu / 3.000.000 IDR |
| 4.2 | Opsi Tambahan: Integrasi pembayaran | Removed | — | — |

- Always include the **Index** column (next free index for additions).
- Include the price (and currency) as a row whenever it changes, so the user sees the money impact before it lands.
- Show every change that will be made, and nothing that won't be — the table must match the edit exactly.
- If the user adjusts the proposal, present the revised table again before editing.
- The Version stamp is refreshed automatically as part of any confirmed edit; no need to list it as a row.
- For a brand-new quotation, present the proposed sections (Deliverables, price, etc.) in the same table form (Before shown as `—`) before writing the file.
- The same rule applies to Zoho Books estimates — see `references/zoho-books.md`.

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
| Producing a Word version | Only when explicitly requested, every time (never auto-regenerate) — generate the `.docx` from the same Markdown content, don't hand-author a separate copy, and write it as a new file named with the current `Versi` timestamp rather than overwriting any earlier docx |
| Structuring the quotation | Fixed 4-section structure with a unique hierarchical index on every section/sub-section: `1` Lingkup Pekerjaan, `2` Deliverables (grouped `2.x` headings back-referencing the estimate's Breakdown items), `3` Catatan (`3.1` Keputusan Teknis, `3.2` Perlu Konfirmasi — no standalone Asumsi section), `4` Estimasi Waktu & Investasi (`4.1` combined time+price, `4.2+` Opsi Tambahan, final `4.x` Catatan Estimasi) |
| User says "refresh the data" (or similar) | Re-read the quotation/estimate documents in context from disk, drop the earlier copy, treat the latest physical file as the truth; report differences, don't edit |
| Before a new quotation or any write to the document | Re-read the latest quotation and its source estimate from disk; the latest version is the source of truth |
| Versioning a quotation | Always keep a `Versi` datetime stamp (`YYYY.MM.DD.HH.mm`, from `date`) in the meta block; set on creation and refresh on every update |
| Changing an existing quotation | Present the changes in a table (index, section, change, before, after, incl. price) and get confirmation before editing |
| Updating a Zoho Books estimate | See `references/zoho-books.md` — `get_estimate` first, then `update_estimate` with only the fields the user asked to change |
| Creating/adding a Zoho Books line item | See `references/zoho-books.md` — use `service` item type; describe the deliverable, not man-hours, unless explicitly requested |
| Recording a pricing variable | Save it to `.agents/contexts/writing-quotations/MEMORY.md` once confirmed by the user |

## Common Mistakes

- Ignoring a "refresh the data" (or similar) request and continuing from the copy already in context instead of re-reading the documents from disk.
- Writing or pricing from a stale earlier read or from memory instead of re-reading the latest quotation and estimate files first, or overriding newer on-disk content with an older copy.
- Writing a hardcoded price without showing the `AI Estimate` → `Quoted time` → `base man-day rate` derivation.
- Assuming, inventing, or silently defaulting `buffer multiplier`, `man-day hours`, `base man-day rate`, or `currency` instead of reading them from `MEMORY.md` or asking the user — including quietly using the default values without confirming them, or assuming `$`/USD by default.
- Sending a client the internal derivation or jargon (`AI Estimate`, `buffer multiplier`, etc.) instead of a plain-language, bulleted quotation — see `references/writing-quotations.md`.
- **Remembering or reusing a client name or project name across quotations** instead of asking fresh every time — this is the opposite of the pricing variables, which genuinely are worth remembering.
- Skipping the `docs/quotations/` file and only pasting the quotation text into the conversation.
- Building a `.docx` by default without being asked, or hand-writing a docx that can drift from the `.md` source instead of generating it from that same content.
- Regenerating or refreshing an existing `.docx` on your own initiative after editing the quotation, instead of waiting for a fresh, explicit docx request each time.
- Overwriting a previously generated `.docx` instead of writing each generation as its own new file named with the quotation's current `Versi` timestamp.
- Blocking on, or repeatedly re-asking for, the client name or project name instead of falling back to a content-based value when the user doesn't answer.
- Re-asking for a pricing variable every time instead of checking `.agents/contexts/writing-quotations/MEMORY.md` first.
- Silently reusing a non-Indonesian language for a new quotation in the same project without it having been saved to `MEMORY.md` as this project's preference.
- Giving a section a lone sub-item (`1.1` with no `1.2`) instead of making it the section description, or adding a second item without restructuring the section.
- Leaving any quotation section or sub-section unindexed, duplicating an index, or renumbering existing items.
- Reintroducing a standalone "Asumsi" (Assumptions) section — assumptions belong inside `3.1 Keputusan Teknis`, attached to the deliverable group they support, not listed generically up front.
- Numbering Deliverables at index `3` (the old mapping) instead of `2`, or omitting a `2.x` group's back-reference to the estimate Breakdown items it summarizes.
- Collapsing `3.1 Keputusan Teknis` and `3.2 Perlu Konfirmasi` back into a single "Catatan"/"Asumsi" section instead of keeping both fixed subsections.
- Omitting a Deliverables section, or describing deliverables as internal tasks/hours instead of outcomes the client will receive.
- Writing the quotation in English (or any language) by default instead of Indonesian, without the user having asked for it.
- Omitting the `Versi` datetime stamp from the quotation meta, or editing the quotation without refreshing it (or guessing the time instead of reading it).
- Editing a quotation (or Zoho Books estimate) before showing the user the upcoming changes in a table and getting confirmation.
- Overwriting or reformatting unrelated sections of a Zoho Books estimate when the user only asked to change one part of it — see `references/zoho-books.md`.
- Using a `goods`/inventory item type for a Zoho Books line item instead of `service`, or exposing man-hour breakdowns by default when the user never asked for them.
