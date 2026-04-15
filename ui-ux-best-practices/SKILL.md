---
name: ui-ux-best-practices
description: This skill should be used when the user asks about UI/UX best practices, frontend UI implementation, interactive affordances, micro-interactions, motion/animation guidance, accessibility for interactive elements, or improving interactive feedback (including hover and focus states). Provide practical, implementation-focused guidance for visible feedback, performance, and accessibility.
version: 1.0.2
---

# UI/UX Best Practices — Hover & Clickable Feedback

Purpose: Ensure consistent, accessible, and pleasant micro-interactions by requiring visible hover feedback for clickable elements and recommending smooth, respectful animations.

When to use:
- This skill should be used when the user asks about UI feedback, hover states, clickable affordances, interactive micro-interactions, or requests guidance on animation, motion, or accessibility for interactive components.

Guiding rule
- Every clickable element must give visual feedback when hovered. Smoothly animated feedback is preferred, but always respect user motion preferences and accessibility needs.

Recommendations
- Provide a clear, perceivable hover state for buttons, links, controls, cards, and other interactive elements.
- Prefer GPU-accelerated properties (transform, opacity) for animation to preserve performance and avoid layout thrashing.
- Use short durations (100–200ms), with ~150ms as a practical default. Use gentle easing (e.g., cubic-bezier(.2,.9,.2,1)).
- Respect `prefers-reduced-motion` and disable or simplify animations for users who opt out.
- Ensure hover feedback is not the sole cue; include focus-visible and active/pressed states for keyboard and touch users.

Practical examples

Example: primary button (accessible, animated)

```css
.button {
  transition: background-color 160ms cubic-bezier(.2,.9,.2,1),
              transform 160ms cubic-bezier(.2,.9,.2,1),
              box-shadow 160ms ease;
  will-change: transform, box-shadow;
}

.button:hover,
.button:focus-visible {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0,0,0,0.08);
  background-color: #1e40af; /* stronger contrast on hover */
}

/* Respect user preference for reduced motion */
@media (prefers-reduced-motion: reduce) {
  .button {
    transition: none;
    transform: none;
  }
}
```

Links
- Provide a visible underline or color transition on hover and ensure the contrast meets accessibility guidelines. Example: `a { text-decoration-skip-ink: auto; transition: color 140ms ease; }`.

Cards & interactive regions
- Use a subtle lift (translateY(-2px) + soft shadow) or a highlight outline on hover to show interactivity.
- For touch-first contexts, provide an immediate press/active state (background tint or ripple) — do not rely on hover.

Accessibility & keyboard
- Implement `:focus-visible` styles that mirror hover styles so keyboard users receive the same feedback.
- Do not use color alone to indicate interactivity; combine color with movement, underline, shadow, or an icon state change.

Performance and best practices
- Animate transform and opacity where possible; avoid animating layout properties (width/height/top/left) in critical paths.
- Limit heavy box-shadows and large blurs; use subtle shadows for hover affordance.

Testing checklist
- Verify hover, focus, and active states for all interactive elements.
- Test with keyboard-only navigation and screen reader on/off to confirm affordance and semantics.
- Test with `prefers-reduced-motion: reduce` enabled to ensure no disruptive motion.
- Validate color contrast for hover states.

Common pitfalls
- Relying solely on color changes (fails color-blind users).
- Long, slow transitions ( > 300ms ) that feel laggy.
- Animating properties that force layout and cause jank.

Examples of prompts to use this skill
- "Make the hover state for primary buttons more visible and accessible."
- "Add hover feedback to all clickable cards and ensure keyboard focus matches hover styles."
- "Suggest an accessible animation for link hover that respects reduced-motion."

References
- Prefer short, actionable examples and include code snippets where helpful.
