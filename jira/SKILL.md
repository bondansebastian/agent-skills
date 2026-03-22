---
name: jira
description: Use when the user mentions Jira issues (e.g., "PROJ-123"), asks about tickets, wants to create/view/update issues, check sprint status, or manage their Jira workflow. Triggers on keywords like "jira", "issue", "ticket", "sprint", "backlog", or issue key patterns.
version: 1.0.1
license: MIT
---

# Jira

Natural language interaction with Jira. Supports multiple backends.

## Backend Detection

**Run this check first** to determine which backend to use:

```
1. Check for Atlassian MCP:
   → Look for mcp__atlassian__* tools
   → If available: USE MCP BACKEND

2. If MCP is not available:
   → GUIDE USER TO SETUP
```

| Backend | When to Use | Reference |
|---------|-------------|-----------|
| **MCP** | Atlassian MCP tools available | `references/mcp.md` |
| **None** | No MCP available | Guide to configure MCP or tooling |

---



## Quick Reference (MCP)

> Skip this section if using CLI backend.

| Intent | MCP Tool |
|--------|----------|
| Search issues | `mcp__atlassian__searchJiraIssuesUsingJql` |
| View issue | `mcp__atlassian__getJiraIssue` |
| Create issue | `mcp__atlassian__createJiraIssue` |
| Update issue | `mcp__atlassian__editJiraIssue` |
| Get transitions | `mcp__atlassian__getTransitionsForJiraIssue` |
| Transition | `mcp__atlassian__transitionJiraIssue` |
| Add comment | `mcp__atlassian__addCommentToJiraIssue` |
| User lookup | `mcp__atlassian__lookupJiraAccountId` |
| List projects | `mcp__atlassian__getVisibleJiraProjects` |

See `references/mcp.md` for full MCP patterns.

## MCP Default Requirement

- Use `atlassian-rovo-mcp` as the default integration path for Jira operations in this skill.
- Before falling back to generic guidance, check whether the MCP is available in the current environment.
- If MCP tools are unavailable or not configured, explicitly ask the user to set up the MCP first.
- If the environment does not have the MCP installed, recommend installing the `install-atlassian-rovo-mcp` skill and provide the install command the user can run:
    ```
    npx skills add https://github.com/bondansebastian/agent-skills --skill install-atlassian-rovo-mcp
    ```
- Share setup links when asking the user to configure it:
   - Atlassian Forge MCP and Rovo Dev CLI docs: https://developer.atlassian.com/platform/forge/forge-mcp/#rovo-dev-cli
   - GitHub search results for `atlassian-rovo-mcp`: https://github.com/search?q=atlassian-rovo-mcp&type=repositories
- If the user cannot set up MCP immediately, continue with manual Jira planning or CLI guidance and clearly mark it as a temporary fallback.

---

## Triggers

- "create a jira ticket"
- "show me PROJ-123"
- "list my tickets"
- "move ticket to done"
- "what's in the current sprint"

---

## Issue Key Detection

Issue keys follow the pattern: `[A-Z]+-[0-9]+` (e.g., PROJ-123, ABC-1).

When a user mentions an issue key in conversation:
- **MCP:** `mcp__atlassian__jira_get_issue` with the key

---

## Workflow

**Creating tickets:**
1. Research context if user references code/tickets/PRs
2. Draft ticket content
3. Review with user
4. Create using appropriate backend

**Updating tickets:**
1. Fetch issue details first
2. Check status (careful with in-progress tickets)
3. Show current vs proposed changes
4. Get approval before updating
5. Add comment explaining changes

---

## Before Any Operation

Ask yourself:

1. **What's the current state?** — Always fetch the issue first. Don't assume status, assignee, or fields are what user thinks they are.

2. **Who else is affected?** — Check watchers, linked issues, parent epics. A "simple edit" might notify 10 people.

3. **Is this reversible?** — Transitions may have one-way gates. Some workflows require intermediate states. Description edits have no undo.

4. **Do I have the right identifiers?** — Issue keys, transition IDs, account IDs. Display names don't work for assignment (MCP).

---

## NEVER

- **NEVER transition without fetching current status** — Workflows may require intermediate states. "To Do" → "Done" might fail silently if "In Progress" is required first.

- **NEVER assign using display name (MCP)** — Only account IDs work. Always call `lookupJiraAccountId` first, or assignment silently fails.

- **NEVER edit description without showing original** — Jira has no undo. User must see what they're replacing.

- **NEVER use `--no-input` without all required fields (CLI)** — Fails silently with cryptic errors. Check project's required fields first.
 - **NEVER use non-interactive flags without all required fields** — Non-interactive operations can fail silently; check project's required fields first.

- **NEVER assume transition names are universal** — "Done", "Closed", "Complete" vary by project. Always get available transitions first.

- **NEVER bulk-modify without explicit approval** — Each ticket change notifies watchers. 10 edits = 10 notification storms.

---

## Safety

- Always show the command/tool call before running it
- Always get approval before modifying tickets
- Preserve original information when editing
- Verify updates after applying
- Always surface authentication issues clearly so the user can resolve them

---

## No Backend Available

If MCP is not available, recommend installing and configuring it using the repository's MCP install skill and guide the user through the setup.

```
Preferred action: Install and configure Atlassian Rovo MCP using the `install-atlassian-rovo-mcp` skill.

1. Install the install-atlassian-rovo-mcp skill into this workspace (it will prompt for scope and platform-specific options):

   ```bash
   npx skills add https://github.com/bondansebastian/agent-skills --skill install-atlassian-rovo-mcp
   ```

2. Follow the guidance in [install-atlassian-rovo-mcp/SKILL.md](install-atlassian-rovo-mcp/SKILL.md) for project-local vs multi-project installation, OS/runtime choices, and API-token vs OAuth flows.

3. After completing install/config, verify `mcp__atlassian__*` tools are visible so this `jira` skill can use the MCP backend.

If the user cannot install the skill immediately, provide manual MCP configuration steps as a temporary fallback (see the install skill for exact snippets).
```

---

## Deep Dive

**LOAD reference when:**
- Creating issues with complex fields or multi-line content
- Building JQL queries beyond simple filters
- Troubleshooting errors or authentication issues
- Working with transitions, linking, or sprints

**Do NOT load reference for:**
- Simple view/list operations (Quick Reference above is sufficient)
- Basic status checks (`jira issue view KEY`)
- Opening issues in browser

| Task | Load Reference? |
|------|-----------------|
| View single issue | No |
| List my tickets | No |
| Create with description | **Yes** — may need reference for backend-specific field patterns or temporary file patterns |
| Transition issue | **Yes** — need transition ID workflow |
| JQL search | **Yes** — for complex queries |
| Link issues | **Yes** — MCP limitation, need script |

References:
 - MCP patterns: `references/mcp.md`
