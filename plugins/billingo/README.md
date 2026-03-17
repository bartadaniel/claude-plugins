# Billingo Plugin

Manage invoices, partners, products, and expenses via the [Billingo](https://www.billingo.hu) Hungarian invoicing API directly from Claude Code.

## Setup

1. Get your API key from [Billingo API settings](https://app.billingo.hu/api-key)
2. Set the environment variable:
   ```bash
   export BILLINGO_API_KEY=your-api-key-here
   ```

## Features

- **25 MCP tools** covering documents, partners, products, spendings, bank accounts, and utilities
- **Mock mode** — works without an API key for testing (set `BILLINGO_MOCK=true`)
- **Guided workflows** via slash commands:
  - `/billingo:invoice` — step-by-step invoice creation
  - `/billingo:report` — revenue and spending summary

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
