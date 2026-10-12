part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Tarjeta resumen de "Pico y Placa" para el dashboard: estado de hoy,
/// franja horaria, dígito de la placa y próximo día libre para circular,
/// con acceso a la tabla completa de días con restricción.
class LicensePlateRestrictionCard extends StatelessWidget {
  const LicensePlateRestrictionCard({
    required this.result,
    required this.licensePlate,
    super.key,
  });

  final LicensePlateRestrictionResult result;
  final String licensePlate;

  @override
  Widget build(BuildContext context) {
    bool restricted = result.isRestrictedToday;
    Color accent = restricted
        ? BlueprintColors.danger
        : BlueprintColors.successGreen;
    LicensePlateRestrictionDayRule? rule = result.ruleApplied;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BlueprintColors.surfaceContainerLow,
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PICO Y PLACA · ${result.schedule.cityLabel.toUpperCase()}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: BlueprintColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            restricted ? 'No puedes circular hoy' : 'Puedes circular hoy',
            style: AppTextStyles.headlineMedium.copyWith(color: accent),
          ),
          const SizedBox(height: 8),
          Text(
            _description(rule, result.plateDigit),
            style: AppTextStyles.bodyMedium.copyWith(
              color: BlueprintColors.textMuted,
            ),
          ),
          if (result.scheduleIsStale) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Verifica vigencia — este calendario pudo haber rotado.',
              style: AppTextStyles.bodySmall.copyWith(
                color: BlueprintColors.warning,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: BlueprintColors.outlineVariant, height: 1),
          const SizedBox(height: 16),
          _PicoYPlacaMetric(label: 'FRANJA', value: rule?.horarioLabel ?? '-'),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _PicoYPlacaMetric(
                  label: 'DÍGITO',
                  value: result.plateDigit?.toString() ?? '—',
                ),
              ),
              Expanded(
                child: _PicoYPlacaMetric(
                  label: 'PRÓXIMO DÍA LIBRE',
                  value: result.nextFreeDayLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: BlueprintColors.textPrimary,
                side: const BorderSide(color: BlueprintColors.outline),
                shape: kSharpShape,
              ),
              onPressed: () => _showScheduleSheet(context),
              child: const Text('Ver calendario del mes'),
            ),
          ),
        ],
      ),
    );
  }

  String _description(LicensePlateRestrictionDayRule? rule, int? digit) {
    if (rule == null) {
      return 'Hoy no aplica restricción de pico y placa.';
    }
    String digits = _joinDigits(rule.restrictedLastDigits);
    String digitPhrase = digit != null ? ' Tu dígito es $digit.' : '';
    return 'Los ${rule.dayLabel.toLowerCase()} se restringen los dígitos '
        '$digits.$digitPhrase';
  }

  String _joinDigits(List<int> digits) {
    if (digits.length <= 1) return digits.join();
    return '${digits.sublist(0, digits.length - 1).join(", ")} y '
        '${digits.last}';
  }

  void _showScheduleSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BlueprintColors.surfaceContainerLow,
      isScrollControlled: true,
      shape: kSharpShape,
      builder: (BuildContext context) => LicensePlateRestrictionScheduleSheet(
        schedule: result.schedule,
        plateDigit: result.plateDigit,
      ),
    );
  }
}

class _PicoYPlacaMetric extends StatelessWidget {
  const _PicoYPlacaMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: BlueprintColors.textMuted,
          letterSpacing: 0.6,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: AppTextStyles.titleMedium.copyWith(
          color: BlueprintColors.textPrimary,
        ),
      ),
    ],
  );
}
