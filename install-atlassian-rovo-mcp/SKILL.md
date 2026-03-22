---
name: install-atlassian-rovo-mcp
description: Setup and install guide for Atlassian Rovo MCP in IDE and agent environments. ALWAYS use this skill when the user asks to install, configure, fix authentication for, or use Atlassian Rovo MCP. Start by asking setup questions (project-local vs multi-project, OS/runtime, client) and then provide the matching install path with exact commands.
version: 1.0.0
license: MIT
---

# Install Atlassian Rovo MCP

Use this skill to guide users through installing and configuring Atlassian Rovo MCP with the correct scope:

- Project-local install (only for current repository/project)
- Reusable multi-project install (shared setup for many repositories)

This skill defaults to the API token method (non-interactive) and can offer OAuth when the user wants an interactive browser flow.

## Why this skill exists

Atlassian now supports API-token authentication for Rovo MCP, so users can run MCP in non-interactive environments (agents, CI/CD, servers, scheduled jobs) without browser consent flow.

Reference:
- https://community.atlassian.com/forums/Atlassian-Remote-MCP-Server/Announcing-authentication-via-API-token-for-Atlassian-Rovo-MCP/ba-p/3197014

## Mandatory Discovery First

Before giving install steps, ask and confirm:

1. Scope preference:
- "Should this work only in the current project, or across multiple projects?"

2. Client/runtime target:
- "Which MCP client should we configure? (VS Code/Copilot, Claude Desktop, Cursor, custom app, CI runner, etc.)"

3. Operating environment:
- "What OS/runtime is your MCP client actually running on?"
- Explicitly disambiguate Windows scenarios:
  - Windows native terminal
  - Windows IDE + WSL project
  - WSL-only/headless runtime

4. Auth method preference:
- "Do you want API token auth (recommended for automation) or OAuth (interactive browser)?"

5. Access context:
- "Do you have Org Admin access to enable API-token auth for Atlassian MCP, or should we check with an admin?"

Do not skip this interview. Installation advice is invalid unless these are known.

## Decision Logic

After discovery, choose exactly one primary path:

- If user says current project only: follow Project-Local Path.
- If user says multiple projects: follow Multi-Project Path.

Then tailor command snippets to the runtime OS where the MCP client executes.

## Core Facts To Apply

- MCP endpoint URL must be: `https://mcp.atlassian.com/v1/mcp`
- API token auth format is Basic Auth with base64(email:api_token)
- Header must be under a `headers` object, not as a loose top-level field
- API-token auth is disabled by default until Org Admin enables it
- If tool list is unexpectedly tiny (for example only two tools), suspect:
  - wrong token type (not Rovo MCP scoped token)
  - missing token scopes
  - incorrect base64 encoding

## Project-Local Path (Current Project Only)

Use when user wants setup isolated to one repository.

### 1) Create/confirm Rovo MCP scoped API token

Guide user to create a token from Atlassian account security page and store it securely.

Suggested token link:
- https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken&expiryDays=max&appId=mcp&selectedScopes=all

Note:
- If Org Admin controls are required, ask user to enable API-token access first.

### 2) Encode credentials for Basic Auth

Input format is exactly:
- `email:api_token`

Linux (GNU coreutils):
```bash
printf %s "your.email@example.com:YOUR_API_TOKEN" | base64 -w0
```

macOS:
```bash
printf %s "your.email@example.com:YOUR_API_TOKEN" | base64
```

Windows PowerShell:
```powershell
$pair = "your.email@example.com:YOUR_API_TOKEN"
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pair))
```

WSL caveat:
- Generate and store secrets in the environment where the MCP client process runs.
- If VS Code/Copilot runs on Windows but project files are in WSL, treat Windows as runtime for credential storage and client config.

### 3) Add project-scoped MCP config

Create or update the project MCP config file used by the selected client (often repo-local such as `.vscode/mcp.json` or equivalent client-local project config).

Example config:

```json
{
  "mcpServers": {
    "atlassian-rovo-mcp": {
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        "Authorization": "Basic BASE64_ENCODED_EMAIL_AND_TOKEN"
      }
    }
  }
}
```

Alternative transport (if client uses command execution):

```json
{
  "mcpServers": {
    "atlassian-rovo-mcp": {
      "command": "npx",
      "args": [
        "mcp-remote@latest",
        "https://mcp.atlassian.com/v1/mcp",
        "--header",
        "Authorization: Basic BASE64_ENCODED_EMAIL_AND_TOKEN"
      ]
    }
  }
}
```

### 4) Validate in current project

- Reload client/IDE if needed.
- List tools from the MCP client.
- Verify expected Jira/Confluence tools are visible.

If not:
- re-check token scope/type
- re-check encoded string
- ensure `headers.Authorization` is used
- confirm endpoint URL is exact

## Multi-Project Path (Reusable Setup)

Use when user wants one setup reused by many repositories.

### Recommended strategy

1. Configure Atlassian Rovo MCP in a user-level/client-global MCP config for the chosen client.
2. Keep secrets in OS-native secure storage (password manager, keychain, vault, CI secret store) when possible.
3. Optionally provide a reusable snippet/template for project configs that reference central values.

Because config paths vary by client and platform, first identify exact client and then provide exact file paths.

### OS/runtime guidance

- Linux native:
  - Use Linux user-level config and Linux secret storage.
- macOS native:
  - Use macOS user-level config and Keychain-backed secret strategy.
- Windows native:
  - Use Windows user-level config and Credential Manager/secure env strategy.
- Windows + WSL:
  - If client runtime is Windows app, keep global config/secrets on Windows side.
  - If runtime is Linux in WSL/container/CI, keep config/secrets in Linux side.
  - Do not split token generation/storage across runtimes unless you explicitly manage both.

### Reusable configuration payload

Use the same server block as in project-local setup, but place it in the client's global MCP config location.

```json
{
  "mcpServers": {
    "atlassian-rovo-mcp": {
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        "Authorization": "Basic BASE64_ENCODED_EMAIL_AND_TOKEN"
      }
    }
  }
}
```

## CI/CD and Headless Install Pattern

For automation contexts, recommend API token auth and secret injection from CI vault.

Checklist:
- Org Admin has enabled API-token access
- token is scoped correctly for required tools
- pipeline injects `Authorization` header value securely
- no secrets committed to repository

## Troubleshooting Checklist

1. Only a few tools discovered:
- verify Rovo MCP scoped token
- verify token scopes for required tools
- re-encode `email:api_token` exactly

2. Auth failures:
- confirm admin setting for API-token access is enabled
- confirm `headers.Authorization` exists
- confirm endpoint `https://mcp.atlassian.com/v1/mcp`

3. Works on one machine but not another:
- compare runtime environment (Windows vs WSL vs container)
- compare config file location used by the active client
- compare token source and scope

4. Search or product-specific tool errors:
- validate required scopes
- test with a minimal known-good tool call
- escalate to Atlassian support when service-side issue is suspected

## Response Template

When responding to users, structure output as:

1. Setup summary (scope + client + runtime + auth)
2. Exact install steps for that environment
3. Minimal config snippet to paste
4. Verification steps
5. Troubleshooting branch if verification fails

## Guardrails

- Never ask users to paste API tokens into chat logs.
- Redact credentials in examples.
- Keep OAuth as fallback for interactive use cases.
- If user asks for both project-local and reusable setup, do project-local first, then provide reusable migration steps.
