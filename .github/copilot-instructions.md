(---
description: "Workspace Copilot instructions for the agent-skills repository."
---)

# Copilot Instructions

- **Skill versioning**: When you make any change to a skill's content (for example edits to `SKILL.md`, bundled assets, or instruction text), always increment the skill `version` value. This includes patch-level updates for minor fixes. Incrementing the version ensures tools and agents pick up the updated skill.

- **Where to update**: Edit the `version` field at the top of the skill's `SKILL.md` or in the skill manifest you maintain for this repository.

- **Example**: `version: 1.0.0` -> `version: 1.0.1` for any content change.

- **Validation**: After updating, verify the skill loads and that the new version is visible to consuming agents.

- **README sync**: When you add, remove, or modify any skill (including changes to its `SKILL.md`, description, or `version`), update `README.md`'s Skill Catalog table and any path or description references so the repository README reflects the change. Keep the table rows consistent (icon, skill name, short description, and path). This ensures users and agents can discover skills and see the correct version and location.

