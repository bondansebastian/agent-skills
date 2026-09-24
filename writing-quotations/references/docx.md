# Generating a Quotation .docx

Read this before building a Word version of a client-facing quotation. The Markdown file under `docs/quotations/` is always the source; the `.docx` is a derived snapshot of it.

## When to Build One

Only build a `.docx` when the user explicitly asks for a Word document/docx **in that turn**.

- Don't produce one preemptively "just in case".
- Don't regenerate or refresh an existing docx on your own initiative after editing the `.md` source.
- A docx is only (re)built in direct response to an explicit user request, every single time, even if one was generated earlier for the same quotation.

## How to Generate It

Generate it from the same Markdown content — don't hand-author a separate copy that can drift from the source. Invoke the **`anthropic-skills:docx`** skill; do not hand-roll docx generation with `pandoc` or any other tooling when that skill is available.

The result must be a genuinely polished document: proper heading styles, real bullet lists, and readable typography — not a bare text dump styled as "Normal" throughout.

## Remove the Reference to the Estimate

The Markdown quotation carries back-references to the source estimate document on each Deliverables group heading, e.g. `(estimasi dari 3.1, 3.2 pada dokumen estimasi)`. Those exist only so the two internal documents stay traceable to each other. **The docx is what the client reads, so remove every reference to the estimate from it:**

- Strip the whole parenthetical back-reference from every `2.x` group heading — `2.1 Login & manajemen pengguna (~2 hari kerja) — (estimasi dari 3.1 pada dokumen estimasi)` becomes `2.1 Login & manajemen pengguna (~2 hari kerja)`.
- Remove any other mention of the estimate document, its Breakdown item indices, or the `AI Estimate` anywhere else in the docx.
- Keep the quotation's own indices (`1`, `2.1`, `2.1.1`, ...) unchanged — only the references *to the estimate* go.
- Do this in the docx only. Never remove the back-references from the `.md` source; it must stay traceable to the estimate.

## Never Overwrite an Existing Docx

Each time a docx is generated (first time or any later regeneration), write it as a brand-new file rather than replacing a previously generated one — so earlier snapshots stay on disk and recoverable. Name it after the Markdown source with the quotation's current `Versi` timestamp (see Quotation Meta & Version in `SKILL.md`) appended, using the same dot-separated format:

```
docs/quotations/YYYY-MM-DD-<client>-<project-slug>.<Versi>.docx
```

e.g. `2026-09-21-acme-portal-redesign.2026.09.21.14.35.docx`. Re-read the quotation's current `Versi` stamp from the `.md` file immediately before naming the docx, so the timestamp in the filename always matches the content it was built from. Carry the same `Versi` value into the docx's own meta block.
