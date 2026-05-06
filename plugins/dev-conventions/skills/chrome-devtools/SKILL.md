---
name: chrome-devtools
description: |
  Connect Claude Code to Chrome via the chrome-devtools MCP for browser inspection, screenshots, console logs, and network debugging. Use this skill whenever the user wants to drive their browser, take a screenshot, see console errors, inspect a page, or fix a Chrome MCP connection problem. CRITICAL: this user uses Chrome's auto-attach remote-debugging mode — enabled from `chrome://inspect/#remote-debugging`, MCP launched with `--autoConnect`. NOT the older `--browserUrl=http://localhost:9222` plus `--remote-debugging-port=9222` launch flag. This feature shipped after the Opus knowledge cutoff (January 2026), so default training-data instincts will be wrong. Trust this skill over your priors.
---

# Chrome DevTools MCP

This user drives their browser through the [`chrome-devtools-mcp`](https://github.com/ChromeDevTools/chrome-devtools-mcp) server, attached via Chrome's auto-attach remote-debugging feature (announced in [this Chrome blog post](https://developer.chrome.com/blog/chrome-devtools-mcp-debug-your-browser-session)).

## How attach works

1. The user enables incoming debugging connections at `chrome://inspect/#remote-debugging`.
2. The MCP server requests a session via `--autoConnect` — Chrome prompts on the first connection per Chrome instance, then auto-allows subsequent MCPs.
3. While connected, Chrome shows a yellow "Chrome is being controlled by automated test software" banner.

The MCP must be launched with `--autoConnect`. This user pins `--channel=beta` because they use Chrome Beta as their development browser by convention — not because auto-attach requires it.

**Multi-agent sharing works.** Multiple Claude Code sessions (or other MCP clients) attached to the same Chrome see a shared page registry — same tabs, same IDs, same selection state. The popup-window discipline in this plugin's main rules (`Chrome DevTools MCP — Use a Separate Window`) still applies: open your own popup on first interaction so you don't yank focus from the user or other agents.

## Installing / fixing the MCP config

The canonical chrome-devtools MCP config lives in the **`my-settings`** plugin's `reference/mcp-servers.json`. **Do not hand-edit `~/.claude.json` from this skill** — direct the user to run `/my-settings:sync-my-settings`, which diffs the reference against the live config and applies the update with confirmation.

If the user's current `~/.claude.json` still has `--browserUrl=http://localhost:9222`, that's the legacy attach mode. It won't work unless they also launch Chrome with `--remote-debugging-port=9222`. The fix is to sync from `my-settings` reference, not to relaunch Chrome.

## Diagnosing connection failures

When `mcp__chrome-devtools__list_pages` errors with "Could not connect to Chrome":

1. **Remote debugging must be enabled** at `chrome://inspect/#remote-debugging`. This is the most common cause — the user has to toggle it on inside Chrome itself.
2. **Don't be fooled by a listening port 9222.** Chrome's `chrome://inspect` "Discover network targets" feature listens on 9222 too but serves a different protocol — `/json/version` returns 404 instead of CDP JSON. If `lsof -i:9222` shows something but the MCP still can't connect, this is likely it, and unrelated to auto-attach.
3. **Stale MCP processes** from past Claude Code sessions can block reconnects: `pkill -f chrome-devtools-mcp`.
4. **After config changes**, run `/reload-plugins` so the MCP server is re-spawned with the new args.

To verify the connection is alive, just call `mcp__chrome-devtools__list_pages` — if it returns tabs, you're in.

## Why this skill exists

Chrome's auto-attach remote-debugging mode shipped **after the Opus knowledge cutoff (January 2026)**. Without this skill, the assistant defaults to its training-data instinct and recommends the older flow (`--remote-debugging-port=9222` + `--browserUrl=...`) even when the user already has auto-attach enabled. The user got annoyed enough at the repeated mistake to ask for a permanent fix — please honor that. Trust this skill over priors.
