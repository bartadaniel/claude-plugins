import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { DocumentService } from '@codingsans/billingo-client';
import type { DocumentInsert, DocumentCancellation, SendDocument, PaymentHistory } from '@codingsans/billingo-client';
import { MockDocumentService } from '../mock/index.js';
import type { BillingoConfig } from '../config.js';
import { handleError } from '../helpers.js';
import { paymentMethods, currencies, languages, documentInsertTypes, documentTypes, paymentStatuses, paginationParams } from '../constants.js';

function svc(config: BillingoConfig) {
  return config.mockMode ? MockDocumentService : DocumentService;
}

export function registerDocumentTools(server: McpServer, config: BillingoConfig) {
  server.registerTool('list_documents', {
    description: 'List invoices/documents with optional filters. Returns paginated results sorted by creation date.',
    inputSchema: {
      ...paginationParams,
      partner_id: z.number().optional().describe('Filter by partner ID'),
      payment_method: z.enum(paymentMethods).optional().describe('Filter by payment method'),
      payment_status: z.enum(paymentStatuses).optional().describe('Filter by payment status'),
      start_date: z.string().optional().describe('Filter from date (YYYY-MM-DD)'),
      end_date: z.string().optional().describe('Filter to date (YYYY-MM-DD)'),
      type: z.enum(documentTypes).optional().describe('Filter by document type'),
      query: z.string().optional().describe('Search query string'),
    },
  }, async (params) => handleError(() =>
    svc(config).listDocument(
      params.page, params.per_page, undefined, params.partner_id,
      params.payment_method as any, params.payment_status as any,
      params.start_date, params.end_date,
      undefined, undefined, undefined, undefined,
      params.type as any, params.query
    )
  ));

  server.registerTool('create_document', {
    description: 'Create a new invoice, proforma, advance, or draft document.',
    inputSchema: {
      partner_id: z.number().describe('Partner (client) ID'),
      block_id: z.number().describe('Document block (numbering sequence) ID'),
      type: z.enum(documentInsertTypes).describe('Document type: invoice, proforma, advance, or draft'),
      fulfillment_date: z.string().describe('Fulfillment date (YYYY-MM-DD)'),
      due_date: z.string().describe('Payment due date (YYYY-MM-DD)'),
      payment_method: z.enum(paymentMethods).describe('Payment method'),
      language: z.enum(languages).describe('Document language'),
      currency: z.enum(currencies).describe('Currency code'),
      items: z.array(z.union([
        z.object({
          product_id: z.number().describe('Existing product ID'),
          quantity: z.number().describe('Quantity'),
          comment: z.string().optional(),
        }),
        z.object({
          name: z.string().describe('Item name'),
          unit_price: z.number().describe('Net unit price'),
          unit_price_type: z.enum(['gross', 'net']).describe('Whether unit_price is gross or net'),
          quantity: z.number().describe('Quantity'),
          unit: z.string().describe('Unit of measure (e.g. óra, db, hónap)'),
          vat: z.string().describe('VAT rate (e.g. "27%", "0%", "AAM", "EU")'),
          comment: z.string().optional(),
        }),
      ])).describe('Line items - either reference product_id or provide inline item data'),
      bank_account_id: z.number().optional().describe('Bank account ID'),
      electronic: z.boolean().optional().describe('Electronic invoice (default: false)'),
      paid: z.boolean().optional().describe('Mark as paid immediately'),
      comment: z.string().optional().describe('Invoice comment'),
      conversion_rate: z.number().optional().describe('Currency conversion rate (required for non-HUF)'),
    },
  }, async (params) => handleError(() =>
    svc(config).createDocument(params as DocumentInsert)
  ));

  server.registerTool('get_document', {
    description: 'Retrieve details of a specific document/invoice by ID.',
    inputSchema: { id: z.number().describe('Document ID') },
  }, async ({ id }) => handleError(() => svc(config).getDocument(id)));

  server.registerTool('cancel_document', {
    description: 'Cancel (storno) a document. Creates a cancellation document.',
    inputSchema: {
      id: z.number().describe('Document ID to cancel'),
      cancellation_reason: z.string().optional().describe('Reason for cancellation'),
      cancellation_recipients: z.string().optional().describe('Comma-separated email addresses to notify'),
    },
  }, async ({ id, cancellation_reason, cancellation_recipients }) => handleError(() => {
    const body: DocumentCancellation = {};
    if (cancellation_reason) body.cancellation_reason = cancellation_reason;
    if (cancellation_recipients) body.cancellation_recipients = cancellation_recipients;
    return svc(config).cancelDocument(id, body);
  }));

  server.registerTool('send_document', {
    description: 'Send a document/invoice via email.',
    inputSchema: {
      id: z.number().describe('Document ID to send'),
      emails: z.array(z.string()).optional().describe('Email addresses to send to (uses partner emails if omitted)'),
    },
  }, async ({ id, emails }) => handleError(() => {
    const body: SendDocument | undefined = emails ? { emails } : undefined;
    return svc(config).sendDocument(id, body);
  }));

  server.registerTool('download_document', {
    description: 'Download a document as PDF. Returns base64-encoded PDF content.',
    inputSchema: { id: z.number().describe('Document ID to download') },
  }, async ({ id }) => handleError(async () => {
    const result = await svc(config).downloadDocument(id);
    return `PDF downloaded for document ${id}. Base64 content length: ${String(result).length} chars.`;
  }));

  server.registerTool('get_document_public_url', {
    description: 'Get a public shareable URL for a document.',
    inputSchema: { id: z.number().describe('Document ID') },
  }, async ({ id }) => handleError(() => svc(config).getPublicUrl(id)));

  server.registerTool('update_document_payment', {
    description: 'Record payment(s) on a document. Replaces existing payment history.',
    inputSchema: {
      id: z.number().describe('Document ID'),
      payments: z.array(z.object({
        date: z.string().describe('Payment date (YYYY-MM-DD)'),
        price: z.number().describe('Payment amount'),
        payment_method: z.enum(paymentMethods).describe('Payment method'),
      })).describe('Array of payment records'),
    },
  }, async ({ id, payments }) => handleError(() =>
    svc(config).updatePayment(id, payments as PaymentHistory[])
  ));
}
