part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Una rotación completa, vigente para un período explícito. El período
/// vigente permite detectar en la UI cuándo la tabla quedó desactualizada,
/// ya que la restricción rota cada 6 meses en Medellín.
///
/// effectiveFrom/effectiveTo se guardan como DateTime (no compile-time
/// constantes, ya que ningún constructor de DateTime lo es), por lo que este
/// objeto y su instancia por defecto NO pueden ser `const` — son `final`.
class LicensePlateRestrictionSchedule {
  LicensePlateRestrictionSchedule({
    required this.cityLabel,
    required this.effectivePeriodLabel,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.rulesByIsoWeekday,
  });

  final String cityLabel;
  final String effectivePeriodLabel;
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final Map<int, LicensePlateRestrictionDayRule> rulesByIsoWeekday;
}
