# Global Installation: Per-Project Memory

Reference for where `MEMORY.md` actually lives when this skill is installed **globally** (available across all projects) rather than locally to a single project. Every other reference in this skill (`language-preference.md`, `handling-authentication.md`, `writing-to-notion.md`) says to "check `MEMORY.md` in this skill's folder" — this file defines where that folder actually is before any of those checks run.

**This entire file only applies to global installs. Skip it for a project-local install** — there, `user-guide-documents/MEMORY.md` (directly inside the skill folder) is already correct and per-project by construction, since the skill folder itself lives inside that one project.

## Determining Global vs. Local

Compare the path of this skill's own folder (where `SKILL.md` lives) to the current project's root directory:

- **Local install** — the skill folder is inside the current project (e.g. `<project>/.claude/skills/user-guide-documents/`, or the skill lives directly in a skills repo you're working in). One skill instance, one project — no ambiguity possible.
- **Global install** — the skill folder is outside any single project, in a shared/global location (e.g. `~/.claude/skills/user-guide-documents/`). The same skill instance is reused across every project on the machine, so a single flat `MEMORY.md` would mix language preferences, credentials, and Notion targets from unrelated projects together.

If unsure which applies, check whether the skill folder's path contains the current project's root directory as an ancestor — if yes, it's local; if the skill folder sits in a home-directory or user-level config location instead, it's global.

## Where MEMORY.md Lives for a Global Install

Do not use `user-guide-documents/MEMORY.md` directly. Instead:

1. Take the current project's root directory name (e.g. the basename of the project you were invoked in for this task).
2. The per-project memory file is at:

   ```
   <global-skill-folder>/memory/<project-directory-name>/MEMORY.md
   ```

   For example, if the skill is installed at `~/.claude/skills/user-guide-documents/` and you're working in a project at `/home/user/projects/acme-app`, the memory file is:

   ```
   ~/.claude/skills/user-guide-documents/memory/acme-app/MEMORY.md
   ```

3. Create the `memory/<project-directory-name>/` folder (and `MEMORY.md` inside it) if it doesn't exist yet — don't wait for one to already be there.
4. Every instruction elsewhere in this skill that says "check/save to `user-guide-documents/MEMORY.md`" means this per-project path instead, whenever the install is global.

## Quick Reference

| Situation | Action |
|---|---|
| Skill folder is inside the current project | Local install — use `user-guide-documents/MEMORY.md` directly, no changes needed |
| Skill folder is in a global/home-directory location, outside any one project | Global install — use `<global-skill-folder>/memory/<project-directory-name>/MEMORY.md` |
| Global install, per-project memory folder doesn't exist yet | Create `memory/<project-directory-name>/` and `MEMORY.md` inside it |
| Switching between projects in the same session | Re-derive the project directory name each time — never reuse the previous project's memory path |
