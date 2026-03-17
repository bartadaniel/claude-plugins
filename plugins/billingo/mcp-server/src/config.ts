import { OpenAPI } from '@codingsans/billingo-client';

export interface BillingoConfig {
  apiKey: string | undefined;
  mockMode: boolean;
}

export function initConfig(): BillingoConfig {
  const apiKey = process.env.BILLINGO_API_KEY;
  const mockMode = process.env.BILLINGO_MOCK === 'true' || !apiKey;

  if (apiKey && !mockMode) {
    OpenAPI.HEADERS = { 'X-API-KEY': apiKey };
  }

  return { apiKey, mockMode };
}
