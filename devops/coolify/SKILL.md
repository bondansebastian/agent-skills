---
name: devops-coolify
description: Use when the user wants to manage Coolify (self-hosted PaaS) — deploying or restarting apps, checking server/project/resource status, viewing app or database logs, managing environment variables, contexts, tags, destinations, cloud-provider tokens, databases, or one-click services. Uses the Coolify MCP server when connected (preferred) and the `coolify` CLI as the fallback. Triggers on "coolify", "self-hosted PaaS", or coolify app/server/database/service/deploy/context commands.
version: 1.4.0
license: MIT
---

# Coolify

Natural-language interface to [Coolify](https://coolify.io). **Preferred interface: the Coolify MCP server. Fallback interface: the `coolify` CLI.** CLI docs vendored from `coollabsio/coolify-cli` (v4.x branch, MIT license — see `LICENSE`) so this skill works standalone, without fetching external URLs.

## Interface Selection

Decide the interface before every Coolify task:

1. IF the `coolify` MCP server is connected (its tools are available, named `mcp__coolify__<tool>` in Claude Code; `claude mcp get coolify` shows `✔ Connected`), THEN use the MCP tools (see **MCP Tool Reference**).
2. IF the MCP server is not configured, not connected, or returns an authentication or availability error (HTTP 401 = token rejected, 403 = MCP disabled for the token's team, 404 = MCP disabled on the instance), THEN tell the user which case applies, point to **MCP Setup**, and use the CLI (**CLI Setup Check** onward) for the current task.
3. IF the MCP server has no tool for the requested operation, THEN use the CLI for that operation. Known limits from the Coolify documentation: MCP never returns environment variable values, configuration snapshots, or full deployment logs (log summaries are capped and only best-effort redacted). Otherwise check the connected tool list and the `coolify_help` tool before falling back.
4. When falling back to the CLI, state the reason to the user. DO NOT silently switch interfaces in the middle of a write operation.
5. The **Write Confirmation Policy** and **Credential Handling Policy** (see top-level `../SKILL.md`) apply identically to both interfaces.

## MCP Setup (preferred interface)

Coolify has a built-in MCP endpoint: `https://<coolify-host>/mcp` (Streamable HTTP). Authentication: `Authorization: Bearer <Coolify API token>`. ALWAYS use `https` — DO NOT send the token over plain `http`.

1. In the Coolify dashboard, enable MCP for the instance and keep it enabled for the token's team.
2. Create an API token at `/security/api-tokens` for that team. A token is bound to one team (one token per team). Grant `read` for the read tools; grant `deploy` only when the lifecycle tools (`deploy`, `control`, `rollback_application`, `manage_*`) are wanted. Use a dedicated token for MCP, not the CLI's token.
3. The user stores the token themselves (never in the conversation, never in a committed file): edit `~/.config/coolify-mcp/env` (directory `chmod 700`, file `chmod 600`) so it contains exactly `export COOLIFY_MCP_TOKEN='<token>'`. The single quotes are required because tokens contain `|`; no spaces or newline inside the quotes. Load it from `~/.bashrc` (above any "if not interactive, return" guard) and `~/.profile`: `[ -r "$HOME/.config/coolify-mcp/env" ] && . "$HOME/.config/coolify-mcp/env"`.
4. Register the server once at user scope. The configuration keeps only the variable reference, so no secret lands in `~/.claude.json`:
   ```bash
   claude mcp add-json --scope user coolify '{"type":"http","url":"https://<coolify-host>/mcp","headers":{"Authorization":"Bearer ${COOLIFY_MCP_TOKEN}"}}'
   ```
   The single quotes keep `${COOLIFY_MCP_TOKEN}` literal; Claude Code expands it when it connects.
5. Restart Claude Code from a shell that loaded the variable. A running session does not see a newly added server or variable.
6. Verify: `claude mcp get coolify` must show `✔ Connected`. To test the token directly, the user runs `scripts/check-mcp-token.sh https://<coolify-host>/mcp` (prints only the HTTP status and server name, never the token).

MCP Operating Rules:
- Start with `get_infrastructure_overview` (team, servers, projects) or `coolify_help` when the layout is unknown.
- Use Coolify **UUIDs** for resources — never internal numeric IDs.
- Fetch current state with the `get_*`/`list_*` tools before any write — don't assume a resource's status, environment, or UUID.
- The tool list is not filtered by the token's permissions. A write tool can still be rejected at call time when the token lacks `deploy`; report that to the user instead of retrying through another route.
- Tool names reflect the server version (56 tools on Coolify 0.3.0). IF a tool named here is missing, THEN consult `coolify_help` and the connected tool list.

## MCP Tool Reference

| Task | MCP tool(s) | CLI fallback |
|---|---|---|
| Overview / what is down / search | `get_infrastructure_overview`, `list_unhealthy_resources`, `search_resources`, `list_resources` | `coolify resource list` |
| Servers | `list_servers`, `get_server`, `get_server_resources`, `get_server_domains`, `get_server_metrics` | `coolify server list` |
| Projects / environments | `list_projects`, `get_project`, `get_environment` | `coolify project list` |
| Applications | `list_applications`, `get_application`, `list_application_previews` | `coolify app list` / `app get <uuid>` |
| Databases / backups | `list_databases`, `get_database`, `list_database_backups`, `list_backup_executions` | `coolify database get\|backup list <uuid>` |
| Services | `list_services`, `get_service`, `list_service_applications`, `get_service_application`, `list_service_databases`, `get_service_database`, `list_service_templates` | `coolify service get <uuid>` |
| Deployments | `list_deployments`, `get_deployment` (capped log summary only) | `coolify deploy list`, `coolify app deployments logs` |
| Environment variable names | `list_env_keys`, `list_shared_env_keys` (names only, never values) | `coolify app env list <app-uuid>` (values need the CLI) |
| Storages / tags / scheduled tasks | `list_storages`, `list_resource_tags`, `list_tags`, `list_scheduled_tasks`, `list_scheduled_task_executions` | `coolify tag list` |
| GitHub apps | `list_github_apps`, `list_github_repositories`, `list_github_branches` | `coolify github list\|repos\|branches` |
| Team | `get_current_team`, `list_team_members` | `coolify teams current\|members` |
| Start / stop / restart | `control` | `coolify app start\|stop\|restart <uuid>` |
| Deploy / cancel / rollback | `deploy`, `cancel_deployment`, `rollback_application` | `coolify deploy name\|batch\|cancel` |
| Update / clone / move / delete | `manage_application`, `manage_database`, `manage_service`, `manage_preview`, `manage_scheduled_task`, `manage_storage` | `coolify app update\|move\|clone`, `coolify database *`, `coolify service *` |
| Server proxy / Docker cleanup / registries | `manage_proxy`, `docker_cleanup`, `manage_registry` | — (dashboard) |
| Container log tail | — (not available over MCP) | `coolify app logs <uuid> --follow` |
| Environment variable values / create / update / sync | values never returned; check `coolify_help` for write support | `coolify app env create\|update\|sync <app-uuid>` |

## CLI Setup Check (fallback)

**Run this first when the CLI is needed:**

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
- If no context is configured, walk the user through **CLI Authentication** below before running any resource command.

## CLI Authentication (fallback)

1. Get an API token from the Coolify dashboard at `/security/api-tokens`.
2. Coolify Cloud: `coolify context set-token cloud <token>`
3. Self-hosted: `coolify context add -d <context_name> <url> <token>`
4. Switch active context: `coolify context use <context_name>`

Config file: `~/.config/coolify/config.json` (Linux/macOS) or `%APPDATA%\coolify\config.json` (Windows). Supports multiple saved contexts (instances).

## CLI Operating Rules (fallback)

- Prefer `--format json` for automation/parsing; default `table` output is for humans.
- Use Coolify **UUIDs** for resources — never internal numeric IDs.
- **Exception:** team commands use numeric team IDs.
- Prefer a saved context (`--context <name>`) over passing `--token` on every call.
- `--show-sensitive` reveals fields marked sensitive (tokens, passwords, IPs, emails); omit by default.

## CLI Quick Reference (fallback)

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

This platform follows the devops skill's **Write Confirmation Policy** and **Credential Handling Policy** (see top-level `../SKILL.md`), for both the MCP tools and the CLI: read operations run directly, every write operation requires explicit user confirmation first, stated with the exact command or MCP tool call (tool name and arguments), what it does, and its impact — and tokens/secrets are never requested from the user or read from `~/.config/coolify/config.json` or `~/.config/coolify-mcp/env`; point the user to **MCP Setup** or **CLI Authentication** above instead. Never run a command with `--show-sensitive`.

### MCP tools

**MCP read (no confirmation):** `coolify_help`, `get_infrastructure_overview`, `search_resources`, `list_unhealthy_resources`, `get_current_team`, `list_team_members`, `list_servers`, `get_server`, `get_server_domains`, `get_server_resources`, `get_server_metrics`, `list_destinations`, `get_destination`, `list_projects`, `get_project`, `get_environment`, `list_resources`, `list_applications`, `get_application`, `list_application_previews`, `list_databases`, `get_database`, `list_database_backups`, `list_backup_executions`, `list_services`, `get_service`, `list_service_applications`, `get_service_application`, `list_service_databases`, `get_service_database`, `list_deployments`, `get_deployment`, `list_env_keys`, `list_shared_env_keys`, `list_storages`, `list_resource_tags`, `list_scheduled_tasks`, `list_scheduled_task_executions`, `list_tags`, `list_github_apps`, `list_github_repositories`, `list_github_branches`, `list_service_templates`.

**MCP write (always confirm first):** `control`, `deploy`, `cancel_deployment`, `rollback_application`, `manage_application`, `manage_database`, `manage_service`, `manage_preview`, `manage_scheduled_task`, `manage_storage`, `manage_proxy`, `docker_cleanup`, `manage_registry`, and any tool not listed above.

- IF a `manage_*`/`docker_cleanup` call is a pure read (the action argument is verifiably get/list/read), THEN it may run directly; IF the action is anything else or unclear, THEN treat it as a write and confirm.
- Impact to state per tool: `control` — downtime for that resource until it is back; `deploy` — queues a real deployment (one application, or every resource of the target scope) and may replace the running version; `cancel_deployment` — aborts a queued or in-progress deployment; `rollback_application` — redeploys a previous image and replaces the running version; `manage_application`/`manage_database`/`manage_service` — update, clone, move, or delete (delete is irreversible and may remove data); `manage_preview` — creates, deploys, or deletes a pull request preview; `manage_scheduled_task` — "run now" executes a real command in the container; `manage_storage` — changing or deleting a volume can lose data; `manage_proxy` — can interrupt routing for every application on that server; `docker_cleanup` — pruning removes unused Docker resources and is not reversible; `manage_registry` — adds or removes registry logins and affects image pulls.
- A token with `deploy` permission can change running resources; a `read`-only token rejects write tools at call time.

### CLI commands (fallback)

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
- If a command's read/write status is unclear from the CLI Quick Reference or `references/llms-full.txt`, treat it as a write and confirm.

## Deep Dive

The references below document the CLI (fallback). For MCP tools, use `coolify_help` and the connected tool list instead.

**Load `references/llms-full.txt`** (exhaustive command/flag catalog, one entry per subcommand) when:
- The CLI Quick Reference above doesn't cover the exact subcommand or flag needed.
- Creating apps/databases/services from scratch (build packs, deploy keys, one-click service types, cloud-provider server creation — many required flags).
- Working with backups, storage/volumes, GitHub App integration, or team management.

**Load `references/cli-readme.md`** for install-script details, shell completion setup, or upstream project links not covered above.

Do NOT load either reference for simple list/get/start/stop/restart calls — the CLI Quick Reference is sufficient.
