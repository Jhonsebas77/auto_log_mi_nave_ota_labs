part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Curva de rendimiento Km/Gal (design_spec: Tanqueos y Consumo).
class PerformanceCurveChart extends StatelessWidget {
  const PerformanceCurveChart({required this.curve, super.key});

  final List<FuelMetricsPoint> curve;

  static const String _explanation =
      'Cada punto es el rendimiento (Km/Gal) logrado entre dos tanqueos '
      'llenos consecutivos. Si la curva sube, tu carro está rindiendo más '
      'por galón; si baja, el consumo empeoró.';

  @override
  Widget build(BuildContext context) {
    if (curve.length < 2) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: BlueprintColors.outlineVariant),
        ),
        child: const Text(
          'Registra al menos 3 tanqueos llenos para ver la curva.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      );
    }

    List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < curve.length; i++)
        FlSpot(i.toDouble(), curve[i].kmPerGallon),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Row(
          children: <Widget>[
            Text('Rendimiento (Km/Gal)', style: AppTextStyles.titleMedium),
            SizedBox(width: 4),
            Tooltip(
              message: _explanation,
              triggerMode: TooltipTriggerMode.tap,
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: BlueprintColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          decoration: BoxDecoration(
            border: Border.all(color: BlueprintColors.outlineVariant),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(drawVerticalLine: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border.fromBorderSide(
                  BorderSide(color: BlueprintColors.outlineVariant),
                ),
              ),
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: BlueprintColors.accentOrange,
                  barWidth: 2,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: BlueprintColors.accentOrange.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
