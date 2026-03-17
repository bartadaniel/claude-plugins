export const mockProducts = [
  {
    id: 1,
    name: 'Webfejlesztés',
    comment: 'Egyedi weboldal fejlesztés',
    currency: 'HUF',
    vat: '27%',
    net_unit_price: 25000,
    unit: 'óra',
  },
  {
    id: 2,
    name: 'Konzultáció',
    comment: 'IT tanácsadás',
    currency: 'HUF',
    vat: '27%',
    net_unit_price: 15000,
    unit: 'óra',
  },
  {
    id: 3,
    name: 'Hosting szolgáltatás',
    comment: 'Havi szerver üzemeltetés',
    currency: 'EUR',
    vat: '27%',
    net_unit_price: 30,
    unit: 'hónap',
  },
];

export const mockProductList = {
  data: mockProducts,
  total: mockProducts.length,
  per_page: 25,
  current_page: 1,
  last_page: 1,
};
