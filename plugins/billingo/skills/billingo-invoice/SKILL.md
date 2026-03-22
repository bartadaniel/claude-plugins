---
name: billingo-invoice
description: >
  Upload incoming invoices (bejovo szamla) as spending/expense entries (kiadas) on Billingo —
  things the user has paid for, NOT outgoing invoices to clients.
  Use this skill when the user wants to record, enter, or upload an invoice they received (an expense),
  or when they provide a PDF invoice and ask to enter it on Billingo.
  Do NOT use this for creating outgoing invoices — that's the /billingo:invoice command.
---

# Billingo Invoice Entry

This skill records incoming invoices as spending entries on Billingo. It uses the Billingo MCP API for spending creation, partner management, and exchange rates.

**Attachments** are handled via Chrome DevTools MCP (the Billingo API doesn't support spending attachments). If Chrome DevTools MCP is not available, create the spending entry via the API and inform the user that the PDF attachment must be uploaded manually through the Billingo web UI. If the spending API itself is unavailable, the entire form can be filled via Chrome DevTools as a fallback (see Appendix A).

## Prerequisites

- Billingo MCP server must be connected (provides `mcp__billingo__*` tools)
- Chrome DevTools MCP is **optional** — required only for PDF attachments and as fallback for the spending form
- The invoice PDF must be accessible locally

## Workflow

### Step 1: Extract invoice data from the PDF

Read the PDF with the `Read` tool. Extract these fields:

| Field | What to look for |
|---|---|
| Supplier name | Company name on the invoice (e.g. "Figma, Inc.") |
| Supplier country | Address country (ISO 3166-1 alpha-2 code, e.g. "US", "DE", "HU") |
| Supplier zip | Postal/zip code |
| Supplier city | City name |
| Supplier address | Street address |
| Supplier tax/VAT ID | VAT number, tax ID, EU VAT, etc. |
| Invoice number | Invoice ID / document number |
| Date of issue | Issue date (YYYY-MM-DD) |
| Due date | Payment deadline (YYYY-MM-DD) |
| Paid date | When it was paid (YYYY-MM-DD) — often same as issue date for card payments |
| Currency | EUR, USD, HUF, etc. |
| Line items | Description, quantity, net unit price, VAT amount per line |
| Total gross amount | Gross total |
| Total VAT amount | Tax amount — extract the actual value from the invoice, do not assume 0 |
| Payment method | Card, transfer, etc. — infer from context if not stated |

### Step 2: Check for duplicates

Before creating a new spending entry, check if this invoice has already been recorded.

Use `mcp__billingo__list_spending` with `q` set to the invoice number. If a match is found, skip this invoice and tell the user it's already recorded.

If the invoice is a duplicate, **stop here** — do not create a new entry. Report it as "already exists" and move on to the next invoice.

### Step 3: Find or create the partner

1. **Search for existing partner:** Use `mcp__billingo__list_partners` with `query` set to the supplier name. Try a short/distinctive substring for better matching (e.g. "Figma" not "Figma, Inc.").

2. **If found:** Use the partner's `id` for the spending entry.

3. **If not found:** Create the partner with `mcp__billingo__create_partner`:
   ```
   name: Supplier name
   address:
     country_code: ISO alpha-2 (e.g. "US", "DE", "IE", "HU")
     post_code: Zip code
     city: City
     address: Street address
   taxcode: VAT/tax ID (if available, NO SPACES — e.g. "HU30514142" not "HU 30514142")
   ```

### Step 4: Get exchange rate (foreign currency only)

If the invoice currency is not HUF, fetch the MNB exchange rate for the invoice date:

```
mcp__billingo__get_currency_rates
  to: "EUR" (or "USD", etc.)
  date: invoice issue date (YYYY-MM-DD)
```

The API returns the rate as HUF→foreign (e.g. 0.00255 for EUR). You need the inverse (HUF per 1 unit of foreign currency): `1 / 0.00255 ≈ 391.29`.

### Step 5: Create the spending entry

Use `mcp__billingo__create_spending` with the extracted data:

```
invoice_date: issue date (YYYY-MM-DD)
due_date: payment deadline (YYYY-MM-DD)
paid_at: paid date (YYYY-MM-DD) — always set this!
currency: "EUR", "USD", "HUF", etc.
conversion_rate: HUF per 1 unit of foreign currency (REQUIRED even for HUF — use 1)
payment_method: see mapping table below
partner_id: from Step 3
invoice_number: document number from the invoice
category: English values — "software", "service", "other" (NOT Hungarian)
comment: brief description including service period if applicable
items: array of line items, each with:
  description: item description
  net_unit_amount: net price per unit
  quantity: number of units
  vat_amount: VAT for this line — use the actual value from the invoice
```

The tool auto-computes `total_gross`, `total_vat_amount`, `fulfillment_date`, and HUF equivalents.

**If the API returns 404**, the spending module isn't available — fall back to Chrome DevTools (see Appendix A).

### Step 6: Attach the PDF invoice

**If Chrome DevTools MCP is not available:** Tell the user: "The spending entry was created successfully, but I can't attach the PDF because Chrome DevTools MCP is not installed. You can attach it manually at https://app.billingo.hu/n/spending/list". Then skip to Step 7.

**If Chrome DevTools MCP is available:**

The Billingo API does not support spending attachments. Use Chrome DevTools to attach the PDF to each spending record.

**Spending list URL:** `https://app.billingo.hu/n/spending/list`

For each spending entry:

1. Navigate to `https://app.billingo.hu/n/spending/list` (if not already there)
2. Find the row for this invoice
3. Click the **Csatolmányok** (paperclip) link in that row — a side panel opens
4. Use `mcp__chrome-devtools__upload_file` on the **"Fájl választása"** button (`value="No file chosen"`) with the PDF path
5. Click the **"Feltöltés"** button to confirm the upload — **do not skip this step**, auto-upload is unreliable
6. Verify: the row should now show a blue "1" badge in the Csatolmány column
7. **Close the panel** (click the X link) before opening the next record's panel

### Step 7: Confirm to the user

Present a summary table for each invoice:

| Field | Value |
|---|---|
| Partner | ... |
| Invoice # | ... |
| Date | ... |
| Amount | ... |
| Currency | ... |
| VAT | ... |
| Payment | ... |
| Attachment | attached / manual upload needed / failed |
| Status | Created / Already exists / Error |

## Payment method mapping

| Invoice context | API value |
|---|---|
| Bank transfer / wire | `artutalas` |
| Cash | `cash` |
| Card payment (in person) | `bankcard` |
| Online card / SaaS subscription | `online_bankcard` |
| PayPal | `paypal` |
| Barion | `barion` |
| Advance payment / prepaid | `elore_utalas` |

For SaaS/subscription invoices, `online_bankcard` is usually correct.

## Common invoice types and their mappings

| Invoice source | Category | Payment method | Notes |
|---|---|---|---|
| SaaS (Figma, GitHub, Anthropic, etc.) | software | online_bankcard | Usually EUR |
| Cloud services (AWS, GCP) | software | online_bankcard | Usually USD |
| Consulting/freelancer | service | artutalas | Check if HUF or EUR |
| Office supplies / hardware | other | bankcard or online_bankcard | Usually HUF |
| Education / training | education_and_trainings | bankcard | Usually USD |

## Important notes

- **Always set `paid_at`** — the user expects this to be filled.
- **VAT is not always 0 for foreign invoices.** Some vendors (e.g. Anthropic) charge Hungarian VAT directly. Always extract the actual VAT from the invoice.
- **`conversion_rate` is required even for HUF** — set it to `1`.
- **Category values are English**: `software`, `service`, `other`, `education_and_trainings` — not Hungarian.
- **Taxcode must not contain spaces** (e.g. "HU30514142" not "HU 30514142").
- If the PDF has multiple line items, create a separate item entry for each one. Don't collapse them into a single line.
- Dates must be in YYYY-MM-DD format.

---

## Appendix A: Chrome DevTools fallback for spending creation

If the spending API returns 404, fill the "Új kiadás létrehozása" form at `https://app.billingo.hu/n/spending/create`. Follow the field order below — the form is reactive, so order matters.

### Partner section

1. **Toggle partner checkbox** — Click "A kiadásod partnerhez kapcsolódik?" to enable partner fields.
2. **Partner neve** — Combobox. Type the supplier name, select with `ArrowDown` + `Enter`.
3. **Ország** — Combobox, defaults to "Magyarország". For foreign suppliers, type the Hungarian country name (USA → "Amerikai Egyesült Államok", Germany → "Németország", Ireland → "Írország", Netherlands → "Hollandia"). Select with `ArrowDown` + `Enter`. **Important:** Changing the country changes the Város field — take a fresh snapshot after.
4. **Irányítószám** — Plain text field.
5. **Város** — Plain textbox for foreign countries, combobox for Hungary.
6. **Cím** — Plain text field.
7. **Adószám** — Plain text field.

### Spending details

8. **Pénznem** — Combobox, defaults to HUF. Type currency code and select.
9. **Kategória** — Combobox. Type and select (e.g. "Szoftver", "Szolgáltatás", "Irodaszer").
10. **Megjegyzés** — Free text. Include description and service period.

### Dates

All four date fields are **readonly** — click the calendar icon link to open the date picker. Navigate months with `<` / `>`, click the day number to select. Always snapshot after opening or navigating the calendar.

11. **Kiállítás napja** (Date of issue)
12. **Teljesítés napja** (Fulfillment date) — usually same as issue date
13. **Fizetési határidő** (Payment deadline)
14. **Fizetve** (Paid date) — always set this!

### Document details

15. **Bizonylatazonosító** (Invoice number)
16. **Fizetési mód** — Combobox. Use "Online bankkártya", "Átutalás", "Bankkártya", etc.

### Amounts

17. **Fizetendő bruttó végösszeg** (Total gross amount)
18. **Teljes ÁFA tartalom** (Total VAT)

### Attachment

19. Click "Csatolmány hozzáadása", use `mcp__chrome-devtools__upload_file` on "Fájl választása" with the PDF path, click "Feltöltés".

**Do NOT click "Kiadás létrehozása" unless the user explicitly asks you to submit.**

### Combobox interaction pattern

Billingo uses custom comboboxes:

1. Fill the searchbox with your value using `mcp__chrome-devtools__fill`
2. Press `ArrowDown` to highlight the first option
3. Press `Enter` to select it
4. The dropdown closes and the value is set

Always take a snapshot after filling comboboxes to verify the value was accepted.

### Handling 1Password interference

1Password browser extension may show autofill popups that block form interaction. If a fill operation times out or fails, press `Escape` to dismiss the popup, then retry.
