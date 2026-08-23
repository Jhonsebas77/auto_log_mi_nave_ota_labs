part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `fuel_logs` table in claude/tech_spec.md.
class FuelLog {
  const FuelLog({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometer,
    required this.gallons,
    required this.totalCost,
    this.pricePerGallon,
    this.isFullTank = true,
    this.stationName,
  });
  final String id;
  final String vehicleId;
  final DateTime date;
  final int odometer;
  final double gallons;
  final double? pricePerGallon;
  final double totalCost;
  final bool isFullTank;
  final String? stationName;

  FuelLog copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    int? odometer,
    double? gallons,
    double? pricePerGallon,
    double? totalCost,
    bool? isFullTank,
    String? stationName,
  }) => FuelLog(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    date: date ?? this.date,
    odometer: odometer ?? this.odometer,
    gallons: gallons ?? this.gallons,
    pricePerGallon: pricePerGallon ?? this.pricePerGallon,
    totalCost: totalCost ?? this.totalCost,
    isFullTank: isFullTank ?? this.isFullTank,
    stationName: stationName ?? this.stationName,
  );
}
