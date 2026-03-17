import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { registerDocumentTools } from './documents.js';
import { registerPartnerTools } from './partners.js';
import { registerProductTools } from './products.js';
import { registerSpendingTools } from './spendings.js';
import { registerBankAccountTools } from './bank-accounts.js';
import { registerUtilTools } from './utils.js';
import type { BillingoConfig } from '../config.js';

export function registerAllTools(server: McpServer, config: BillingoConfig) {
  registerDocumentTools(server, config);
  registerPartnerTools(server, config);
  registerProductTools(server, config);
  registerSpendingTools(server, config);
  registerBankAccountTools(server, config);
  registerUtilTools(server, config);
}
