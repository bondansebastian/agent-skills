---
name: react-best-practices
description: "Opinionated React component architecture: SRP-driven splits, colocation, state isolation, explicit props, re-exported types, naming conventions, and practical file-size targets for maintainable components."
version: 1.0.1
---

# React Best Practices Skill

## When to use this skill

Load this skill when you are:

- Reviewing or refactoring an existing React component
- Splitting a large "God Component" into smaller sub-components
- Deciding how to colocate, organize, or name component files
- Applying SRP (Single Responsibility Principle) to React code
- Deciding on component folder structure, state isolation, or prop contracts

---

## Core Principles

### 1. Single Responsibility Principle (SRP)

Each component should do **one thing**. If a component handles multiple states (loading, error, empty, ready, editing, confirming) it is a "God Component" and should be split.

**Red flags for a God Component:**

- More than ~150–200 lines of JSX/TSX
- More than 3–4 `if`/`switch` branches returning different UI trees
- State variables that are only relevant for one of several render branches
- A component name like `Card` or `Form` that actually covers multiple sub-states

---

### 2. Component Colocation (the Folder Pattern)

When splitting a large component, colocate all sub-components in a dedicated folder named after the root component.

**Structure:**

```text
components/
└── feature-name/
    ├── index.tsx              # Entry point — the "Router" that delegates to sub-components
    ├── types.ts               # Shared interfaces and type aliases
    ├── feature-name-state-a.tsx
    ├── feature-name-state-b.tsx
    ├── shared-sub-component.tsx
    └── ...
```

The `index.tsx` only contains the routing logic (state checks → early returns → delegate). It must not contain any JSX beyond delegation calls.

**Example index.tsx shape:**

```tsx
"use client";
import { useState, useEffect } from "react";
import type { MyComponentProps, Mode } from "./types";
import { MyComponentLoading } from "./my-component-loading";
import { MyComponentError } from "./my-component-error";
import { MyComponentEdit } from "./my-component-edit";
import { MyComponentView } from "./my-component-view";

export type { MyDataType } from "./types"; // re-export shared types for consumers

export function MyComponent({ data, ...handlers }: MyComponentProps) {
  const [mode, setMode] = useState<Mode>("view");

  if (data.status === "LOADING") return <MyComponentLoading />;
  if (data.status === "ERROR") return <MyComponentError data={data} />;
  if (mode === "edit") return <MyComponentEdit data={data} onCancel={() => setMode("view")} />;

  return <MyComponentView data={data} onSetMode={setMode} />;
}
```

---

### 3. State Isolation

Move state into the sub-component that owns it. Do **not** hoist state to the parent/index unless multiple siblings share it.

| State           | Lives in                                             |
| --------------- | ---------------------------------------------------- |
| `isSubmitting`  | The sub-component with the button                    |
| `editTopic`     | `feature-edit.tsx`                                   |
| `previewDraft`  | The sub-component that opens the preview modal       |
| `mode` (router) | `index.tsx` — it decides which sub-component renders |

---

### 4. Props Design

- Sub-component props should be **minimal and explicit**. Pass only what the sub-component uses.
- Callbacks passed to sub-components should be typed at the call site in `index.tsx`:

  ```tsx
  // Good — explicit partial handlers
  <MyComponentEdit onApprove={onApprove} onCancel={() => setMode("view")} />

  // Bad — sprawling prop pass-through
  <MyComponentEdit {...props} setMode={setMode} />
  ```

- Define all interfaces in `types.ts`, not inline.

---

### 5. Re-exporting Shared Types

The `index.tsx` must re-export any types that consumers of the component import, so existing import paths remain unchanged:

```tsx
// In idea-card/index.tsx
export type { ContentIdeaData } from "./types";
export { IdeaCard } from "./idea-card"; // if needed
```

This means consumers that use `import type { ContentIdeaData } from "@/components/ideas/idea-card"` continue to work without changes after the folder split.

---

### 6. Shared Sub-components

Sub-components used by **more than one** sibling (e.g. `ChannelBadges` used in both `idea-card-failed.tsx` and `idea-card-ready.tsx`) should live inside the same folder as a standalone file (e.g. `channel-badges.tsx`), **not** hoisted to a parent folder unless they are reused across multiple feature folders.

---

### 7. File Size Target

| Role           | Target size      |
| -------------- | ---------------- |
| `index.tsx`    | < 50 lines       |
| Sub-components | < 150 lines each |
| `types.ts`     | < 50 lines       |
| Shared utils   | < 80 lines       |

If a sub-component exceeds 150 lines, consider a further split.

---

### 8. Naming Conventions

| Pattern                       | Used for                                             |
| ----------------------------- | ---------------------------------------------------- |
| `{feature}-{status/mode}.tsx` | Status-driven sub-components                         |
| `{feature}-{noun}.tsx`        | Shared UI sub-components (e.g. `channel-badges.tsx`) |
| `index.tsx`                   | Entry point / router only                            |
| `types.ts`                    | All exported interfaces and type aliases             |

---

### 9. "use client" Placement

- Only add `"use client"` to files that use hooks (`useState`, `useEffect`, `useCallback`, etc.) or browser APIs.
- Pure presentational sub-components without hooks do **not** need `"use client"`.
- `index.tsx` needs `"use client"` if it manages router state (e.g. `useState<Mode>`).

---

### 10. Do Not Over-Abstract

- Do not create a generic `StatusRouter` abstraction for one-off component splits.
- Do not extract helpers into a separate `utils.ts` unless they are used in 3+ files.
- `formatTimestamp` can be a module-level function in each sub-component file — duplication is acceptable at this scale.
