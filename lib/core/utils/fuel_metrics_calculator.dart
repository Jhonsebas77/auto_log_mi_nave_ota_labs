part of com.auto_log_mi_nave_ota_labs.app.core.utils;

class FuelMetricsPoint {
  const FuelMetricsPoint({required this.date, required this.kmPerGallon});
  final DateTime date;
  final double kmPerGallon;
}

class FuelMetrics {
  const FuelMetrics({
    required this.curve,
    required this.averageKmPerGallon,
    required this.costPerKm,
    required this.totalSpent,
    required this.currentMonthSpent,
    this.estimatedRangeKm,
  });

  final List<FuelMetricsPoint> curve;
  final double? averageKmPerGallon;
  final double? costPerKm;
  final double totalSpent;

  /// Suma de `totalCost` de los tanqueos del mes calendario actual (según
  /// el [DateTime] de referencia usado en `calculateFuelMetrics` — por
  /// defecto `DateTime.now()`). Cero si no hay tanqueos ese mes.
  final double currentMonthSpent;

  /// Autonomía estimada con tanque lleno: `tankCapacityGallons *
  /// averageKmPerGallon`. Nulo si el vehículo no tiene capacidad de tanque
  /// registrada o si aún no hay [averageKmPerGallon] calculado.
  final double? estimatedRangeKm;

  static const FuelMetrics empty = FuelMetrics(
    curve: <FuelMetricsPoint>[],
    averageKmPerGallon: null,
    costPerKm: null,
    totalSpent: 0,
    currentMonthSpent: 0,
  );
}

/// Km/Gal solo entre pares consecutivos de tanqueos "tanque lleno" (design_spec:
/// "Performance curve (Km/Gal)" con historial marcado por Full Tank badges).
/// Costo/Km usa todo el historial (incluye tanqueos parciales).
///
/// [tankCapacityGallons] (opcional, del vehículo) se usa solo para derivar
/// [FuelMetrics.estimatedRangeKm] — no afecta el resto de los cálculos.
///
/// [now] es el punto de referencia para "mes actual" en
/// [FuelMetrics.currentMonthSpent] — parámetro inyectable para que los
/// tests no dependan del reloj real; por defecto `DateTime.now()`.
FuelMetrics calculateFuelMetrics(
  List<FuelLog> logsAscendingByDate, {
  double? tankCapacityGallons,
  DateTime? now,
}) {
  if (logsAscendingByDate.isEmpty) return FuelMetrics.empty;

  List<FuelMetricsPoint> curve = <FuelMetricsPoint>[];
  FuelLog? lastFullTank;
  for (FuelLog log in logsAscendingByDate) {
    if (log.isFullTank) {
      if (lastFullTank != null) {
        int distance = log.odometer - lastFullTank.odometer;
        if (distance > 0 && log.gallons > 0) {
          curve.add(
            FuelMetricsPoint(
              date: log.date,
              kmPerGallon: distance / log.gallons,
            ),
          );
        }
      }
      lastFullTank = log;
    }
  }

  int totalDistance =
      logsAscendingByDate.last.odometer - logsAscendingByDate.first.odometer;
  double totalSpent = logsAscendingByDate.fold<double>(
    0,
    (double sum, FuelLog log) => sum + log.totalCost,
  );
  double? costPerKm = totalDistance > 0 ? totalSpent / totalDistance : null;

  DateTime today = now ?? DateTime.now();
  double currentMonthSpent = logsAscendingByDate
      .where(
        (FuelLog log) =>
            log.date.year == today.year && log.date.month == today.month,
      )
      .fold<double>(0, (double sum, FuelLog log) => sum + log.totalCost);

  double? averageKmPerGallon = curve.isEmpty
      ? null
      : curve.fold<double>(
              0,
              (double sum, FuelMetricsPoint p) => sum + p.kmPerGallon,
            ) /
            curve.length;

  double? estimatedRangeKm =
      (averageKmPerGallon == null || tankCapacityGallons == null)
      ? null
      : averageKmPerGallon * tankCapacityGallons;

  return FuelMetrics(
    curve: curve,
    averageKmPerGallon: averageKmPerGallon,
    costPerKm: costPerKm,
    totalSpent: totalSpent,
    currentMonthSpent: currentMonthSpent,
    estimatedRangeKm: estimatedRangeKm,
  );
}
