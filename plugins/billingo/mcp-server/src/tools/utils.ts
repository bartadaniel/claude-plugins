import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { UtilService, OrganizationService, CurrencyService, DocumentBlockService } from '@codingsans/billingo-client';
import type { Currency } from '@codingsans/billingo-client';
import { MockUtilService, MockOrganizationService, MockCurrencyService, MockDocumentBlockService } from '../mock/index.js';
import type { BillingoConfig } from '../config.js';
import { handleError } from '../helpers.js';
import { currencies, paginationParams } from '../constants.js';

export function registerUtilTools(server: McpServer, config: BillingoConfig) {
  server.registerTool('check_tax_number', {
    description: 'Validate a Hungarian tax number format and check against NAV (tax authority).',
    inputSchema: { tax_number: z.string().describe('Hungarian tax number (format: 12345678-2-41)') },
  }, async ({ tax_number }) => handleError(() => {
    const svc = config.mockMode ? MockUtilService : UtilService;
    return svc.checkTaxNumber(tax_number);
  }));

  server.registerTool('get_organization', {
    description: 'Retrieve your organization/company data from Billingo.',
    inputSchema: {},
  }, async () => handleError(() => {
    const svc = config.mockMode ? MockOrganizationService : OrganizationService;
    return svc.getOrganizationData();
  }));

  server.registerTool('get_exchange_rate', {
    description: 'Get the exchange rate between two currencies.',
    inputSchema: {
      from: z.enum(currencies).describe('Source currency code'),
      to: z.enum(currencies).describe('Target currency code'),
      date: z.string().optional().describe('Date for historical rate (YYYY-MM-DD)'),
    },
  }, async ({ from, to, date }) => handleError(() => {
    const svc = config.mockMode ? MockCurrencyService : CurrencyService;
    return svc.getConversionRate(from as Currency, to as Currency, date);
  }));

  server.registerTool('list_document_blocks', {
    description: 'List all document blocks (invoice numbering sequences).',
    inputSchema: { ...paginationParams },
  }, async (params) => handleError(() => {
    const svc = config.mockMode ? MockDocumentBlockService : DocumentBlockService;
    return svc.listDocumentBlock(params.page, params.per_page);
  }));
}
