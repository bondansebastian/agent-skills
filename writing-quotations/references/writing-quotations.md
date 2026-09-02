# Writing Client Quotations

A **quotation** is the client-facing pricing communication itself — the text a client actually reads (the Pricing section of an estimate document, a Zoho Books estimate, or a standalone quote message). This is distinct from `docs/QUOTES.md`, which is an internal ledger of pricing variables (`buffer multiplier`, `man-day hours`, `base man-day rate`, `currency`) and is never sent to a client.

## Language

**Write in Indonesian by default.** Only switch to another language when the user explicitly asks for it — e.g. they say "write it in English," or the client is clearly international and the user asks for that. Don't guess the language from the client's name, domain, or industry; the default is Indonesian until told otherwise.

## Style Rules

- **Lead with bullet points.** Present the key facts — scope, deliverables, timeline, price — as a scannable bullet list, not prose paragraphs.
- **Use business language, not technical or internal jargon.** A client shouldn't need to understand how the number was produced to understand what they're paying for. Rephrase internal terms:
  - `AI Estimate` — don't expose this term to the client at all.
  - `buffer multiplier` — don't expose the multiplier; state only the resulting timeline.
  - `Quoted time` — present as a plain timeline (e.g. "estimated turnaround" / "estimasi waktu pengerjaan").
  - `base man-day rate` — "daily rate" or "day rate" if a rate needs to be shown at all.
  - `Price` — "Investment" ("Investasi") or "Total" reads better to a client than an internal derivation label.
- **Always include a Deliverables section.** State the concrete things the client will receive — features shipped, documents handed over, environments configured — as outcomes, not as the internal task/hour breakdown from the estimate document's Breakdown section. This is what tells the client exactly what they're paying for, separate from how long it takes or what it costs.
- **Show outputs, not derivation.** The full `AI Estimate → Quoted time → Price` derivation from the Pricing Method belongs in the estimate document's audit trail — it is not what goes into the client-facing quotation.

## Example

Internal audit trail (stays in the estimate document, not sent to client):

```
AI Estimate: 3 hours
Buffer multiplier: 10
Quoted time: 10 × 3 hours = 30 hours
Man-day hours: 6
Base man-day rate: 800 USD
Price: (30 / 6) × 800 USD = 4,000 USD
```

Client-facing quotation, written from the same numbers (Indonesian, the default language):

```
- Lingkup pekerjaan: <deskripsi singkat pekerjaan>
- Deliverables:
  - <hasil/fitur konkret #1 yang akan diterima klien>
  - <hasil/fitur konkret #2 yang akan diterima klien>
- Estimasi waktu pengerjaan: ~5 hari kerja
- Investasi: 4.000.000 IDR
```

## Common Mistakes

- Sending a client the internal derivation (`AI Estimate`, `buffer multiplier`, etc.) instead of a plain-language summary.
- Writing the quotation as prose instead of scannable bullet points.
- Omitting the Deliverables section, or listing internal tasks/hours instead of outcomes the client will actually receive.
- Defaulting to English (or any other language) instead of Indonesian without the user having explicitly asked for it.
- Confusing this quotation-writing guidance with `docs/QUOTES.md`, which only tracks internal pricing variables and is never client-facing.
