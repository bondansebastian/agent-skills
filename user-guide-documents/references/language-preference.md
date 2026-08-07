# Language Preference

Reference for what language to write a guide in, checked at the **start** of every guide-writing task — before drafting any content.

## Core Rule: Check Memory First, Ask Only If Needed

1. **If the user's request already states a language** (e.g. "write this guide in Spanish"), use it — no need to ask or check `MEMORY.md`. Still offer to save it as the default per step 5 below if no default is currently saved.
2. **Otherwise, check `MEMORY.md`** in this skill's folder (`user-guide-documents/MEMORY.md`) for a remembered language preference.
3. **If a remembered preference exists**, write the guide in that language — don't ask again.
4. **If no preference is saved yet**, stop and ask the user what language the guide should be written in before drafting any content.
5. **After the user answers**, save it to `user-guide-documents/MEMORY.md` as the default for future guides — no separate confirmation needed, since this isn't sensitive information (unlike credentials).

## MEMORY.md Entry Format

```markdown
- **Language** — <language, e.g. "English">
```

## Quick Reference

| Situation | Action |
|---|---|
| User's request already names a language | Use it; save as default if none is saved yet |
| `MEMORY.md` has a saved language preference | Use it, don't ask |
| `MEMORY.md` has no language preference yet | Ask the user before drafting, then save the answer |
| User changes their mind mid-project | Update the `MEMORY.md` entry to the new language |
