# Development Conventions

## Agent Autonomy

The agent is free to disagree with the user. If a proposed approach seems wrong, suboptimal, or at odds with the codebase, say so directly and explain why. Do not simply comply to avoid friction.

## Clean Code — No Copy-Paste

Never duplicate logic across files. If the same pattern appears in more than one place, extract it into a shared utility, hook, or component immediately — not as a follow-up.

- **Utilities over repeated functions.** If the same transformation, validation, or helper appears in multiple files, extract it.
- **Stop and refactor first.** If implementing a feature would require copy-pasting existing code, refactor the existing code into something reusable before proceeding.

## Systems Thinking — Build the System, Not Just the Feature

Every task is an opportunity to strengthen the codebase as a whole. Do not just solve the immediate problem — consider how the change fits into the bigger picture.

- **Reuse before creating.** Before building something new, look for existing components, utilities, or patterns that already solve the problem or can be extended to solve it. Duplicate code is a missed abstraction.
- **Respect and evolve architecture.** Understand the existing file structure, data flow, and component hierarchy before making changes. New code should follow established conventions. If a convention is wrong, fix the convention — don't create a parallel one.
- **Leave the codebase better.** When you touch an area and notice a small, obvious improvement (a duplicated constant, an inconsistent naming), fix it — as long as it's low-risk and within the scope of the current work. Don't go on a refactoring spree, but don't ignore easy wins either.

## Documentation — Capture Tribal Knowledge

Be proactive about identifying undocumented conventions, implicit patterns, and decisions that exist only as tribal knowledge. When you discover something that someone new to the project would need to know but isn't written down:

1. **Flag it.** Point out what's undocumented and why it matters.
2. **Suggest where it belongs.** Propose adding it to an existing doc or creating a new one.
3. **Write it.** Don't just note it — offer to add the documentation immediately.

## Frontend

- **Hooks over repeated logic.** If multiple pages share the same `useEffect` logic (auth guards, data fetching, redirects), extract it into a custom hook.
- **Think in components.** UI work should produce composable, reusable pieces. If you're building something that will clearly appear in more than one place, make it a shared component from the start.

## Git — Atomic Commits

When asked to commit changes, split into the smallest logical units possible without extra effort. If changes naturally group into "feature A touches 2 files" and "feature B touches 3 files", make two commits. Do not force a split if the changes are genuinely coupled. No need to over-engineer it — just avoid mammoth single commits when an obvious split exists.
