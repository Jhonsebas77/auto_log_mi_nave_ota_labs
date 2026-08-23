part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Regla de restricción "Pico y Placa" para un día de la semana.
class LicensePlateRestrictionDayRule {
  const LicensePlateRestrictionDayRule({
    required this.dayLabel,
    required this.restrictedLastDigits,
    required this.horarioLabel,
  });

  final String dayLabel;
  final List<int> restrictedLastDigits;
  final String horarioLabel;
}
