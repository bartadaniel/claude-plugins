export const mockBankAccounts = [
  {
    id: 1,
    name: 'OTP HUF számla',
    account_number: '11773016-01234567-00000000',
    account_number_iban: 'HU42 1177 3016 0123 4567 0000 0000',
    swift: 'OTPVHUHB',
    currency: 'HUF',
  },
  {
    id: 2,
    name: 'Wise EUR számla',
    account_number: 'BE12 3456 7890 1234',
    account_number_iban: 'BE12 3456 7890 1234',
    swift: 'TRWIBEB1XXX',
    currency: 'EUR',
  },
];

export const mockBankAccountList = {
  data: mockBankAccounts,
  total: mockBankAccounts.length,
  per_page: 25,
  current_page: 1,
  last_page: 1,
};
