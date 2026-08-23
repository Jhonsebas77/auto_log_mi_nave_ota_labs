part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Tabla completa de los días con restricción vehicular ("pico y placa"),
/// abierta desde [LicensePlateRestrictionCard] ("Ver calendario del mes").
///
/// La rotación vigente solo define reglas por día de la semana (no por
/// fecha calendario puntual), así que esta vista tabula los 7 días de la
/// semana en vez de un mes completo — es la representación fiel de los
/// datos que existen hoy en [LicensePlateRestrictionSchedule].
class LicensePlateRestrictionScheduleSheet extends StatelessWidget {
  const LicensePlateRestrictionScheduleSheet({
    required this.schedule,
    required this.plateDigit,
    super.key,
  });

  final LicensePlateRestrictionSchedule schedule;
  final int? plateDigit;

  static const List<int> _weekdaysInOrder = <int>[
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  @override
  Widget build(BuildContext context) {
    int todayWeekday = DateTime.now().weekday;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BlueprintColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Días con restricción · ${schedule.cityLabel}',
              style: AppTextStyles.titleMedium.copyWith(
                color: BlueprintColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vigente ${schedule.effectivePeriodLabel}',
              style: AppTextStyles.bodySmall.copyWith(
                color: BlueprintColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            for (int weekday in _weekdaysInOrder) ...<Widget>[
              _ScheduleDayRow(
                dayLabel: weekdayLabel(weekday),
                rule: schedule.rulesByIsoWeekday[weekday],
                plateDigit: plateDigit,
                isToday: weekday == todayWeekday,
              ),
              if (weekday != _weekdaysInOrder.last)
                const Divider(color: BlueprintColors.outlineVariant, height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleDayRow extends StatelessWidget {
  const _ScheduleDayRow({
    required this.dayLabel,
    required this.rule,
    required this.plateDigit,
    required this.isToday,
  });

  final String dayLabel;
  final LicensePlateRestrictionDayRule? rule;
  final int? plateDigit;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    bool restrictsUser =
        rule != null &&
        plateDigit != null &&
        rule!.restrictedLastDigits.contains(plateDigit);
    Color dayColor = isToday
        ? BlueprintColors.accentOrange
        : BlueprintColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  dayLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: dayColor,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (isToday) ...<Widget>[
                  const SizedBox(height: 4),
                  const _DayFlagChip(
                    label: 'HOY',
                    color: BlueprintColors.accentOrange,
                  ),
                ],
                if (restrictsUser) ...<Widget>[
                  const SizedBox(height: 4),
                  const _DayFlagChip(
                    label: 'TU DÍA',
                    color: BlueprintColors.danger,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: rule == null
                ? Text(
                    'Sin restricción',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: BlueprintColors.textMuted,
                    ),
                  )
                : Text(
                    '[${rule!.restrictedLastDigits.join(", ")}] · '
                    '${rule!.horarioLabel}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: restrictsUser
                          ? BlueprintColors.danger
                          : BlueprintColors.textMuted,
                    ),
                  ),
          ),
          if (restrictsUser)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.block, size: 16, color: BlueprintColors.danger),
            ),
        ],
      ),
    );
  }
}

/// Etiqueta pequeña ("HOY" / "TU DÍA") para distinguir sin ambigüedad la
/// fila del día de hoy de la fila que realmente restringe la placa del
/// usuario — antes solo se diferenciaban por color, lo que se confundía
/// fácilmente.
class _DayFlagChip extends StatelessWidget {
  const _DayFlagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.6)),
    ),
    child: Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
  );
}
