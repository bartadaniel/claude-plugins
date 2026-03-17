---
name: report
description: Generate a revenue and spending summary report
arguments:
  - name: period
    description: "Time period: month, quarter, or year (default: month)"
    required: false
---

Generate a financial summary report from Billingo data:

1. **Determine date range** — Based on the period argument (default: current month), calculate start_date and end_date
2. **Fetch documents** — Call `list_documents` with the date range to get all invoices
3. **Fetch spendings** — Call `list_spendings` with the date range
4. **Summarize** — Present a formatted report with:
   - Total revenue (by payment status: paid vs outstanding)
   - Revenue breakdown by partner
   - Total spendings by category
   - Net result (revenue - spendings)
   - Currency breakdown if multiple currencies are used
5. **Highlight** — Flag any overdue invoices (payment_status: expired or outstanding past due_date)
