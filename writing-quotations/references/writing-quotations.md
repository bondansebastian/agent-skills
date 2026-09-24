# Writing Client Quotations

A **quotation** is the client-facing pricing communication itself — the text a client actually reads (the Pricing section of an estimate document, a Zoho Books estimate, or a standalone quote message). This is distinct from this skill's internal pricing-variable context (`.agents/contexts/writing-quotations/MEMORY.md`: `buffer multiplier`, `man-day hours`, `base man-day rate`, `currency`), which is never sent to a client.

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
- **Always include a Deliverables section (Section 2).** State the concrete things the client will receive — features shipped, documents handed over, environments configured — as outcomes, not as the internal task/hour breakdown from the estimate document's Breakdown section. This is what tells the client exactly what they're paying for, separate from how long it takes or what it costs.
- **Index every section and sub-section, following this skill's fixed 4-section structure.** Number them hierarchically (`1`, `1.1`, `1.1.1`) at the start of each heading/bullet:
  - `1` **Lingkup Pekerjaan** — plain-language scope description.
  - `2` **Deliverables** — grouped by feature area, one group per `2.x` heading. Each `2.x` heading carries an effort figure and a back-reference to the estimate Breakdown item(s) it summarizes (e.g. `— (estimasi dari 3.1, 3.2)`); one `2.x` group can summarize several estimate items at once, so this is a back-reference, not a 1:1 index reuse. Individual deliverables under a group are `2.x.1`, `2.x.2`, ....
  - `3` **Catatan** — two fixed subsections, each rendered only when it has content: `3.1 Keputusan Teknis` (technical approach per `2.x` deliverable group) and `3.2 Perlu Konfirmasi` (open questions, indexed `3.2.1`, `3.2.2`, ...). There is no standalone Asumsi section — assumptions live inside `3.1`, attached to the deliverable group they support. If there are no open questions, omit `3.2` altogether; if both are empty, omit Section 3.
  - `4` **Estimasi Waktu Pengerjaan & Investasi** — `4.1` a single combined table of total time + total price; `4.2`+ "Opsi Tambahan" (optional add-ons, each with its own description, before/after comparison table, and incremental time/price); final `4.x` "Catatan Estimasi" (exclusions and caveats).
  
  Indices are unique and stable — never renumber or reuse them. **A section with only one sub-item has no sub-index:** that item is the section's description. When more bullets are needed later, restructure the section (existing text becomes `x.1`, new item `x.2`).
- **Don't render empty sections.** Any section or sub-section without meaningful content (an empty `3.2 Perlu Konfirmasi`, one holding only "Tidak ada"/"-", a `4.x` Opsi Tambahan or Catatan Estimasi with nothing to say) is left out entirely — no heading, no index, no placeholder. Remaining indices are never renumbered, and a fixed subsection that is the only one left (e.g. `3.1` alone) keeps its own index and heading. See "Omit Empty Sections" in `SKILL.md`.
- **Show outputs, not derivation.** The full `AI Estimate → Quoted time → Price` derivation from the Pricing Method belongs in the estimate document's audit trail — it is not what goes into the client-facing quotation.

## Example

Internal audit trail (stays in the estimate document, not sent to client):

```
AI Estimate: 3 hours
Buffer multiplier: 6
Quoted time: 6 × 3 hours = 18 hours
Man-day hours: 6
Base man-day rate: 800 USD
Price: (18 / 6) × 800 USD = 2,400 USD
```

Client-facing quotation, written from the same numbers (Indonesian, the default language):

```
Klien: <nama klien>
Proyek: <nama proyek>
Versi: 2026.09.21.14.35  (selalu ada; diperbarui setiap quotation diubah)

1. Lingkup Pekerjaan
   <deskripsi singkat pekerjaan>  (satu item saja → menjadi deskripsi section, tanpa 1.1)

2. Deliverables
   Setelah proyek ini selesai, sistem akan memiliki:
   2.1 Login & manajemen pengguna (~2 hari kerja) — (estimasi dari 3.1 pada dokumen estimasi)
       2.1.1 Halaman login dengan email & kata sandi
       2.1.2 Reset kata sandi via email

3. Catatan
   3.1 Keputusan Teknis
       3.1.1 (terkait 2.1) Autentikasi dibangun di atas middleware auth yang sudah ada, tanpa
             mengubah alurnya, untuk menjaga kompatibilitas dengan sistem berjalan.
   3.2 Perlu Konfirmasi
       3.2.1 Apakah reset kata sandi perlu didukung untuk akun yang login via SSO?

4. Estimasi Waktu Pengerjaan & Investasi
   4.1 Estimasi waktu: ~3 hari kerja | Investasi: 2.400.000 IDR
```

`2.1` here summarizes estimate Breakdown item `3.1` — a back-reference, not the same index reused. Note there is no standalone "Asumsi" section; the assumption about the existing auth middleware sits inside `3.1 Keputusan Teknis` instead, tied to the `2.1` deliverable group it supports.

## Common Mistakes

- Sending a client the internal derivation (`AI Estimate`, `buffer multiplier`, etc.) instead of a plain-language summary.
- Writing the quotation as prose instead of scannable bullet points.
- Leaving sections unindexed, or using indices that don't follow the fixed 4-section structure.
- Reintroducing a standalone "Asumsi" section instead of folding assumptions into `3.1 Keputusan Teknis`, attached to the deliverable group they support.
- Numbering Deliverables at index `3` instead of `2`, or reusing an estimate Breakdown item's index directly on a `2.x` group instead of writing it as a back-reference (a `2.x` group can summarize several Breakdown items at once).
- Merging `3.1 Keputusan Teknis` and `3.2 Perlu Konfirmasi` into one subsection.
- Rendering an empty section or sub-section (e.g. a `3.2 Perlu Konfirmasi` with no questions, or with just "Tidak ada") instead of omitting it, or renumbering the remaining sections after omitting one.
- Omitting the `Versi` datetime stamp from the meta, or not refreshing it when the quotation is updated.
- Omitting the Deliverables section, or listing internal tasks/hours instead of outcomes the client will actually receive.
- Defaulting to English (or any other language) instead of Indonesian without the user having explicitly asked for it.
- Confusing this quotation-writing guidance with the internal pricing-variable context in `.agents/contexts/writing-quotations/MEMORY.md`, which only tracks internal pricing variables and is never client-facing.
