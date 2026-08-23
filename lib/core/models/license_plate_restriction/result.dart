part of com.auto_log_mi_nave_ota_labs.app.core.models;

class LicensePlateRestrictionResult {
  const LicensePlateRestrictionResult({
    required this.isRestrictedToday,
    required this.ruleApplied,
    required this.scheduleIsStale,
    required this.plateDigit,
    required this.nextFreeDayLabel,
    required this.schedule,
  });

  final bool isRestrictedToday;
  final LicensePlateRestrictionDayRule? ruleApplied;
  final bool scheduleIsStale;

  /// Último dígito de la placa consultada, o `null` si la placa no contiene
  /// dígitos.
  final int? plateDigit;

  /// Próximo día en que el vehículo puede circular sin restricción:
  /// "Hoy", "Mañana" o el nombre del día (ej. "Miércoles").
  final String nextFreeDayLabel;

  /// Rotación vigente usada para calcular este resultado. Se expone
  /// completa para que la UI pueda dibujar la tabla de todos los días con
  /// restricción, no solo el de hoy.
  final LicensePlateRestrictionSchedule schedule;
}
