import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { PartnerService } from '@codingsans/billingo-client';
import type { Partner } from '@codingsans/billingo-client';
import { MockPartnerService } from '../mock/index.js';
import type { BillingoConfig } from '../config.js';
import { handleError } from '../helpers.js';
import { partnerTaxTypes, paginationParams } from '../constants.js';

function svc(config: BillingoConfig) {
  return config.mockMode ? MockPartnerService : PartnerService;
}

const addressSchema = z.object({
  country_code: z.string().describe('ISO 3166-1 alpha-2 country code (e.g. HU, DE, US)'),
  post_code: z.string().describe('Postal/ZIP code'),
  city: z.string().describe('City name'),
  address: z.string().describe('Street address'),
}).describe('Address');

export function registerPartnerTools(server: McpServer, config: BillingoConfig) {
  server.registerTool('list_partners', {
    description: 'List all partners (clients). Returns paginated results.',
    inputSchema: {
      ...paginationParams,
      query: z.string().optional().describe('Search by partner name'),
    },
  }, async (params) => handleError(() =>
    svc(config).listPartner(params.page, params.per_page, params.query)
  ));

  server.registerTool('create_partner', {
    description: 'Create a new partner (client/customer).',
    inputSchema: {
      name: z.string().describe('Partner/company name'),
      address: addressSchema,
      emails: z.array(z.string()).optional().describe('Email addresses'),
      taxcode: z.string().optional().describe('Tax number (e.g. 12345678-2-41)'),
      tax_type: z.enum(partnerTaxTypes).optional().describe('Tax type: HAS_TAX_NUMBER, NO_TAX_NUMBER, FOREIGN, or empty'),
      phone: z.string().optional().describe('Phone number'),
      account_number: z.string().optional().describe('Bank account number'),
      iban: z.string().optional().describe('IBAN'),
      swift: z.string().optional().describe('SWIFT/BIC code'),
    },
  }, async (params) => handleError(() =>
    svc(config).createPartner(params as Partner)
  ));

  server.registerTool('get_partner', {
    description: 'Retrieve details of a specific partner by ID.',
    inputSchema: { id: z.number().describe('Partner ID') },
  }, async ({ id }) => handleError(() => svc(config).getPartner(id)));

  server.registerTool('update_partner', {
    description: 'Update an existing partner.',
    inputSchema: {
      id: z.number().describe('Partner ID to update'),
      name: z.string().optional().describe('Partner/company name'),
      address: addressSchema.optional(),
      emails: z.array(z.string()).optional().describe('Email addresses'),
      taxcode: z.string().optional().describe('Tax number'),
      tax_type: z.enum(partnerTaxTypes).optional().describe('Tax type'),
      phone: z.string().optional().describe('Phone number'),
    },
  }, async ({ id, ...data }) => handleError(() =>
    svc(config).updatePartner(id, data as Partner)
  ));
}
