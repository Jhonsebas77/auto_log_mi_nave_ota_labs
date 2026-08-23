part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class KpiCardsRow extends StatelessWidget {
  const KpiCardsRow({required this.metrics, super.key});

  final FuelMetrics metrics;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: KpiCard(
          label: 'Rendimiento prom.',
          value: metrics.averageKmPerGallon == null
              ? '—'
              : '${metrics.averageKmPerGallon!.toStringAsFixed(1)} km/gal',
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: KpiCard(
          label: 'Costo por km',
          value: metrics.costPerKm == null
              ? '—'
              : copFormat.format(metrics.costPerKm),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: KpiCard(
          label: 'Total gastado',
          value: copFormat.format(metrics.totalSpent),
        ),
      ),
    ],
  );
}
