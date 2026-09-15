part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// "Vence en N días" — countdown de vencimiento de un LegalDocument, con
/// color según qué tan cerca esté el vencimiento.
class CountdownChip extends StatelessWidget {
  const CountdownChip({
    required this.expirationDate,
    required this.now,
    super.key,
  });

  final DateTime expirationDate;
  final DateTime now;

  int get _daysLeft =>
      expirationDate.difference(DateTime(now.year, now.month, now.day)).inDays;

  TrafficLightLevel get _level {
    int days = _daysLeft;
    if (days < 0) return TrafficLightLevel.danger;
    if (days <= 15) return TrafficLightLevel.warning;
    return TrafficLightLevel.ok;
  }

  String get _label {
    int days = _daysLeft;
    if (days == 0) return 'Vence hoy';
    if (days < 0) return 'Vencido hace ${_yearsOrDays(-days)}';
    return 'Vence en ${_yearsOrDays(days)}';
  }

  /// Más de 365 días (un año) se muestran como años en vez de días, para
  /// que un vencimiento lejano no se lea como "en 800d".
  String _yearsOrDays(int days) {
    if (days <= 365) return '${days}d';
    int years = days ~/ 365;
    return years == 1 ? '1 año' : '$years años';
  }

  @override
  Widget build(BuildContext context) =>
      StatusTrafficLight(label: _label, level: _level);
}
