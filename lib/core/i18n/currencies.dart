/// Información básica de una divisa soportada por la aplicación.
class CurrencyInfo {
  /// Código ISO 4217 de la divisa (p. ej. `'EUR'`).
  final String code;

  /// Símbolo visual de la divisa (p. ej. `'€'`).
  final String symbol;

  /// Nombre legible de la divisa en español (p. ej. `'Euro'`).
  final String name;

  const CurrencyInfo(this.code, this.symbol, this.name);
}

/// Lista de divisas soportadas en la interfaz de usuario.
///
/// Mantener esta lista aquí (en lugar de generarla dinámicamente) permite
/// referenciarla fácilmente desde el selector de moneda de los ajustes.
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

/// Devuelve la [CurrencyInfo] cuyo [CurrencyInfo.code] coincide con [code].
///
/// Si no se encuentra ninguna coincidencia, devuelve la primera divisa de
/// [kSupportedCurrencies] (EUR) como valor por defecto.
///
/// [code] Código ISO 4217 a buscar (p. ej. `'USD'`).
CurrencyInfo currencyByCode(String code) =>
    kSupportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kSupportedCurrencies.first,
    );
