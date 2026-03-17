import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { SpendingService } from '@codingsans/billingo-client';
import type { SpendingSave } from '@codingsans/billingo-client';
import { MockSpendingService } from '../mock/index.js';
import type { BillingoConfig } from '../config.js';
import { handleError } from '../helpers.js';
import { currencies, spendingPaymentMethods, categories, paginationParams } from '../constants.js';

function svc(config: BillingoConfig) {
  return config.mockMode ? MockSpendingService : SpendingService;
}

export function registerSpendingTools(server: McpServer, config: BillingoConfig) {
  server.registerTool('list_spendings', {
    description: 'List all spending/expense items. Returns paginated results.',
    inputSchema: {
      ...paginationParams,
      query: z.string().optional().describe('Search query'),
      start_date: z.string().optional().describe('Filter from date (YYYY-MM-DD)'),
      end_date: z.string().optional().describe('Filter to date (YYYY-MM-DD)'),
      category: z.enum(categories).optional().describe('Filter by spending category'),
      currency: z.enum(currencies).optional().describe('Filter by currency'),
    },
  }, async (params) => handleError(() =>
    svc(config).spendingList(
      params.query, params.page, params.per_page,
      undefined, params.start_date, params.end_date,
      undefined, undefined, params.category as any,
      params.currency as any
    )
  ));

  server.registerTool('create_spending', {
    description: 'Record a new spending/expense.',
    inputSchema: {
      currency: z.enum(currencies).describe('Currency code'),
      total_gross: z.number().describe('Gross total amount'),
      total_gross_huf: z.number().describe('Gross total in HUF'),
      total_vat_amount: z.number().describe('VAT amount'),
      total_vat_amount_huf: z.number().describe('VAT amount in HUF'),
      fulfillment_date: z.string().describe('Fulfillment date (YYYY-MM-DD)'),
      category: z.enum(categories).describe('Spending category'),
      payment_method: z.enum(spendingPaymentMethods).describe('Payment method'),
      partner_id: z.number().optional().describe('Partner/vendor ID'),
      invoice_number: z.string().optional().describe('Invoice number from vendor'),
      invoice_date: z.string().optional().describe('Invoice date (YYYY-MM-DD)'),
      due_date: z.string().optional().describe('Due date (YYYY-MM-DD)'),
      paid_at: z.string().optional().describe('Payment date (YYYY-MM-DD)'),
      comment: z.string().optional().describe('Comment/description'),
      conversion_rate: z.number().optional().describe('Currency conversion rate'),
    },
  }, async (params) => handleError(() =>
    svc(config).spendingSave(params as SpendingSave)
  ));

  server.registerTool('get_spending', {
    description: 'Retrieve details of a specific spending item by ID.',
    inputSchema: { id: z.number().describe('Spending ID') },
  }, async ({ id }) => handleError(() => svc(config).spendingShow(id)));
}
