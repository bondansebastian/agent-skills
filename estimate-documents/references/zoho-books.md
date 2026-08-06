# Zoho Books Estimates

## Updating Existing Estimates

When updating an existing estimate in Zoho Books (e.g. via `update_estimate`), **never change any content beyond the specific section(s) the user asked to update.**

- First fetch the current estimate (`get_estimate`) and diff the user's request against it to identify exactly which fields/line items/sections are in scope.
- Only include the fields the user asked to change in the update payload. Do not "clean up," reformat, reprice, re-word, or otherwise touch line items, terms, notes, or metadata the user didn't mention — even if they look inconsistent with the requested change.
- If the requested change has knock-on effects elsewhere in the document (e.g. a line-item price change that should shift the total), surface that to the user and get confirmation before touching the additional section — don't silently cascade the edit.
- If it's unclear which section a request refers to, ask rather than guessing and editing broadly.

## Line Item Conventions

These apply whenever a line item is created or added, whether via `create_estimate` or `update_estimate`:

- **Always use the `service` item type for line items** — never `goods`/inventory item types, regardless of what the underlying work involved.
- **Don't expose detailed man-hour breakdowns** (hours × hourly rate, per-task hour counts, etc.) in line item names, descriptions, or notes, unless the user explicitly asks for that level of detail. Default to describing the deliverable or scope of the line item, not how the time was spent — this mirrors `references/writing-quotations.md`: the client sees outputs, not internal derivation.
- If the user explicitly requests man-hour detail, include it — this rule only governs the unrequested default.

## Quick Reference

| Situation | Action |
|---|---|
| Updating a Zoho Books estimate | `get_estimate` first, then `update_estimate` with only the fields the user asked to change — leave everything else untouched |
| Creating or adding a line item | Use `service` item type; describe the deliverable, not man-hours, unless the user explicitly asks for hour-level detail |

## Common Mistakes

- Overwriting or reformatting unrelated sections of a Zoho Books estimate when the user only asked to change one part of it.
- Using a `goods`/inventory item type for a line item instead of `service`.
- Exposing man-hour breakdowns in a line item by default when the user never asked for that level of detail.
