part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `fuel_logs` table in Supabase (ver
/// `supabase/sql/0003_fuel_logs.sql`, que sigue el schema de
/// claude/tech_spec.md sin cambios — a diferencia de `Vehicle`, acá no se
/// agregaron columnas de auditoría porque nada en la UI las necesita hoy).
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
    this.isExtraFuel = false,
    this.stationName,
  });

  /// Arma un [FuelLog] a partir de una fila de la tabla `fuel_logs` de
  /// Supabase (columnas `snake_case`). Ver `supabase/sql/0003_fuel_logs.sql`.
  factory FuelLog.fromJson(Map<String, dynamic> json) => FuelLog(
    id: json['id'] as String,
    vehicleId: json['vehicle_id'] as String,
    date: DateTime.parse(json['date'] as String),
    odometer: json['odometer'] as int,
    gallons: (json['gallons'] as num).toDouble(),
    pricePerGallon: (json['price_per_gallon'] as num?)?.toDouble(),
    totalCost: (json['total_cost'] as num).toDouble(),
    isFullTank: json['is_full_tank'] as bool,
    // Nullable-safe: filas creadas antes de la migración que agrega esta
    // columna (0005_fuel_logs_extra_fuel.sql) no la tienen poblada.
    isExtraFuel: json['is_extra_fuel'] as bool? ?? false,
    stationName: json['station_name'] as String?,
  );
  final String id;
  final String vehicleId;
  final DateTime date;
  final int odometer;
  final double gallons;
  final double? pricePerGallon;
  final double totalCost;
  final bool isFullTank;

  /// Indica si este tanqueo se hizo con gasolina extra/premium. No confundir
  /// con `Vehicle.fuelType == FuelType.gasolinaExtra` (ver
  /// `lib/core/enums/enums.dart`), que describe el combustible habitual del
  /// vehículo, no de un tanqueo puntual.
  final bool isExtraFuel;
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
    bool? isExtraFuel,
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
    isExtraFuel: isExtraFuel ?? this.isExtraFuel,
    stationName: stationName ?? this.stationName,
  );

  /// Representación completa de la fila (columnas `snake_case`). A
  /// diferencia de `Vehicle.toJson`, no hay ninguna columna controlada por
  /// la DB que haya que quitar antes de un `insert` — no hay
  /// `_writablePayload` en `SupabaseFuelLogRepository`.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'vehicle_id': vehicleId,
    'date': date.toIso8601String(),
    'odometer': odometer,
    'gallons': gallons,
    'price_per_gallon': pricePerGallon,
    'total_cost': totalCost,
    'is_full_tank': isFullTank,
    'is_extra_fuel': isExtraFuel,
    'station_name': stationName,
  };
}
