part of com.auto_log_mi_nave_ota_labs.app.core.utils;

/// Pesos colombianos con el símbolo adelante: "$ 240.000". El patrón por
/// defecto de `es_CO` en intl lo pone al final ("240.000 $"); el locale se
/// mantiene para el separador de miles (punto). El espacio es no separable
/// (U+00A0) para que el "$" nunca quede solo al final de una línea.
final NumberFormat copFormat = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
  customPattern: '\u00A4\u00A0#,##0',
);

/// Enteros con separador de miles colombiano (1.240), p. ej. kilómetros.
final NumberFormat integerFormat = NumberFormat.decimalPattern('es_CO');

/// Fecha corta d/m/aaaa ("5/3/2026"), la usada en formularios y listas.
String formatShortDate(DateTime date) =>
    '${date.day}/${date.month}/${date.year}';

/// Decimal escrito por el usuario. Acepta coma decimal ("12,5"), que es lo
/// habitual en Colombia, además del punto.
double? parseDecimal(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

/// Entero escrito con separador de miles ("1.240.000"), como lo deja
/// `ThousandsSeparatorInputFormatter`.
int? parseGroupedInt(String text) =>
    int.tryParse(text.trim().replaceAll('.', ''));

/// Texto recortado, o `null` si quedó vacío (campos opcionales).
String? trimmedOrNull(String text) => text.trim().isEmpty ? null : text.trim();
