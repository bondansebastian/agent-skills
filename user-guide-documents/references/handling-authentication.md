# Handling Authentication During Screenshot Capture

Reference for what to do when capturing a real screenshot (per the Structure section of `SKILL.md`) requires signing in first and you hit a login page instead of the target screen.

## Core Rule: Ask, Don't Guess or Skip Silently

Never invent credentials, skip the screenshot without saying why, or try random/default credentials. Stop at the login page and ask the user directly for the login credentials needed to reach the screen you're documenting.

## Step by Step

1. **Check `MEMORY.md`** in this skill's folder (`user-guide-documents/MEMORY.md`) for a saved credential entry matching this app/environment.
2. **If a matching entry exists**, use it to sign in and continue capturing the screenshot.
3. **If no matching entry exists**, stop and ask the user for the login credentials for that app/environment.
4. **After the user provides credentials**, ask explicitly whether they want them remembered for future use:

   > "Want me to remember these credentials in MEMORY.md for future [app/environment name] screenshots?"

5. **If yes**, append an entry to `user-guide-documents/MEMORY.md` (create the file if it doesn't exist) recording the app/environment and the credentials.
6. **If no**, use the credentials for this session only — do not write them anywhere.

## MEMORY.md Entry Format

Keep entries short and matchable by app/environment name:

```markdown
- **<App or environment name>** — username: `<username>` — password: `<password>` — <optional notes, e.g. URL or MFA info>
```

## Quick Reference

| Situation | Action |
|---|---|
| Login page blocks screenshot capture, `MEMORY.md` has a matching entry | Use the saved credentials to sign in, no need to ask |
| Login page blocks screenshot capture, no matching entry | Ask the user for credentials — never guess, fabricate, or skip silently |
| User provides credentials | Ask if they want them saved to `MEMORY.md` for next time |
| User says yes to saving | Append the credentials to `user-guide-documents/MEMORY.md` |
| User says no to saving | Use for this session only, don't write to `MEMORY.md` |
