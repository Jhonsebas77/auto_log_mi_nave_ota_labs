part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Curva de rendimiento Km/Gal (design_spec: Tanqueos y Consumo).
class PerformanceCurveChart extends StatelessWidget {
  const PerformanceCurveChart({required this.curve, super.key});

  final List<FuelMetricsPoint> curve;

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
          'Registra al menos 2 tanqueos llenos para ver la curva.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      );
    }

    List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < curve.length; i++)
        FlSpot(i.toDouble(), curve[i].kmPerGallon),
    ];

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(color: BlueprintColors.outlineVariant),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(drawVerticalLine: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                color: BlueprintColors.accentOrange.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
