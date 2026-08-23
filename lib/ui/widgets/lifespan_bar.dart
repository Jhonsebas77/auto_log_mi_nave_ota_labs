part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Barra de vida útil de un componente de mantenimiento (Aceite/Llantas/Frenos).
/// [progress] en [0, +inf): 1.0 = 100% del intervalo consumido (vencido).
class LifespanBar extends StatelessWidget {
  const LifespanBar({required this.label, required this.progress, super.key});

  final String label;
  final double progress;

  Color get _color {
    if (progress >= 1.0) return BlueprintColors.danger;
    if (progress >= 0.8) return BlueprintColors.warning;
    return BlueprintColors.successGreen;
  }

  @override
  Widget build(BuildContext context) {
    double clamped = progress.clamp(0.0, 1.0);
    String percentLabel =
        '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: AppTextStyles.bodyMedium),
            Text(
              progress >= 1.0 ? 'Vencido ($percentLabel)' : percentLabel,
              style: AppTextStyles.bodySmall.copyWith(color: _color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: <Widget>[
            Container(height: 8, color: BlueprintColors.outlineVariant),
            FractionallySizedBox(
              widthFactor: clamped,
              child: Container(height: 8, color: _color),
            ),
          ],
        ),
      ],
    );
  }
}
