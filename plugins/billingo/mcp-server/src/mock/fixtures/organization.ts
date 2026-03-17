export const mockOrganization = {
  id: 1,
  name: 'Teszt Fejlesztő Kft.',
  tax_number: '99887766-2-42',
  bank_account: {
    id: 1,
    name: 'OTP HUF számla',
    account_number: '11773016-01234567-00000000',
    currency: 'HUF',
  },
  address: {
    country_code: 'HU',
    post_code: '1052',
    city: 'Budapest',
    address: 'Váci utca 12.',
  },
  small_taxpayer: false,
  ev: false,
};
