import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { BankAccountService } from '@codingsans/billingo-client';
import type { BankAccount } from '@codingsans/billingo-client';
import { MockBankAccountService } from '../mock/index.js';
import type { BillingoConfig } from '../config.js';
import { handleError } from '../helpers.js';
import { currencies, paginationParams } from '../constants.js';

function svc(config: BillingoConfig) {
  return config.mockMode ? MockBankAccountService : BankAccountService;
}

export function registerBankAccountTools(server: McpServer, config: BillingoConfig) {
  server.registerTool('list_bank_accounts', {
    description: 'List all bank accounts.',
    inputSchema: { ...paginationParams },
  }, async (params) => handleError(() =>
    svc(config).listBankAccount(params.page, params.per_page)
  ));

  server.registerTool('create_bank_account', {
    description: 'Create a new bank account.',
    inputSchema: {
      name: z.string().describe('Account name (e.g. "OTP HUF számla")'),
      account_number: z.string().describe('Account number'),
      currency: z.enum(currencies).describe('Currency code'),
      account_number_iban: z.string().optional().describe('IBAN'),
      swift: z.string().optional().describe('SWIFT/BIC code'),
    },
  }, async (params) => handleError(() =>
    svc(config).createBankAccount(params as BankAccount)
  ));
}
