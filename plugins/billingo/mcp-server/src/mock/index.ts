import type { DocumentInsert, DocumentCancellation, SendDocument, PaymentHistory, Partner, Product, BankAccount, SpendingSave } from '@codingsans/billingo-client';
import { mockDocuments, mockDocumentList } from './fixtures/documents.js';
import { mockPartners, mockPartnerList } from './fixtures/partners.js';
import { mockProducts, mockProductList } from './fixtures/products.js';
import { mockBankAccounts, mockBankAccountList } from './fixtures/bank-accounts.js';
import { mockSpendings, mockSpendingList } from './fixtures/spendings.js';
import { mockOrganization } from './fixtures/organization.js';

let nextId = 100;

function withId<T extends Record<string, unknown>>(data: T): T & { id: number } {
  return { ...data, id: nextId++ };
}

export const MockDocumentService = {
  listDocument: async () => mockDocumentList,
  createDocument: async (requestBody: DocumentInsert) => withId({
    ...(requestBody as unknown as Record<string, unknown>),
    invoice_number: `MOCK-${Date.now()}`,
    invoice_date: new Date().toISOString().split('T')[0],
    cancelled: false,
    payment_status: requestBody.paid ? 'paid' : 'outstanding',
  }),
  getDocument: async (id: number) => mockDocuments.find(d => d.id === id) ?? mockDocuments[0],
  cancelDocument: async (id: number, _requestBody?: DocumentCancellation) => ({
    ...(mockDocuments.find(d => d.id === id) ?? mockDocuments[0]),
    cancelled: true,
    type: 'cancellation',
  }),
  sendDocument: async (_id: number, _requestBody?: SendDocument) => ({ emails: [] as string[] }),
  downloadDocument: async (_id: number) => Buffer.from('mock-pdf-content').toString('base64'),
  getPublicUrl: async (id: number) => ({
    public_url: `https://app.billingo.hu/document/mock/${id}`,
  }),
  updatePayment: async (id: number, requestBody: PaymentHistory[]) => ({
    ...(mockDocuments.find(d => d.id === id) ?? mockDocuments[0]),
    payment_status: 'paid',
    payment_history: requestBody,
  }),
};

export const MockPartnerService = {
  listPartner: async () => mockPartnerList,
  createPartner: async (requestBody: Partner) => ({ ...requestBody, id: nextId++ }),
  getPartner: async (id: number) => mockPartners.find(p => p.id === id) ?? mockPartners[0],
  updatePartner: async (id: number, requestBody: Partner) => ({ id, ...requestBody }),
  deletePartner: async () => undefined,
};

export const MockProductService = {
  listProduct: async () => mockProductList,
  createProduct: async (requestBody: Product) => ({ ...requestBody, id: nextId++ }),
  getProduct: async (id: number) => mockProducts.find(p => p.id === id) ?? mockProducts[0],
  updateProduct: async (id: number, requestBody: Product) => ({ id, ...requestBody }),
  deleteProduct: async () => undefined,
};

export const MockBankAccountService = {
  listBankAccount: async () => mockBankAccountList,
  createBankAccount: async (requestBody: BankAccount) => ({ ...requestBody, id: nextId++ }),
  getBankAccount: async (id: number) => mockBankAccounts.find(b => b.id === id) ?? mockBankAccounts[0],
  updateBankAccount: async (id: number, requestBody: BankAccount) => ({ id, ...requestBody }),
  deleteBankAccount: async () => undefined,
};

export const MockSpendingService = {
  spendingList: async () => mockSpendingList,
  spendingSave: async (requestBody: SpendingSave) => ({ ...(requestBody as unknown as Record<string, unknown>), id: nextId++ }),
  spendingShow: async (id: number) => mockSpendings.find(s => s.id === id) ?? mockSpendings[0],
  spendingUpdate: async (id: number, requestBody: SpendingSave) => ({ id, ...(requestBody as unknown as Record<string, unknown>) }),
  spendingDelete: async () => undefined,
};

export const MockOrganizationService = {
  getOrganizationData: async () => mockOrganization,
};

export const MockCurrencyService = {
  getConversionRate: async (from: string, to: string) => ({
    conversation_rate: from === 'EUR' && to === 'HUF' ? 398.5 : 1,
    from,
    to,
  }),
};

export const MockDocumentBlockService = {
  listDocumentBlock: async () => ({
    data: [
      { id: 1, name: 'Számla', prefix: 'INV', type: 'invoice' },
      { id: 2, name: 'Díjbekérő', prefix: 'PRO', type: 'proforma' },
    ],
    total: 2,
    per_page: 25,
    current_page: 1,
    last_page: 1,
  }),
};

export const MockUtilService = {
  checkTaxNumber: async (taxNumber: string) => ({
    tax_number: taxNumber,
    valid: /^\d{8}-\d-\d{2}$/.test(taxNumber),
    name: 'Mock Cég Kft.',
    address: { country_code: 'HU', post_code: '1011', city: 'Budapest', address: 'Példa utca 1.' },
  }),
  getServerTime: async () => ({ time: new Date().toISOString() }),
};
