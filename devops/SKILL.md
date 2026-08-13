---
name: devops
description: Use when the user wants to interact with, manage, deploy to, or query a supported DevOps/hosting platform — currently Coolify (self-hosted PaaS for apps, databases, and services). Triggers on platform names (Coolify, and later Vercel, Cloudflare), or requests to deploy, check server/app status, view logs, manage environment variables, databases, or services on those platforms.
version: 1.0.0
license: MIT
---

# DevOps

Router skill for platform-management tasks. Each supported platform is self-contained in its own subdirectory with vendored CLI docs — no shared code between platforms.

## Supported Platforms

| Platform | Status | Directory |
|---|---|---|
| Coolify | Supported | `coolify/SKILL.md` |
| Vercel | Planned, not yet implemented | — |
| Cloudflare | Planned, not yet implemented | — |

## Routing

1. Detect the target platform from the user's request — explicit name, CLI mentioned (`coolify`, `vercel`, `wrangler`), or project config files (e.g. a saved Coolify context, `vercel.json`, `wrangler.toml`).
2. If the platform is ambiguous or more than one could apply, ask the user which platform to use.
3. Load `<platform>/SKILL.md` and follow it exactly for that platform's commands, auth, and safety rules.
4. If the requested platform isn't supported yet (e.g. Vercel, Cloudflare), tell the user and offer to scaffold a new platform directory following the structure below.

## Adding a New Platform

Create `<platform-name>/SKILL.md` with platform-specific triggers, install/auth steps, and a quick command reference. Put heavy reference material (full CLI/API docs) under `<platform-name>/references/`. Keep each platform directory standalone — do not add cross-platform abstractions.
