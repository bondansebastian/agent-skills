---
name: estimate-documents
description: "Use when creating, naming, renaming, or filling in the metadata table of estimate documents under docs/estimates/ — covers date-prefixed filenames keyed to the Date of assessment field and the required AI Estimate metadata row."
version: 1.0.0
---

# Estimate Documents Skill

## When to Use This Skill

Load this skill when you are:

- Creating a new client estimate document
- Renaming an estimate document after its `Date of assessment` changes
- Writing or reviewing an estimate document's metadata table
- Adding an entry to `docs/QUOTES.md`

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

## Metadata: AI Estimate

Every estimate document's metadata table must report an **AI Estimate** in place of the `Estimate` row (do not include a separate `Human Estimate` row):

- **AI Estimate** — wall-clock time for an AI coding agent (e.g. Claude Code) to complete the same scope in an active session, e.g. `45 minutes`, `3 hours`. This is elapsed session time, not effort-days — agents don't work in man-day units.

---

## Quick Reference

| Situation | Action |
|---|---|
| Creating a new estimate | Write to `docs/estimates/YYYY-MM-DD-<client>-<slug>.md` using today's `Date of assessment` |
| `Date of assessment` changes | `git mv` the file (and its linked folder, if any) to the new date |
| Filling in the metadata table | Include one `AI Estimate` row; omit `Estimate` and `Human Estimate` |
| Appending to the quotes ledger | Edit `docs/QUOTES.md` in place — never rename it |

## Common Mistakes

- Dating the filename by creation or approval date instead of `Date of assessment`.
- Leaving a stale date in the filename after the assessment is revised.
- Including both an `Estimate` row and an `AI Estimate` row, or adding a `Human Estimate` row.
- Renaming `QUOTES.md` to a dated form.
