---
name: devops
description: Use when the user wants to interact with, manage, deploy to, or query a supported DevOps/hosting platform — currently Coolify (self-hosted PaaS for apps, databases, and services). Triggers on platform names (Coolify, and later Vercel, Cloudflare), or requests to deploy, check server/app status, view logs, manage environment variables, databases, or services on those platforms.
version: 1.2.0
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

## Write Confirmation Policy (applies to every platform)

This rule binds every platform directory — do not weaken it in a platform's own `SKILL.md`.

- **Read operations** — list, get, view, status, logs, or any call that only retrieves information: run directly, no confirmation needed.
- **Write operations** — anything that creates, updates, deletes, starts, stops, restarts, deploys, moves, syncs, cancels, or otherwise changes state: **ALWAYS prompt the user for confirmation before running it.** Never execute a write operation on an implicit "go ahead."
- Each confirmation prompt must state, in plain language:
  1. The exact command/operation about to run.
  2. What it does.
  3. Its likely impact — what changes, what's affected (downtime, data loss, other users/services notified), and whether it's reversible.
- Confirm each write operation individually. Do not bundle several writes under one confirmation unless the user has explicitly pre-approved that exact batch.
- If unsure whether a command is a read or a write, treat it as a write and confirm.

## Installation Cleanup Policy (applies to every platform)

Whenever this skill installs or updates a platform's CLI (or any dependency needed to run it), remove any leftover installation artifacts once the install succeeds — downloaded installer scripts, archives/tarballs, extracted directories, checksum files, and other staging files left in the working directory, `/tmp`, or a scratch directory.

- Clean up immediately after confirming the install worked (e.g. a version check succeeds), not before.
- Only remove the staging artifacts, never the installed binary, its config file, or its data directories.
- If cleanup itself would delete something ambiguous, ask before removing it rather than guessing.

## Adding a New Platform

Create `<platform-name>/SKILL.md` with platform-specific triggers, install/auth steps, and a quick command reference. Put heavy reference material (full CLI/API docs) under `<platform-name>/references/`. Keep each platform directory standalone — do not add cross-platform abstractions.
