class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  const CurrencyInfo(this.code, this.symbol, this.name);
}

const List<CurrencyInfo> kSupportedCurrencies = [
  CurrencyInfo('EUR', '€', 'Euro'),
  CurrencyInfo('USD', '\$', 'Dólar estadounidense'),
  CurrencyInfo('GBP', '£', 'Libra esterlina'),
  CurrencyInfo('JPY', '¥', 'Yen japonés'),
  CurrencyInfo('CNY', '¥', 'Yuan chino'),
  CurrencyInfo('MXN', 'MX\$', 'Peso mexicano'),
  CurrencyInfo('ARS', '\$', 'Peso argentino'),
  CurrencyInfo('COP', 'COL\$', 'Peso colombiano'),
  CurrencyInfo('CLP', 'CLP\$', 'Peso chileno'),
  CurrencyInfo('BRL', 'R\$', 'Real brasileño'),
  CurrencyInfo('CHF', 'CHF', 'Franco suizo'),
  CurrencyInfo('CAD', 'CA\$', 'Dólar canadiense'),
  CurrencyInfo('AUD', 'AU\$', 'Dólar australiano'),
  CurrencyInfo('SEK', 'kr', 'Corona sueca'),
  CurrencyInfo('NOK', 'kr', 'Corona noruega'),
  CurrencyInfo('DKK', 'kr', 'Corona danesa'),
  CurrencyInfo('PLN', 'zł', 'Złoty polaco'),
  CurrencyInfo('CZK', 'Kč', 'Corona checa'),
];

CurrencyInfo currencyByCode(String code) =>
    kSupportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kSupportedCurrencies.first,
    );
