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
  });

  final List<FuelMetricsPoint> curve;
  final double? averageKmPerGallon;
  final double? costPerKm;
  final double totalSpent;

  static const FuelMetrics empty = FuelMetrics(
    curve: <FuelMetricsPoint>[],
    averageKmPerGallon: null,
    costPerKm: null,
    totalSpent: 0,
  );
}

/// Km/Gal solo entre pares consecutivos de tanqueos "tanque lleno" (design_spec:
/// "Performance curve (Km/Gal)" con historial marcado por Full Tank badges).
/// Costo/Km usa todo el historial (incluye tanqueos parciales).
FuelMetrics calculateFuelMetrics(List<FuelLog> logsAscendingByDate) {
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

  double? averageKmPerGallon = curve.isEmpty
      ? null
      : curve.fold<double>(
              0,
              (double sum, FuelMetricsPoint p) => sum + p.kmPerGallon,
            ) /
            curve.length;

  return FuelMetrics(
    curve: curve,
    averageKmPerGallon: averageKmPerGallon,
    costPerKm: costPerKm,
    totalSpent: totalSpent,
  );
}
