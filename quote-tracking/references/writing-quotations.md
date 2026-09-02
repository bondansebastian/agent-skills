# Writing Client Quotations

A **quotation** is the client-facing pricing communication itself — the text a client actually reads (the Pricing section of an estimate document, a Zoho Books estimate, or a standalone quote message). This is distinct from `docs/QUOTES.md`, which is an internal ledger of pricing variables (`buffer multiplier`, `man-day hours`, `base man-day rate`, `currency`) and is never sent to a client.

## Style Rules

- **Lead with bullet points.** Present the key facts — scope, timeline, price — as a scannable bullet list, not prose paragraphs.
- **Use business language, not technical or internal jargon.** A client shouldn't need to understand how the number was produced to understand what they're paying for. Rephrase internal terms:
  - `AI Estimate` — don't expose this term to the client at all.
  - `buffer multiplier` — don't expose the multiplier; state only the resulting timeline.
  - `Quoted time` — present as a plain timeline (e.g. "estimated turnaround").
  - `base man-day rate` — "daily rate" or "day rate" if a rate needs to be shown at all.
  - `Price` — "Investment" or "Total" reads better to a client than an internal derivation label.
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

Client-facing quotation, written from the same numbers:

```
- Scope: <one-line description of the work>
- Estimated turnaround: ~5 business days
- Investment: 4,000 USD
```

## Common Mistakes

- Sending a client the internal derivation (`AI Estimate`, `buffer multiplier`, etc.) instead of a plain-language summary.
- Writing the quotation as prose instead of scannable bullet points.
- Confusing this quotation-writing guidance with `docs/QUOTES.md`, which only tracks internal pricing variables and is never client-facing.
