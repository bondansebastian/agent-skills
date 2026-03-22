# Agent Skills

![Skills](https://img.shields.io/badge/Skills-Collection-0ea5e9?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-22c55e?style=for-the-badge)
![Format](https://img.shields.io/badge/Format-SKILL.md-f59e0b?style=for-the-badge)

> An opinionated, curated collection of reusable agent skills that encode domain expertise, workflows, and high-quality execution patterns.

## What This Repository Is

This repository stores modular skill packages that help agents perform specialized tasks with better consistency, clarity, and outcomes.

Each skill lives in its own folder and contains a `SKILL.md` file with:
- Purpose and scope
- Trigger conditions (when to use it)
- Step-by-step workflow and best practices
- Templates, examples, and pitfalls

## Skill Catalog

| Icon | Skill | Description | Path |
|---|---|---|---|
| 📚 | Confluence Knowledge Base | Build and maintain a product-focused Confluence knowledge base that is accessible to design, engineering, sales, and support. | [confluence-knowledge-base/SKILL.md](confluence-knowledge-base/SKILL.md) |
| 🔌 | Install Atlassian Rovo MCP | Guide users through Atlassian Rovo MCP installation with setup discovery first, then project-local or multi-project instructions tailored to OS/runtime (Windows, WSL, macOS, Linux). | [install-atlassian-rovo-mcp/SKILL.md](install-atlassian-rovo-mcp/SKILL.md) |

## Repository Layout

```text
agent-skills/
├── README.md
├── confluence-knowledge-base/
│   └── SKILL.md
└── install-atlassian-rovo-mcp/
    └── SKILL.md
```

## Why Agent Skills

- Better quality: repeat proven workflows instead of starting from scratch each time.
- Better speed: reduce back-and-forth by giving agents concrete execution guidance.
- Better consistency: standardize outputs across repeated task types.
- Better collaboration: capture team knowledge in a reusable format.

## Add a New Skill

1. Create a new folder using kebab-case, for example: `customer-interview-analysis`.
2. Add a `SKILL.md` file with clear frontmatter and actionable instructions.
3. Include practical examples and edge-case guidance.
4. Update the Skill Catalog table in this README.

Minimal frontmatter example:

```yaml
---
name: your-skill-name
description: Clear, specific description of what this skill does and when it should be used.
version: 1.0.0
license: MIT
---
```

## Design Principles For Skills

- Be explicit about when the skill must be used.
- Prefer plain language over jargon.
- Provide concrete templates that can be applied immediately.
- Include review checklists to keep outputs reliable.

## License

This repository uses the MIT License for skill content unless stated otherwise in individual skill files.
