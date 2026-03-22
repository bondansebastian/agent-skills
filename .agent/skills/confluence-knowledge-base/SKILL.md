---
name: confluence-knowledge-base
description: Guide for creating and maintaining a product-specific Confluence knowledge base where all teams share understanding of the product, features, decisions, and customer insights in plain language. ALWAYS use this skill when the user requests ANY Confluence operation—creating pages, documenting features, setting up structures, managing business rules, or updating content. Use for both single pages and full space architecture. The knowledge base is product-focused, may contain product-related business rules, and should be accessible to design, engineering, sales, and support teams.
version: 1.0.0
license: MIT
---

# Confluence Knowledge Base — Skill

Purpose
-------
Build a product-specific knowledge base in Confluence where the team shares a single source of truth about the product, its features, customer insights, product-related business rules, and decisions. Written in plain language accessible to all teams (design, engineering, sales, support).

When to use
-----------
- User requests any Confluence operation (creating pages, documenting features, managing rules, etc.)
- Documenting product features and how they work
- Recording product decisions and their rationale
- Documenting product-specific business rules (pricing, access, constraints)
- Capturing customer insights and use cases related to the product
- Creating shared understanding of the product across departments

Space Skeleton
--------------
📁 [Product Name] Knowledge Base
│
├── 🏠 Home (Quick links, upcoming reviews, key contacts)
│
├── 📋 Product Overview
│   ├── What We Built & Why
│   ├── Key Terminology (Glossary)
│   ├── Customer Problems Solved
│   └── Success Metrics
│
├── ⚙️ Features
│   └── [Feature Name]
│       ├── What It Is & Why We Built It
│       ├── Customer Problem Solved
│       ├── How It Works (Overview for all roles)
│       ├── Key Product Rules
│       ├── Design & User Experience
│       ├── Launch Plan & Timeline
│       └── Decisions Made & Alternatives Considered
│
├── 📊 Product Rules & Constraints
│   ├── Rules Index
│   ├── Pricing & Access Rules
│   ├── Feature Limitations & Why
│   └── Edge Cases
│
├── 🎯 Customer Knowledge
│   ├── Use Cases & Success Stories
│   ├── Customer Feedback & Insights
│   └── Common Questions & Issues
│
├── 📅 Releases & Updates
│   ├── Communication Guidelines
│   ├── Escalation Procedures
│   └── Incident & Issue Resolution
│
└── 📅 Releases & Announcements
    ├── Latest Updates
    └── [Release Name] Information

Key Practices
-------------
1. Product Rules Index
   - Master table showing: Rule | Why It Exists | Affected Feature | Priority | Owner | Last Reviewed
   - Written in plain language anyone can understand, not technical jargon
   - Links to the features that enforce or depend on each rule
   - Focus on product constraints and behaviors (not internal implementation)

2. Feature Page Template (use for every feature)
   - Status (Draft / Approved / Active / Retired) — clear badge at top
   - Page owner assigned (required)
   - Quick summary: "What is it?" and "Why did we build it?" (2-3 sentences)
   - Customer problem it solves
   - How it works (visual overview; avoid technical implementation details)
   - Key product rules and constraints that apply
   - Design & user experience (embed Figma mockups)
   - Launch timeline and rollout plan
   - Decision log explaining choices and alternatives considered
   - Last reviewed date and next review date

3. Organization & Navigation
   - Keep depth shallow: 3-4 levels maximum
   - Use consistent naming across all pages
   - Focus on product-related content only (internal processes belong in separate space if needed)
   - Create clear indexes so people can find what they need

4. Linking & Cross-References
   - Link related features instead of duplicating information
   - Connect features to the customer problems they solve
   - Link product rules to the features that enforce them
   - Embed visual assets (Figma, mockups, diagrams) directly

5. Governance & Maintenance
   - Assign a single owner to each page (required field)
   - Schedule quarterly reviews; owners responsible for keeping info current
   - Add a "Last Reviewed" date visible on every page
   - Mark outdated content as "Archived" — never delete, always preserve history
   - Use simple language; avoid internal jargon or explain it in a glossary

Feature Page Template
---------------------
Page Title: `[Feature Name] — Short description`

Quick Info Box (at top):
- Status: ☑️ Active / 📋 Draft / 🗺️ Planned / 🗄️ Retired
- Owner: Name or Team
- Last Reviewed: YYYY-MM-DD
- Next Review: YYYY-MM-DD

Main Sections:
1. **What & Why** (1-2 paragraphs)
   - What is this feature?
   - What customer problem does it solve?
   - Why is it valuable to our customers?

2. **How It Works** (Overview for all functions)
   - Explain in simple terms how users interact with it
   - Include visuals (screenshots, mockups, flowcharts)
   - Avoid internal technical implementation details

3. **Product Rules & Constraints**
   - Important product rules that apply to this feature
   - Limitations or restrictions (what users can't do and why)
   - Access or availability constraints

4. **Design & User Experience**
   - Embed Figma mockups or screenshots
   - Key user workflows shown visually

5. **Launch & Timeline**
   - When is/was it launched?
   - Rollout plan if phased
   - Customer communication approach

6. **Decisions & Alternatives**
   - What were the key product choices?
   - What alternatives were considered and why were they rejected?
   - Who made the decision and when?

7. **Related Information**
   - Links to customer use cases or success stories
   - Links to related features
   - Links to product rules that affect it

Product Rules Index — Example Columns
--------------------------------------
| Rule | Plain Language Explanation | Why It Exists | Affects Which Feature(s) | Priority | Owner | Last Reviewed |
|---|---|---|---|---|---|---|
| PR-001 | Users can only have one active account at a time | Fraud prevention and data integrity | Account Management | High | Product Team | 2026-01-15 |
| PR-002 | Free users see ads; paid users don't | Revenue model and user experience differentiation | Subscriptions | High | Product Team | 2026-02-01 |

Simple Formatting & Organization
----------------------------------
- Use Confluence Status macros for page lifecycle visibility (Draft / Active / Archived)
- Use visually engaging icons or emojis where possible to improve scanability and section clarity.
- Assign page owners so people know who to ask questions
- Put "Last Reviewed" date at top so everyone knows if content is current
- Add labels to pages for easy filtering (e.g., "sales", "feature", "archived", "needs-review")
- Use visuals: flowcharts, screenshots, mockups — they communicate faster than text
- Keep consistent formatting so pages feel like a unified knowledge base

Page Health Checklist
---------------------
Before publishing or after quarterly review, confirm:
- ✅ Page has a clear owner assigned (who do I contact with questions?)
- ✅ Last Reviewed date is recent (within 90 days)
- ✅ Status is set clearly (Active / Draft / Archived)
- ✅ Content is written for a broad audience (not jargon-heavy)
- ✅ Key visuals are present (mockups, flowcharts, screenshots)
- ✅ Related pages are linked (connects the knowledge base)
- ✅ Decision rationale is documented (explains the "why")

Common Pitfalls & Fixes
-----------------------
| Problem | Solution |
|---------|----------|
| Info duplicated across multiple pages | Create one "source of truth" page and link to it from other pages |
| Nobody ever updates the knowledge base | Assign owners and tie updates to quarterly reviews; remind them on calendar |
| Pages are too technical; only engineers understand them | Rewrite for a general audience; create a glossary for unavoidable terms |
| Too many nested pages; hard to navigate | Flatten structure to 3-4 levels; use clear section titles on main pages |
| Business decisions buried in Slack or emails | Policy: Decisions go in Confluence with rationale; Slack is for discussion only |
| No consistency in how pages are formatted | Create and enforce simple templates; all feature pages look similar |
| Pages become outdated and wrong | Assign owners responsible for quarterly reviews; add visible "Last Reviewed" date

How the skill should be used by agents
-------------------------------------
- **On any Confluence operation request:** Use this skill to guide documentation structure, tone, and organization.
- When creating or updating a feature page, use the Feature Page Template and keep language accessible to all team members.
- When adding product rules, update the Rules Index with plain-language explanations and link affected features.
- When documenting product decisions, focus on the "why" and alternatives considered, not internal implementation details.
- When reviewing knowledge base content, ensure it's understandable to someone outside engineering (not overly technical).

Examples
--------
**Example Product Rule:**
- Rule: "Free users can only have 3 saved items; paid users unlimited"
- Why: Storage and infrastructure costs; incentivizes premium upgrade
- Affects: Search, Saved Items, Subscription features
- Priority: High
- Owner: Product Team
- Last Reviewed: 2026-02-01

**Example Feature Page Titles:**
- "Smart Search — How It Finds What You Need"
- "Collections — Organize Content You Love"
- "Premium Subscription — What Paid Users Get"

Maintenance & Review Process
-----------------------------
- Every page has an owner; that person is responsible for keeping it accurate.
- Set up calendar reminders for quarterly reviews (every 3 months).
- During a review, the owner confirms: "Is this still accurate? Has anything changed?"
- Update the "Last Reviewed" date after each review.
- Create a simple dashboard (Home page) showing which pages are due for review.
- Have a team member periodically spot-check pages to ensure accuracy and readability.

Appendix — Quick Start Template
--------------------------------
When creating a new page, start with this structure:

```
Title: [Feature Name] — [1-line description]

STATUS: [Draft / Active / Planned / Archived]
OWNER: [Name/Team]
LAST REVIEWED: [Date]

## What & Why
[2-3 sentences explaining what this feature is and why it matters to customers]

## How It Works
[Simple overview with visuals]

## Product Rules & Constraints
- Rule 1 and why it exists
- Rule 2 and why it exists

## Design & User Experience
[Screenshots or mockups]

## Timeline
[When launched / planned]

## Decisions Made
- Decision 1: Why we chose this, what we rejected
- Decision 2: Why we chose this, what we rejected

## Related Features
- Link to feature/rule X
- Link to feature/rule Y
```

Tips for Product Knowledge Base Success
----------------------------------------
- **Start simple:** Don't try to document everything at once. Begin with your most important features.
- **Use plain language:** If someone from Sales, Design, or Support wouldn't understand it, rewrite it.
- **Product focus:** Document what the product does and why, not how it's built. Internal processes belong elsewhere.
- **Make it visual:** Screenshots, flowcharts, mockups, and Figma embeds help communicate faster than paragraphs.
- **Link generously:** Connect features to the problems they solve; link rules to the features that enforce them.
- **Review regularly:** Outdated knowledge is worse than no knowledge. Assign owners and hold them accountable with quarterly reviews.
- **Involve all voices:** Get input from support, sales, design, and engineering so the knowledge base captures all perspectives.
