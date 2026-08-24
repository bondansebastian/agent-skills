# Handling Authentication During Screenshot Capture

Reference for what to do when capturing a real screenshot (per the Structure section of `SKILL.md`) requires signing in first and you hit a login page instead of the target screen.

## Core Rule: Ask, Don't Guess or Skip Silently

Never invent credentials, skip the screenshot without saying why, or try random/default credentials. Stop at the login page and ask the user directly for the login credentials needed to reach the screen you're documenting.

## Credentials Live Separately From Contexts

Saved credentials are kept apart from the rest of this skill's memory, in their own folder:

```
<project-root>/.agents/credentials/writing-user-guide/CREDENTIALS.md
```

This is deliberate — the contexts `MEMORY.md` (language preference, Notion targets) is ordinary project memory that's fine to commit, while credentials are secrets that must never be. Never mix the two: don't write credentials into the contexts `MEMORY.md`, and don't write language/Notion preferences into this credentials file.

Before writing to this folder for the first time in a project, confirm the project's `.gitignore` excludes `.agents/credentials/` (or at least `.agents/credentials/writing-user-guide/`) — add an entry if it's missing. This isn't optional: a login page blocking a screenshot is a routine, expected situation, and the fix must never risk leaking a secret into git history.

## Step by Step

1. **Check `CREDENTIALS.md`** at `<project-root>/.agents/credentials/writing-user-guide/CREDENTIALS.md` for a saved credential entry matching this app/environment. Only do this once authentication actually turns out to be necessary — don't check it proactively at the start of a task.
2. **If a matching entry exists**, use it to sign in and continue capturing the screenshot.
3. **If no matching entry exists**, stop and ask the user for the login credentials for that app/environment.
4. **After the user provides credentials**, ask explicitly whether they want them remembered for future use:

   > "Want me to remember these credentials for future [app/environment name] screenshots?"

5. **If yes**, first confirm `.gitignore` excludes `.agents/credentials/` (add it if missing), then append an entry to `CREDENTIALS.md` (create the folder and file if they don't exist) recording the app/environment and the credentials.
6. **If no**, use the credentials for this session only — do not write them anywhere.

## CREDENTIALS.md Entry Format

Keep entries short and matchable by app/environment name:

```markdown
- **<App or environment name>** — username: `<username>` — password: `<password>` — <optional notes, e.g. URL or MFA info>
```

## Quick Reference

| Situation | Action |
|---|---|
| Login page blocks screenshot capture, `CREDENTIALS.md` has a matching entry | Use the saved credentials to sign in, no need to ask |
| Login page blocks screenshot capture, no matching entry | Ask the user for credentials — never guess, fabricate, or skip silently |
| User provides credentials | Ask if they want them saved for next time |
| User says yes to saving | Confirm `.gitignore` excludes `.agents/credentials/` (add if missing), then append the credentials to `<project-root>/.agents/credentials/writing-user-guide/CREDENTIALS.md` |
| User says no to saving | Use for this session only, don't write to the credentials folder |
| `.agents/credentials/` not yet in the project's `.gitignore` | Add it before writing any credential file — never commit this folder |
