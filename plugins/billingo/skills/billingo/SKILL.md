---
name: billingo
description: Manage invoices, partners, products, and expenses via Billingo. Use when the user mentions invoicing, billing, számlázás, creating invoices, partners/clients, tax numbers, or Billingo.
---

You have access to Billingo MCP tools for Hungarian invoicing. Use these tools to help the user manage their Billingo account.

## Available Tools

**Documents (invoices):**
- `list_documents` — Browse invoices with filters (date, partner, status, type)
- `create_document` — Create invoice, proforma, advance, or draft
- `get_document` — View invoice details
- `cancel_document` — Cancel/storno an invoice
- `send_document` — Email an invoice
- `download_document` — Get PDF
- `get_document_public_url` — Get shareable link
- `update_document_payment` — Record payment on invoice

**Partners (clients):**
- `list_partners` — Browse clients
- `create_partner` — Add new client
- `get_partner` — View client details
- `update_partner` — Modify client info

**Products:**
- `list_products` — Browse product catalog
- `create_product` — Add new product
- `get_product` — View product details
- `update_product` — Modify product

**Spendings (expenses):**
- `list_spendings` — Browse expenses
- `create_spending` — Record expense
- `get_spending` — View expense details

**Utilities:**
- `check_tax_number` — Validate Hungarian tax number against NAV
- `get_organization` — View own company data
- `get_exchange_rate` — Currency conversion rates
- `list_document_blocks` — List invoice numbering sequences
- `list_bank_accounts` — List bank accounts
- `create_bank_account` — Add bank account

## Important Context

- Hungarian invoicing requires NAV (tax authority) compliance
- Default currency is HUF, default language is "hu"
- Tax numbers follow format: 12345678-2-41
- Common VAT rates: 27% (standard), 0%, AAM (exempt), EU (intra-community)
- Common payment methods: wire_transfer, cash, bankcard, barion
- To create an invoice you need: partner_id, block_id, items, dates, payment_method, currency, language
- Always list document_blocks first to get the correct block_id for the document type
- When creating invoices, prefer looking up existing partners/products first
