part of com.auto_log_mi_nave_ota_labs.app.core.constants;

/// Tabla vigente para Medellín y el Valle de Aburrá, segundo semestre 2026.
/// Fuente: claude/pico_y_placa_Medellin.md. Actualizar cada 6 meses.
///
/// Cada regla cubre **dos dígitos** (no un rango inclusivo): los 5 días
/// cubren los 10 dígitos sin solaparse (5,8 / 1,4 / 0,2 / 3,6 / 7,9 =
/// {0..9} exactamente una vez cada uno), que es como opera realmente el
/// pico y placa en Medellín.
final LicensePlateRestrictionSchedule picoYPlacaMedellin2026S2 =
    LicensePlateRestrictionSchedule(
      cityLabel: 'Medellín y Valle de Aburrá',
      effectivePeriodLabel: '2026-2 · Segundo semestre 2026',
      effectiveFrom: DateTime.utc(2026, 7, 1),
      effectiveTo: DateTime.utc(2026, 12, 31),
      rulesByIsoWeekday: <int, LicensePlateRestrictionDayRule>{
        DateTime.monday: const LicensePlateRestrictionDayRule(
          dayLabel: 'Lunes',
          restrictedLastDigits: <int>[5, 8],
          horarioLabel: '5:00 a.m. - 8:00 p.m.',
        ),
        DateTime.tuesday: const LicensePlateRestrictionDayRule(
          dayLabel: 'Martes',
          restrictedLastDigits: <int>[1, 4],
          horarioLabel: '5:00 a.m. - 8:00 p.m.',
        ),
        DateTime.wednesday: const LicensePlateRestrictionDayRule(
          dayLabel: 'Miércoles',
          restrictedLastDigits: <int>[0, 2],
          horarioLabel: '5:00 a.m. - 8:00 p.m.',
        ),
        DateTime.thursday: const LicensePlateRestrictionDayRule(
          dayLabel: 'Jueves',
          restrictedLastDigits: <int>[3, 6],
          horarioLabel: '5:00 a.m. - 8:00 p.m.',
        ),
        DateTime.friday: const LicensePlateRestrictionDayRule(
          dayLabel: 'Viernes',
          restrictedLastDigits: <int>[7, 9],
          horarioLabel: '5:00 a.m. - 8:00 p.m.',
        ),
      },
      // Sábado y domingo intencionalmente ausentes del mapa == sin restricción.
    );

/// Nombres de día en español indexados por `DateTime.weekday` (1 = lunes,
/// 7 = domingo), incluyendo sábado y domingo aunque no tengan regla — se
/// usan para etiquetar el próximo día libre y la tabla completa de días.
const List<String> spanishWeekdayLabels = <String>[
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

String weekdayLabel(int isoWeekday) => spanishWeekdayLabels[isoWeekday - 1];

int? lastPlateDigit(String plate) {
  String digits = plate.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.parse(digits[digits.length - 1]);
}

/// Recorre los próximos 7 días (incluido [today]) buscando el primero en
/// que [digit] no esté restringido, y lo etiqueta como "Hoy", "Mañana" o el
/// nombre del día. Si [digit] es `null` (placa sin dígitos) no hay nada que
/// calcular, así que se asume que hoy es libre.
String _nextFreeDayLabel({
  required LicensePlateRestrictionSchedule schedule,
  required int? digit,
  required DateTime today,
}) {
  if (digit == null) return 'Hoy';
  for (int offset = 0; offset < 7; offset++) {
    DateTime day = today.add(Duration(days: offset));
    LicensePlateRestrictionDayRule? rule =
        schedule.rulesByIsoWeekday[day.weekday];
    bool restrictedThatDay =
        rule != null && rule.restrictedLastDigits.contains(digit);
    if (!restrictedThatDay) {
      return switch (offset) {
        0 => 'Hoy',
        1 => 'Mañana',
        _ => weekdayLabel(day.weekday),
      };
    }
  }
  // No debería alcanzarse: ningún dígito está restringido más de un día
  // por semana en esta rotación.
  return 'Hoy';
}

/// [schedule] no puede tener un valor por defecto constante en la firma
/// (LicensePlateRestrictionSchedule no es const-constructible
/// por sus campos DateTime),
/// así que se resuelve el fallback dentro del cuerpo de la función.
LicensePlateRestrictionResult isVehicleRestrictedToday({
  required String licensePlate,
  required DateTime today,
  LicensePlateRestrictionSchedule? schedule,
}) {
  LicensePlateRestrictionSchedule effectiveSchedule =
      schedule ?? picoYPlacaMedellin2026S2;
  LicensePlateRestrictionDayRule? rule =
      effectiveSchedule.rulesByIsoWeekday[today.weekday];
  int? digit = lastPlateDigit(licensePlate);
  bool restricted =
      rule != null &&
      digit != null &&
      rule.restrictedLastDigits.contains(digit);
  bool stale = today.isAfter(effectiveSchedule.effectiveTo);
  return LicensePlateRestrictionResult(
    isRestrictedToday: restricted,
    ruleApplied: rule,
    scheduleIsStale: stale,
    plateDigit: digit,
    nextFreeDayLabel: _nextFreeDayLabel(
      schedule: effectiveSchedule,
      digit: digit,
      today: today,
    ),
    schedule: effectiveSchedule,
  );
}
