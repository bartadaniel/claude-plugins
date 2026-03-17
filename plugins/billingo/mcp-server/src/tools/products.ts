import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { ProductService } from '@codingsans/billingo-client';
import type { Product } from '@codingsans/billingo-client';
import { MockProductService } from '../mock/index.js';
import type { BillingoConfig } from '../config.js';
import { handleError } from '../helpers.js';
import { currencies, paginationParams } from '../constants.js';

function svc(config: BillingoConfig) {
  return config.mockMode ? MockProductService : ProductService;
}

export function registerProductTools(server: McpServer, config: BillingoConfig) {
  server.registerTool('list_products', {
    description: 'List all products. Returns paginated results.',
    inputSchema: {
      ...paginationParams,
      query: z.string().optional().describe('Search by product name'),
    },
  }, async (params) => handleError(() =>
    svc(config).listProduct(params.page, params.per_page, params.query)
  ));

  server.registerTool('create_product', {
    description: 'Create a new product in the catalog.',
    inputSchema: {
      name: z.string().describe('Product name'),
      unit: z.string().describe('Unit of measure (e.g. óra, db, hónap, kg)'),
      currency: z.enum(currencies).describe('Currency code'),
      vat: z.string().describe('VAT rate (e.g. "27%", "0%", "AAM", "EU")'),
      net_unit_price: z.number().optional().describe('Net unit price'),
      comment: z.string().optional().describe('Product description/comment'),
    },
  }, async (params) => handleError(() =>
    svc(config).createProduct(params as Product)
  ));

  server.registerTool('get_product', {
    description: 'Retrieve details of a specific product by ID.',
    inputSchema: { id: z.number().describe('Product ID') },
  }, async ({ id }) => handleError(() => svc(config).getProduct(id)));

  server.registerTool('update_product', {
    description: 'Update an existing product.',
    inputSchema: {
      id: z.number().describe('Product ID to update'),
      name: z.string().optional().describe('Product name'),
      unit: z.string().optional().describe('Unit of measure'),
      currency: z.enum(currencies).optional().describe('Currency code'),
      vat: z.string().optional().describe('VAT rate'),
      net_unit_price: z.number().optional().describe('Net unit price'),
      comment: z.string().optional().describe('Product description/comment'),
    },
  }, async ({ id, ...data }) => handleError(() =>
    svc(config).updateProduct(id, data as Product)
  ));
}
