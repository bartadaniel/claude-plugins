# Billingo Plugin

Manage invoices, partners, products, and expenses via the [Billingo](https://www.billingo.hu) Hungarian invoicing API directly from Claude Code.

## Setup

1. Get your API key from [Billingo API settings](https://app.billingo.hu/api-key)
2. Set the environment variable — either in your shell profile:
   ```bash
   export BILLINGO_API_KEY=your-api-key-here
   ```
   Or via Claude Code settings (keeps it scoped to Claude Code only):
   ```bash
   /config set env.BILLINGO_API_KEY your-api-key-here
   ```

### Optional: Chrome DevTools MCP

The spending entry workflow can automatically attach PDF invoices to Billingo spending records via Chrome DevTools. This requires a Chrome DevTools MCP server to be configured separately. Without it, spending entries are created normally but PDF attachments must be uploaded manually through the Billingo web UI.

## Features

- **25 MCP tools** covering documents, partners, products, spendings, bank accounts, and utilities
- **Mock mode** — works without an API key for testing (set `BILLINGO_MOCK=true`)
- **Guided workflows** via slash commands:
  - `/billingo:invoice` — step-by-step invoice creation
  - `/billingo:report` — revenue and spending summary
- **Skills:**
  - `billingo` — general Billingo tool usage (triggered by invoicing/billing keywords)
  - `billingo-invoice` — upload incoming invoices (things you paid for) as spending/expense entries from PDF, with duplicate checking, partner management, exchange rates, and optional PDF attachment via Chrome DevTools

## Tools

| Category | Tools |
|---|---|
| Documents | list, create, get, cancel, send, download, public URL, update payment |
| Partners | list, create, get, update |
| Products | list, create, get, update |
| Spendings | list, create, get |
| Bank Accounts | list, create |
| Utilities | check tax number, get organization, exchange rate, document blocks |

## MCP Server

The MCP server is published as [`@daniel.barta/billingo-mcp`](https://www.npmjs.com/package/@daniel.barta/billingo-mcp) and can be used standalone:

```bash
npx @daniel.barta/billingo-mcp
```
