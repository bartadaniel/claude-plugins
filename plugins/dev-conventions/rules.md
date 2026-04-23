# Development Conventions

## Agent Autonomy

The agent is free to disagree with the user. If a proposed approach seems wrong, suboptimal, or at odds with the codebase, say so directly and explain why. Do not simply comply to avoid friction.

The user often uses voice dictation, which can misrender technical terms — e.g., "Claude" → "cloth", "MCP" → "M C P", "CLAUDE.md" → "Cloud MD". Interpret input charitably and infer the intended meaning from context rather than taking misspellings literally.

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

## Debugging — Evidence Before Guessing

When the user reports something is **broken**, **not working**, or **looks wrong**, gather evidence from the running application **before** reading code or speculating about the cause.

For web applications with a Chrome DevTools MCP connected:

1. `mcp__chrome-devtools__list_pages` — find the active tab.
2. `mcp__chrome-devtools__take_screenshot` — see what the user sees.
3. `mcp__chrome-devtools__list_console_messages` — check for JS errors/warnings.
4. `mcp__chrome-devtools__list_network_requests` — check for failed requests if relevant.
5. Only after gathering this evidence, proceed to code investigation.

For other environments, use whatever observability is available (logs, shell output, status endpoints) before diving into source code. The principle is the same: look at reality first, then form a hypothesis.

## Chrome DevTools MCP — Use a Separate Window

The Chrome DevTools MCP connects to a shared Chrome instance (`--browserUrl=http://localhost:9222`), so multiple Claude sessions may be attached at the same time. Screenshots, clicks, and most interactive tools call `Page.bringToFront()` under the hood — if you drive the user's active tab, you'll yank focus away from whatever they're doing. To avoid that, always work inside your own popup window:

1. **On your first Chrome interaction in a session**, open a popup window via `evaluate_script`. A popup lands in its own OS window; subsequent focus changes stay inside that window and don't disturb the user's primary window:

   ```
   evaluate_script {
     function: "() => { const w = window.open('about:blank', '_blank', 'popup=yes,width=1400,height=900'); return w ? 'ok' : 'blocked'; }"
   }
   ```

   If the result is `blocked`, fall back to `new_page { url: '...', background: true }` and warn the user that focus-stealing mitigation is degraded for this session.

2. **Select the new page without bringing it to front**: call `list_pages`, find the newly-opened entry (typically the last one, URL `about:blank`), then `select_page { pageId, bringToFront: false }`.

3. **Navigate inside that tab** with `navigate_page`. Do not open additional tabs unless the task genuinely requires it — extra tabs tend to land back in the user's main window.

4. **Always `select_page` before acting** if there's any chance another Claude instance has shifted the selection. Never assume the currently-selected page is yours.

5. **Never pass `bringToFront: true`** unless the user explicitly asks — it defeats the whole point of the popup window.

6. **Never close tabs or windows you did not open.** The user closes stale agent windows manually when they're done.
