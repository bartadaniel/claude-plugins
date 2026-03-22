import { z } from 'zod';

export const paymentMethods = ['aruhitel', 'bankcard', 'barion', 'barter', 'cash', 'cash_on_delivery', 'coupon', 'elore_utalas', 'ep_kartya', 'kompenzacio', 'levonas', 'online_bankcard', 'other', 'paylike', 'payoneer', 'paypal', 'paypal_utolag', 'payu', 'pick_pack_pont', 'postai_csekk', 'postautalvany', 'skrill', 'szep_card', 'transferwise', 'upwork', 'utalvany', 'valto', 'wire_transfer'] as const;

export const spendingPaymentMethods = paymentMethods;

export const currencies = ['AED', 'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR', 'GBP', 'HKD', 'HRK', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'RSD', 'RUB', 'SEK', 'SGD', 'THB', 'TRY', 'UAH', 'USD', 'ZAR'] as const;

export const languages = ['de', 'en', 'fr', 'hr', 'hu', 'it', 'ro', 'sk', 'us'] as const;

export const documentInsertTypes = ['advance', 'draft', 'invoice', 'proforma'] as const;

export const documentTypes = ['advance', 'cancellation', 'cert_of_completion', 'd_cert_of_completion', 'dossier', 'draft', 'draft_offer', 'draft_order_form', 'draft_waybill', 'invoice', 'modification', 'offer', 'order_form', 'proforma', 'receipt', 'receipt_cancellation', 'waybill'] as const;

export const paymentStatuses = ['expired', 'none', 'outstanding', 'paid', 'partially_paid'] as const;

export const categories = ['advertisement', 'development', 'education_and_trainings', 'other', 'overheads', 'service', 'software', 'stock', 'tangible_assets'] as const;

export const partnerTaxTypes = ['', 'FOREIGN', 'HAS_TAX_NUMBER', 'NO_TAX_NUMBER'] as const;

export const paginationParams = {
  page: z.number().optional().describe('Page number (default: 1)'),
  per_page: z.number().min(1).max(100).optional().describe('Items per page (default: 25, max: 100)'),
};
