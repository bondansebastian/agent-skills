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

| Skill | Description | Path | Install |
|---|---|---|---|
| 📚 Confluence Knowledge Base | Build and maintain a product-focused Confluence knowledge base that is accessible to design, engineering, sales, and support. | [confluence-knowledge-base/SKILL.md](confluence-knowledge-base/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill confluence-knowledge-base` |
| 🔌 Install Atlassian Rovo MCP | Guide users through Atlassian Rovo MCP installation with setup discovery first, then project-local or multi-project instructions tailored to OS/runtime (Windows, WSL, macOS, Linux). | [install-atlassian-rovo-mcp/SKILL.md](install-atlassian-rovo-mcp/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill install-atlassian-rovo-mcp` |
| 🧭 Jira | Natural-language Jira assistant (v1.0.2) for viewing, creating, and updating issues, supporting CLI and MCP backends. (Forked from https://github.com/davila7/claude-code-templates/cli-tool/components/skills/ai-research/jira) | [jira/SKILL.md](jira/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill jira` |
| 🐘 Laravel 7 Guidelines | Coding guidelines and best practices for Laravel 7.x projects covering Eloquent, routing, validation, security, testing, and frontend. | [laravel7-guidelines/SKILL.md](laravel7-guidelines/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill laravel7-guidelines` |
| 🐘 Laravel 8.x – Coding Guidelines & Best Practices | Coding guidelines and best practices for Laravel 8.x projects covering Eloquent, routing, validation, security, testing, and queues. | [laravel8-guidelines/SKILL.md](laravel8-guidelines/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill laravel8-guidelines` |
| 🎨 UI/UX Best Practices | Ensure every clickable element gives visual feedback on hover; prefer smoothly animated micro-interactions, accessible motion preferences, and practical examples. | [ui-ux-best-practices/SKILL.md](ui-ux-best-practices/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill ui-ux-best-practices` |
| ⚛️ React Best Practices | Opinionated React component architecture: SRP-driven splits, colocation, state isolation, explicit props, re-exported types, naming conventions, and practical file-size targets. | [react-best-practices/SKILL.md](react-best-practices/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill react-best-practices` |
| 🧠 Agent Instructor | Refine or create AI/LLM agent instruction files (AGENTS.md, CLAUDE.md, copilot-instructions.md, .github/instructions) with zero information loss, machine-parsable structure, and token efficiency. | [agent-instructor/SKILL.md](agent-instructor/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill agent-instructor` |
| 📄 Estimate Project | Create, name, and rename client estimate documents under docs/estimates/, dated by their Date of assessment metadata field, with a required AI Estimate row and a structured Scope/Assumptions/Breakdown format. Always asks the client name fresh per estimate rather than remembering it. Triggers whenever the user asks to estimate, scope, or size up a project or task. | [estimate-project/SKILL.md](estimate-project/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill estimate-project` |
| 💵 Writing Quotations | Turn an AI Estimate into a client-facing price using a fully-variablized pricing formula (buffer multiplier, man-day hours, base man-day rate, currency) remembered per project in .agents/contexts/writing-quotations/MEMORY.md, write plain-business-language client quotations in Indonesian by default (with a clear Deliverables section) saved as dated Markdown files under docs/quotations/ (always asking the client name and project name fresh, never remembered, with content-based fallbacks), only producing a polished .docx on explicit request, and handle scoped, non-destructive Zoho Books estimates (service-type line items, no unrequested man-hour detail). Triggers whenever the user asks to price, quote, or update a Zoho Books estimate. | [writing-quotations/SKILL.md](writing-quotations/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill writing-quotations` |
| 📖 Writing User Guide | Write end-user guides, manuals, and help center articles in plain non-technical business language for the app's actual end-user, as numbered step-by-step instructions with a screenshot per step where possible (preferring the playwright-cli tool for browser interaction and screenshot capture, offering to install playwright-cli or its skill if not detected), never referencing ticket numbers, JIRA IDs, feature flags, or other internal identifiers; always checks a project-local MEMORY.md at `.agents/contexts/writing-user-guide/` (a fixed per-project path, regardless of whether the skill itself is installed locally or globally) at the start for a remembered guide language before drafting (asking and saving it if not yet known); when publishing to Notion, always uses the notion-cli (`ntn`) tool — never a Notion MCP server or other integration — offering to install it if not detected; checks MEMORY.md for a known target page and always asks the user explicitly before writing if none is found, then organizes content using the default structure (project page → "User Manual" page → one sub-page per module) unless MEMORY.md or the user specifies otherwise; if a login page blocks screenshot capture, checks a separate, git-ignored credentials folder at `.agents/credentials/writing-user-guide/` for saved credentials and otherwise asks the user, offering to remember them there for next time (kept apart from the regular MEMORY.md context so secrets never risk being committed). | [writing-user-guide/SKILL.md](writing-user-guide/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill writing-user-guide` |
| ⚙️ DevOps | Manage supported DevOps/hosting platforms by natural language — Coolify (self-hosted PaaS: apps, databases, services, deployments, logs, env vars) and OCI (Oracle Cloud Infrastructure: `oci` CLI plus an opinionated bastion-tunnel workflow for SSH/SCP to private compute instances with no public IP) — via vendored, standalone copies of each platform's CLI docs; structured with one self-contained subdirectory per platform so Vercel and Cloudflare can be added later without touching existing platforms. | [devops/SKILL.md](devops/SKILL.md) | `npx skills add https://github.com/bondansebastian/agent-skills --skill devops` |

## Repository Layout

```text
agent-skills/
├── README.md
├── confluence-knowledge-base/
│   └── SKILL.md
├── jira/
│   ├── SKILL.md
│   └── references/
│       ├── commands.md
│       └── mcp.md
├── laravel7-guidelines/
│   ├── SKILL.md
│   └── references/
│       ├── database.md
│       ├── eloquent.md
│       ├── frontend.md
│       ├── routing-controllers.md
│       ├── security.md
│       ├── testing.md
│       └── validation.md
├── laravel8-guidelines/
│   ├── SKILL.md
│   └── references/
│       ├── eloquent.md
│       ├── queues-jobs.md
│       ├── security.md
│       └── testing.md
├── react-best-practices/
│   ├── SKILL.md
│   ├── rules/
│   └── upstream/
│       └── rules/
├── ui-ux-best-practices/
│   └── SKILL.md
├── install-atlassian-rovo-mcp/
│   └── SKILL.md
├── agent-instructor/
│   └── SKILL.md
├── estimate-project/
│   └── SKILL.md
├── writing-quotations/
│   ├── SKILL.md
│   └── references/
│       ├── writing-quotations.md
│       └── zoho-books.md
├── writing-user-guide/
│   ├── SKILL.md
│   └── references/
│       ├── language-preference.md
│       ├── handling-authentication.md
│       └── writing-to-notion.md
└── devops/
    ├── SKILL.md
    ├── coolify/
    │   ├── SKILL.md
    │   ├── LICENSE
    │   └── references/
    │       ├── llms.txt
    │       ├── llms-full.txt
    │       └── cli-readme.md
    └── oci/
        ├── SKILL.md
        ├── LICENSE
        ├── scripts/
        │   ├── download-oci
        │   ├── ssh-oci
        │   ├── upload-oci
        │   └── rotate-oci-config.py
        └── references/
            ├── cli-install.md
            ├── cli-config.md
            └── bastion-workflow.md
```

## Why Agent Skills

- Better quality: repeat proven workflows instead of starting from scratch each time.
- Better speed: reduce back-and-forth by giving agents concrete execution guidance.
- Better consistency: standardize outputs across repeated task types.
- Better collaboration: capture team knowledge in a reusable format.

## License

This repository uses the MIT License for skill content unless stated otherwise in individual skill files.
