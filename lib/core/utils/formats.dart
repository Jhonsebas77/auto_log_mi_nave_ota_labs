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
