part of com.auto_log_mi_nave_ota_labs.app.ui.views;

/// Validadores compartidos por los formularios.

String? _validateRequired(String? v, String message) =>
    (v == null || v.trim().isEmpty) ? message : null;

/// Kilometraje escrito con separador de miles (ver
/// [ThousandsSeparatorInputFormatter]).
String? _validateOdometerText(String? v) =>
    parseGroupedInt(v ?? '') == null ? 'Ingresa el kilometraje.' : null;

/// Monto en COP escrito con separador de miles. Con [allowZero] acepta 0
/// (ej. un mantenimiento cubierto por garantía).
String? _validateCopAmount(String? v, {bool allowZero = false}) {
  int? amount = parseGroupedInt(v ?? '');
  if (amount == null) return 'Ingresa el costo.';
  if (!allowZero && amount <= 0) return 'Debe ser mayor a 0.';
  return null;
}
