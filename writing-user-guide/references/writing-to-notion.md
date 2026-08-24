# Writing to Notion

Reference for publishing or updating a user guide in Notion instead of (or in addition to) a local file.

## Always Use notion-cli

Every Notion operation this skill performs — reading an existing page, creating a new one, updating content, listing pages to find a target — goes through the `notion-cli` tool (the `ntn` command), never a Notion MCP server or any other Notion integration. Mixing integrations against the same Notion workspace risks inconsistent page IDs, formatting quirks, or a narrower auth scope on one path than the other producing a broken or partial write. Even if a Notion MCP server is connected in the session, don't reach for it here — use `ntn`.

Before writing anything to Notion:

- Check whether `notion-cli` is actually available (the `ntn` command runs).
- If `ntn` itself or its authentication isn't set up, don't silently fall back to another integration or skip the write — offer to install it with `curl -fsSL https://ntn.dev | bash`, then set up auth per its own instructions (it uses `NOTION_API_TOKEN` if set, otherwise `ntn login`).
- If no `notion-cli` skill is detected at all, offer to install it with `npx skills add https://github.com/makenotion/skills.git --skill notion-cli`.
- Only proceed without it if the user declines the install — in that case, stop and ask the user how they'd like the guide published instead, rather than substituting a different Notion integration on your own.

## Core Rule: Never Assume the Target Page

Before creating or updating any Notion page for a user guide:

1. **Check `MEMORY.md`** at `<project-root>/.agents/contexts/writing-user-guide/MEMORY.md` (see Memory Location in `SKILL.md`) for a matching entry — one that names the guide, feature, or product area you're about to write about.
2. **If a matching entry exists**, use the page/URL it records as the write target. Confirm with the user only if the request is ambiguous about which guide this is.
3. **If no matching entry exists**, do not guess a page, workspace, or parent based on naming similarity, recent activity, or search results. Stop and ask the user explicitly which Notion page (or parent page, for a new page) to write to.

## After the User Answers

Once the user tells you which Notion page to use, ask whether they'd like it remembered for next time:

> "Want me to remember this Notion page in MEMORY.md for future [guide/feature name] updates?"

- If yes, append an entry to `MEMORY.md` at that path (create the file if it doesn't exist) recording what the page is for and its page/URL.
- If no, proceed with the write without saving anything.

## Default Page Structure

Once the target project's Notion location is known (via the Core Rule above), organize the guide content using this default structure:

1. **Project page** — the page representing the project itself.
2. **"User Manual" page** — a page directly under the project page (create it if it doesn't already exist).
3. **Module pages** — for each module being documented, create a sub-page under "User Manual".

Apply this default only if `MEMORY.md` doesn't record a different structure for this project — a `MEMORY.md` structure entry always overrides the default.

## When the User Requests a Different Structure

If the user asks for a structure that differs from the default (e.g., flat pages, a different hierarchy, module docs as sections instead of sub-pages), follow their requested structure for this write. Then ask:

> "Want me to remember this structure in MEMORY.md so future guides for [project name] use it automatically instead of the default?"

- If yes, append a structure entry to `MEMORY.md` at that path.
- If no, use the requested structure for this write only — don't save anything.

## MEMORY.md Entry Format

Keep entries short and matchable by guide/feature name. Use two entry kinds:

**Target page** (which Notion page/parent to write to):
```markdown
- **<Guide or feature name>** — <Notion page title> — <page URL or ID>
```

**Structure override** (a non-default page hierarchy for a project):
```markdown
- **<Project name> structure** — <description of the hierarchy, e.g. "flat: one page per module directly under the project page, no 'User Manual' page">
```

## Quick Reference

| Situation | Action |
|---|---|
| Any Notion read or write | Use `notion-cli` (`ntn`) — never a Notion MCP server or other integration |
| `notion-cli` (`ntn`) not available or not authenticated | Offer to install/set it up per its own instructions; don't fall back to another integration |
| No `notion-cli` skill detected | Offer to install with `npx skills add https://github.com/makenotion/skills.git --skill notion-cli` |
| User declines the `notion-cli` install | Stop and ask the user how they'd like the guide published instead |
| `MEMORY.md` has a matching target-page entry | Use it as the target; no need to ask |
| `MEMORY.md` doesn't exist yet | Treat as no entries — ask before writing |
| No matching entry for this guide | Ask the user explicitly which page to use — never assume |
| User names a page for a new/unmatched guide | After writing, ask if they want it saved to `MEMORY.md` |
| User declines to save | Write to the page as instructed, skip `MEMORY.md` |
| No structure override in `MEMORY.md` | Use the default structure: project page → "User Manual" page → one sub-page per module |
| `MEMORY.md` has a structure override for this project | Use the recorded structure instead of the default — it always wins |
| User requests a structure different from the default | Follow their request for this write, then offer to save it to `MEMORY.md` |
