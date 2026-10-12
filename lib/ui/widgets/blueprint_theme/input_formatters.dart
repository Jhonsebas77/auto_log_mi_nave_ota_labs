part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Enteros con separador de miles mientras se escribe ("1240000" →
/// "1.240.000"), para montos en COP y kilómetros. Se leen de vuelta con
/// [parseGroupedInt].
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter({this.maxDigits = 12});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return TextEditingValue.empty;
    if (digits.length > maxDigits) return oldValue;
    String formatted = integerFormat.format(int.parse(digits));
    // El cursor se conserva contando desde el final: los puntos que se
    // agregan/quitan siempre quedan a su izquierda.
    int fromEnd = newValue.text.length - newValue.selection.extentOffset;
    int offset = (formatted.length - fromEnd).clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Solo dígitos y un separador decimal (coma o punto), ej. galones.
final TextInputFormatter decimalInputFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*'));
