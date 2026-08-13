---
name: devops-coolify
description: Use when the user wants to manage Coolify (self-hosted PaaS) — deploying or restarting apps, checking server/project/resource status, viewing app or database logs, managing environment variables, contexts, tags, destinations, cloud-provider tokens, databases, or one-click services via the `coolify` CLI. Triggers on "coolify", "self-hosted PaaS", or coolify app/server/database/service/deploy/context commands.
version: 1.3.0
license: MIT
---

# Coolify

Natural-language interface to the [Coolify](https://coolify.io) CLI (`coolify`). Docs vendored from `coollabsio/coolify-cli` (v4.x branch, MIT license — see `LICENSE`) so this skill works standalone, without fetching external URLs.

## Setup Check

**Run this first:**

```bash
coolify context version
```

- If the `coolify` binary is missing, install it (pick one):
  ```bash
  # Linux/macOS (recommended)
  curl -fsSL https://raw.githubusercontent.com/coollabsio/coolify-cli/main/scripts/install.sh | bash

  # Homebrew (macOS/Linux)
  brew install coollabsio/coolify-cli/coolify-cli

  # Windows (PowerShell)
  irm https://raw.githubusercontent.com/coollabsio/coolify-cli/main/scripts/install.ps1 | iex

  # Go install
  go install github.com/coollabsio/coolify-cli/coolify@latest
  ```
- After the install succeeds (verify with `coolify context version`), follow the devops skill's **Installation Cleanup Policy** (see top-level `../SKILL.md`): remove any leftover installer artifacts — a saved copy of `install.sh`/`install.ps1`, downloaded release archives, or extracted directories used to install manually. Do not remove the installed binary, `~/.config/coolify/config.json`, or the Go module cache used by `go install`.
- If no context is configured, walk the user through **Authentication** below before running any resource command.

## Authentication

1. Get an API token from the Coolify dashboard at `/security/api-tokens`.
2. Coolify Cloud: `coolify context set-token cloud <token>`
3. Self-hosted: `coolify context add -d <context_name> <url> <token>`
4. Switch active context: `coolify context use <context_name>`

Config file: `~/.config/coolify/config.json` (Linux/macOS) or `%APPDATA%\coolify\config.json` (Windows). Supports multiple saved contexts (instances).

## Operating Rules

- Prefer `--format json` for automation/parsing; default `table` output is for humans.
- Use Coolify **UUIDs** for resources — never internal numeric IDs.
- **Exception:** team commands use numeric team IDs.
- Prefer a saved context (`--context <name>`) over passing `--token` on every call.
- `--show-sensitive` reveals fields marked sensitive (tokens, passwords, IPs, emails); omit by default.

## Quick Reference

| Task | Command |
|---|---|
| List contexts / verify / switch | `coolify context list` / `coolify context verify` / `coolify context use <name>` |
| List servers/projects/resources/apps | `coolify server list` / `project list` / `resource list` / `app list` |
| Get / start / stop / restart an app | `coolify app get <uuid>` / `start` / `stop` / `restart <uuid>` |
| Tail app logs | `coolify app logs <uuid> --show-timestamps` / `--service web --follow` |
| Move app between environments | `coolify app move <uuid> --environment-uuid <uuid>` |
| Manage app env vars | `coolify app env list\|create\|update\|sync <app-uuid> ...` |
| List / trigger / cancel deployments | `coolify deploy list` / `coolify deploy name <app>` / `coolify deploy batch a,b,c --force` / `coolify deploy cancel <uuid>` |
| Databases | `coolify database get\|create\|logs\|move\|backup list <uuid>` |
| One-click services | `coolify service get\|create\|logs\|application\|database <uuid>` |
| Tags / destinations / cloud tokens | `coolify tag list` / `coolify destination list --server <uuid>` / `coolify cloud-token create --provider hetzner ...` |

Common aliases: `app`≈`apps`≈`application`≈`applications`; `service`≈`services`≈`svc`; `database`≈`databases`≈`db`≈`dbs`; `teams`≈`team`.

Global flags on every command: `--context <name>`, `--token <token>`, `--format table|json|pretty`, `--show-sensitive`, `--debug`.

Full quick-start reference: `references/llms.txt`.

## Safety

This platform follows the devops skill's **Write Confirmation Policy** and **Credential Handling Policy** (see top-level `../SKILL.md`): read operations run directly, every write operation requires explicit user confirmation first, stated with the exact command, what it does, and its impact — and tokens/secrets are never requested from the user or read from `~/.config/coolify/config.json`; point the user to **Authentication** above and the CLI commands there instead. Never run a command with `--show-sensitive`.

**Read (no confirmation):** `context list/verify/version`, `server/project/resource/app/service/database list`, `app get`, `app logs`, `app deployments list/logs`, `app env list`, `deploy list`, `database get/logs/backup list`, `service get/logs/application list/database list`, `tag list`, `destination list`, `cloud-token validate`.

**Write (always confirm first):** `app start/stop/restart/move/tag add/update/clone/create *`, `app env create/update/sync`, `deploy name/batch/cancel`, `database create/move/backup create`, `service create/application restart/database restart`, `cloud-token create`, `server hetzner create`, `context add/set-token/use`, and any other `create`, `update`, `delete`, `move`, `sync`, `restart`, `stop`, `cancel`, or `deploy` subcommand.

For every write, the confirmation must call out impact specific to the action, e.g.:
- `app stop`/`restart` — causes downtime for that app until it's back up.
- `deploy ... --force`/`deploy batch` — triggers a real deployment, may replace the running version.
- `deploy cancel` — aborts an in-progress deployment.
- `app env sync` — updates existing variables and creates missing ones; does **not** delete variables absent from the file (state this so the user knows it's non-destructive by default), and confirm the target app/environment before running.
- `database`/`service` `move`/`create`/`restart` — affects live data or availability of that resource.
- `cloud-token create`/`server hetzner create` — provisions or authorizes real infrastructure, potentially incurring cost.

Additional rules:
- Fetch current state (`get`/`list`) before mutating — don't assume a resource's status, environment, or UUID.
- If a command's read/write status is unclear from the Quick Reference or `references/llms-full.txt`, treat it as a write and confirm.

## Deep Dive

**Load `references/llms-full.txt`** (exhaustive command/flag catalog, one entry per subcommand) when:
- The Quick Reference above doesn't cover the exact subcommand or flag needed.
- Creating apps/databases/services from scratch (build packs, deploy keys, one-click service types, cloud-provider server creation — many required flags).
- Working with backups, storage/volumes, GitHub App integration, or team management.

**Load `references/cli-readme.md`** for install-script details, shell completion setup, or upstream project links not covered above.

Do NOT load either reference for simple list/get/start/stop/restart calls — the Quick Reference is sufficient.
