(---
description: "Workspace Copilot instructions for the agent-skills repository."
---)

# Copilot Instructions

- **Skill versioning**: When you make any change to a skill's content (for example edits to `SKILL.md`, bundled assets, or instruction text), always increment the skill `version` value. This includes patch-level updates for minor fixes. Incrementing the version ensures tools and agents pick up the updated skill.

- **Where to update**: Edit the `version` field at the top of the skill's `SKILL.md` or in the skill manifest you maintain for this repository.

- **Example**: `version: 1.0.0` -> `version: 1.0.1` for any content change.

- **Validation**: After updating, verify the skill loads and that the new version is visible to consuming agents.

