export const mockPartners = [
  {
    id: 1,
    name: 'Teszt Kft.',
    address: {
      country_code: 'HU',
      post_code: '1011',
      city: 'Budapest',
      address: 'Fő utca 1.',
    },
    emails: ['info@tesztkft.hu'],
    taxcode: '12345678-2-41',
    tax_type: 'HAS_TAX_NUMBER',
    phone: '+36 1 234 5678',
  },
  {
    id: 2,
    name: 'Példa Bt.',
    address: {
      country_code: 'HU',
      post_code: '6720',
      city: 'Szeged',
      address: 'Kárász utca 10.',
    },
    emails: ['hello@peldabt.hu'],
    taxcode: '87654321-1-06',
    tax_type: 'HAS_TAX_NUMBER',
    phone: '+36 62 123 456',
  },
  {
    id: 3,
    name: 'Minta Zrt.',
    address: {
      country_code: 'HU',
      post_code: '4025',
      city: 'Debrecen',
      address: 'Piac utca 5.',
    },
    emails: ['contact@mintazrt.hu'],
    taxcode: '11223344-2-09',
    tax_type: 'HAS_TAX_NUMBER',
  },
];

export const mockPartnerList = {
  data: mockPartners,
  total: mockPartners.length,
  per_page: 25,
  current_page: 1,
  last_page: 1,
};
