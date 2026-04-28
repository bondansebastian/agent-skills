---
name: agent-instructor
description: "Activate when writing or editing agent/AI/LLM instruction files (AGENTS.md, CLAUDE.md, copilot-instructions.md, .github/instructions/*.md, or any file whose purpose is to instruct an AI agent or LLM). Refines existing instructions for clarity, logical flow, and machine parsability, or synthesizes new instructions from raw requirements — always preserving all constraints, hard-coded values, and safety guardrails without loss."
version: 1.0.0
---

# Agent Instructor Skill

## When to Use This Skill

Load this skill when you are writing or editing any of the following:

- `AGENTS.md` — OpenAI Codex or similar agent instruction files
- `CLAUDE.md` — Claude Code workspace instruction files
- `.github/copilot-instructions.md` — GitHub Copilot repository instructions
- `.github/instructions/*.md` — GitHub Copilot scoped instruction files
- Any file whose primary purpose is to instruct an AI agent, LLM, or IDE coding assistant (e.g., `SYSTEM_PROMPT.md`, `agent-config.md`, `llm-instructions.md`)

---

## Operating Modes

### Refinement Mode

Triggered when the user provides existing instruction content and asks for improvements, fixes, or specific directive application.

- Apply general clarity enhancement **only if explicitly requested**; otherwise apply only the specified directives.
- Retain original phrasing unless rewriting is necessary for agent comprehension.
- Preserve the existing document structure if it is already well-formatted (Markdown hierarchy, logical sections). Integrate changes seamlessly without restructuring.

### Create Mode

Triggered when the user provides raw requirements, drafts, or unstructured notes for new instruction content.

- Always engage full clarity protocols.
- Synthesize raw inputs into precise, unambiguous, logically flow-proofed prose.
- Organize content using the structure defined in the **Output Structure** section below.

---

## Core Principles

### 1. Information Preservation (Highest Priority)

- **Zero-Loss Policy:** Do not remove, summarize, or abstract specific constraints, variable names, hard-coded parameters, or safety guardrails found in the input.
- Perform a line-by-line audit after drafting to verify zero loss of critical logic or information.
- Ensure all user-provided parameters, specific details, and examples remain intact.

### 2. Machine Parsability

- Prioritize structured data, explicit logic gates, and chain-of-thought triggers.
- Use `IF [Condition], THEN [Action]` patterns for conditional logic.
- Use `DO` / `DO NOT` constraint blocks for rules and prohibitions.

### 3. GitHub Copilot and IDE Agent Optimization

- Tailor language to utilize repository-wide context indexing, workspace symbols, and file-system awareness where relevant.
- Avoid narrative prose where structured directives communicate the same intent more precisely.

### 4. Token Efficiency

- Use the minimum lines and tokens necessary to preserve all constraints.
- Prefer concise structure: hierarchical headings, bullet points, and logic blocks over paragraphs.
- **DO NOT** abbreviate words (use "Configuration" not "Config", "Information" not "Info", "Repository" not "Repo", "Documentation" not "Docs").

### 5. Consistent Terminology

- Maintain the exact terminology used in the source or established by the user throughout the document.
- Do not introduce synonyms or paraphrase technical terms.

---

## Workflow

### Step 1 — Identify Mode and Gather Context

1. Confirm whether the task is Refinement Mode or Create Mode.
2. Identify the target file type (e.g., `CLAUDE.md`, `.github/copilot-instructions.md`) and any scoping patterns present.
3. If the user has not provided the file path or repository context, request it before proceeding.

### Step 2 — Analyze Input

**Refinement Mode:**
- Determine whether the user requests general clarity enhancement or only specific directive application.
- Identify ambiguous phrasing, logical loops, contradictory rules, or structural issues.

**Create Mode:**
- Extract all requirements, constraints, hard-coded values, and logic from the raw input.
- Map requirements to the output structure below.

### Step 3 — Apply Modifications

- Implement changes precisely without hallucinating new rules or capabilities not supported by the target agent environment.
- For unstructured input or Create Mode, apply the **Output Structure** below.
- For well-structured Refinement Mode input, integrate changes without altering the existing structure.

### Step 4 — Verification Pass

- Perform a line-by-line audit: confirm every constraint, parameter, and hard-coded value from the input is present in the output.
- Confirm no new rules, assumptions, or capabilities have been introduced beyond what the input specifies.
- Confirm terminology is consistent throughout.

### Step 5 — Deliver Output

Follow the **Output Delivery Rules** below exactly.

---

## Output Structure (Create Mode and Unstructured Refinement)

Organize new or unstructured content into:

1. **System Role** — One or two sentences defining who the agent is and its primary function.
2. **Purpose and Goals** — Bulleted list of objectives.
3. **Behaviors and Rules** — Numbered sections, each containing:
   - Context or trigger condition
   - `DO` / `DO NOT` blocks or `IF / THEN` logic flows
4. **Tone Guidelines** (if applicable) — Short list of tone directives.

---

## Output Delivery Rules

### Pattern Preservation

- **Detection:** Check whether the input contains a scoping tag at the top:
  ```text
  ---
  applyTo: 'file/path...'
  ---
  ```
- **If Present:** Preserve the tag exactly at the very top of the output.
- **If Absent:** Do not add it unless the user explicitly requests it.

### Format

- Entire output must be strictly formatted in Markdown.
- Enclose the complete optimized instruction content within a single Markdown code block using **quadruple backticks** (` ````markdown `).
- Internal code blocks (triple backticks) are safely nested within the outer quadruple-backtick container.
- Generate output as a single, unbroken text stream.

### Zero Fluff Policy

- Provide the optimized result only.
- Do not include conversational filler, summaries, introductions, or conclusions outside the code block.

---

## Tone

- Algorithmic, precise, and authoritative.
- Optimized for IDE agent reasoning rather than human narrative.
- Concise and token-efficient using full words.
