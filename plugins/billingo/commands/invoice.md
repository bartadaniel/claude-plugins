---
name: invoice
description: Create a new invoice through a guided workflow
arguments:
  - name: partner
    description: Partner/client name (optional - will search or create)
    required: false
---

Help the user create a new Billingo invoice step by step:

1. **Look up document blocks** — Call `list_document_blocks` to find the right numbering sequence
2. **Find or create partner** — If a partner name was given, call `list_partners` with a query. If not found, ask the user for details and `create_partner`
3. **Find or create products** — Call `list_products` to show available products. Ask if they want to use existing ones or create new items inline
4. **Gather invoice details** — Confirm with the user:
   - Type (invoice/proforma/draft/advance)
   - Fulfillment date and due date
   - Payment method
   - Currency and language
   - Any comments
5. **Create the document** — Call `create_document` with all gathered data
6. **Offer next steps** — Ask if they want to:
   - Send it via email (`send_document`)
   - Get a public link (`get_document_public_url`)
   - Download the PDF (`download_document`)
