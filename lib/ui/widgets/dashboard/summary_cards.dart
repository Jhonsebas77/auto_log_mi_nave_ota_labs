part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Resumen de vida útil (Aceite/Llantas/Frenos) en el dashboard. Mismas
/// barras que el tab Taller; [onViewAll] lleva a ese tab.
class MaintenanceSummaryCard extends StatelessWidget {
  const MaintenanceSummaryCard({
    required this.statuses,
    required this.onViewAll,
    super.key,
  });

  final List<LifespanStatus> statuses;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => DashboardSectionCard(
    title: 'VIDA ÚTIL',
    icon: Icons.build_outlined,
    actionLabel: 'VER TALLER',
    onAction: onViewAll,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < statuses.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          LifespanBar(
            label: lifespanCategoryLabel(statuses[i].category),
            progress: statuses[i].progress,
          ),
        ],
      ],
    ),
  );
}

/// Resumen de gasolina en el dashboard: rendimiento promedio y gasto del
/// mes. El detalle (curva, historial, demás KPIs) está en el tab Gasolina,
/// al que lleva [onViewAll].
class FuelSummaryCard extends StatelessWidget {
  const FuelSummaryCard({
    required this.metrics,
    required this.now,
    required this.onViewAll,
    super.key,
  });

  final FuelMetrics metrics;
  final DateTime now;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    double? average = metrics.averageKmPerGallon;
    int monthFills = metrics.currentMonthFillCount;
    String month = monthsInSpanish[now.month - 1].toLowerCase();
    return DashboardSectionCard(
      title: 'GASOLINA',
      icon: Icons.local_gas_station_outlined,
      actionLabel: 'VER GASOLINA',
      onAction: onViewAll,
      // IntrinsicHeight + stretch: las dos cards quedan del mismo alto
      // aunque un subtítulo ocupe dos líneas (igual que KpiCardsRow).
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: KpiCard(
                icon: Icons.speed,
                label: 'Rendimiento prom.',
                value: average == null ? '—' : average.toStringAsFixed(1),
                unit: average == null ? null : 'km/gal',
                subtitle: average == null ? 'Faltan tanqueos llenos' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                icon: Icons.calendar_month_outlined,
                label: 'Gasto en $month',
                value: copFormat.format(metrics.currentMonthSpent),
                subtitle: switch (monthFills) {
                  0 => 'Sin tanqueos este mes',
                  1 => '1 tanqueo',
                  _ => '$monthFills tanqueos',
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
