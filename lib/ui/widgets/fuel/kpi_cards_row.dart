part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Grilla 2×2 de KPIs debajo de la curva de rendimiento: arriba el gasto
/// (mes y total), abajo la eficiencia (costo por km y autonomía). El
/// rendimiento promedio no va acá: ya lo muestra la gráfica (línea y leyenda
/// "Prom.").
class KpiCardsRow extends StatelessWidget {
  const KpiCardsRow({required this.metrics, super.key});

  final FuelMetrics metrics;

  static const double _gap = 12;

  static String _fills(int n) => n == 1 ? '1 tanqueo' : '$n tanqueos';

  String get _rangeSubtitle {
    if (metrics.estimatedRangeKm != null) return 'Con el tanque lleno';
    // Sin promedio aún no hay con qué estimar; con promedio, lo único que
    // falta es la capacidad del tanque del vehículo.
    return metrics.averageKmPerGallon == null
        ? 'Faltan tanqueos llenos'
        : 'Agrega la capacidad del tanque';
  }

  @override
  Widget build(BuildContext context) {
    String month = monthsInSpanish[DateTime.now().month - 1].toLowerCase();
    int monthFills = metrics.currentMonthFillCount;

    return Column(
      children: <Widget>[
        _row(
          KpiCard(
            icon: Icons.calendar_month_outlined,
            label: 'Gasto en $month',
            value: copFormat.format(metrics.currentMonthSpent),
            subtitle: monthFills == 0
                ? 'Sin tanqueos este mes'
                : _fills(monthFills),
          ),
          KpiCard(
            icon: Icons.payments_outlined,
            label: 'Total gastado',
            value: copFormat.format(metrics.totalSpent),
            subtitle: 'En ${_fills(metrics.fillCount)}',
          ),
        ),
        const SizedBox(height: _gap),
        _row(
          KpiCard(
            icon: Icons.route_outlined,
            label: 'Costo por km',
            value: metrics.costPerKm == null
                ? '—'
                : copFormat.format(metrics.costPerKm),
            subtitle: metrics.totalDistanceKm > 0
                ? 'En ${integerFormat.format(metrics.totalDistanceKm)} km '
                      'recorridos'
                : 'Registra otro tanqueo',
          ),
          KpiCard(
            icon: Icons.local_gas_station_outlined,
            label: 'Autonomía est.',
            value: metrics.estimatedRangeKm == null
                ? '—'
                : integerFormat.format(metrics.estimatedRangeKm!.round()),
            unit: metrics.estimatedRangeKm == null ? null : 'km',
            subtitle: _rangeSubtitle,
          ),
        ),
      ],
    );
  }

  /// IntrinsicHeight + stretch: las dos cards de la fila quedan del mismo
  /// alto aunque un subtítulo ocupe dos líneas.
  Widget _row(KpiCard left, KpiCard right) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: left),
        const SizedBox(width: _gap),
        Expanded(child: right),
      ],
    ),
  );
}
