part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

class KpiCardsRow extends StatelessWidget {
  const KpiCardsRow({required this.metrics, super.key});

  final FuelMetrics metrics;

  @override
  Widget build(BuildContext context) {
    List<KpiCard> cards = <KpiCard>[
      KpiCard(
        label: 'Rendimiento prom.',
        value: metrics.averageKmPerGallon == null
            ? '—'
            : '${metrics.averageKmPerGallon!.toStringAsFixed(1)} km/gal',
      ),
      KpiCard(
        label: 'Costo por km',
        value: metrics.costPerKm == null
            ? '—'
            : copFormat.format(metrics.costPerKm),
      ),
      KpiCard(
        label: 'Total gastado',
        value: copFormat.format(metrics.totalSpent),
      ),
      KpiCard(
        label: 'Gastado ${monthsInSpanish[DateTime.now().month - 1]}',
        value: copFormat.format(metrics.currentMonthSpent),
      ),
      if (metrics.estimatedRangeKm != null)
        KpiCard(
          label: 'Autonomía est.',
          value: '${metrics.estimatedRangeKm!.toStringAsFixed(0)} km',
        ),
    ];
    List<Widget> rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 12));
      rows.add(
        _row(cards.sublist(i, i + 2 > cards.length ? cards.length : i + 2)),
      );
    }
    return Column(children: rows);
  }

  Widget _row(List<KpiCard> cards) => Row(
    children: <Widget>[
      for (int i = 0; i < cards.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(width: 12),
        Expanded(child: cards[i]),
      ],
    ],
  );
}
