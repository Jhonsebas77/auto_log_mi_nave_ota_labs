part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `maintenances` table in Supabase (ver
/// `supabase/sql/0008_maintenances.sql`), que sigue el schema de
/// claude/tech_spec.md sin cambios — igual que `FuelLog`, acá no hay
/// columnas de auditoría porque nada en la UI las necesita hoy.
///
/// Named `MaintenanceRecord` (not `Maintenance`) to avoid a naming clash with
/// the `MaintenanceServiceType` enum's common usages/imports across features.
class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.category,
    required this.date,
    required this.odometer,
    required this.totalCost,
    this.workshopName,
    this.invoiceUrl,
    this.notes,
  });

  /// Arma un [MaintenanceRecord] a partir de una fila de la tabla
  /// `maintenances` de Supabase (columnas `snake_case`). Ver
  /// `supabase/sql/0008_maintenances.sql`.
  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) =>
      MaintenanceRecord(
        id: json['id'] as String,
        vehicleId: json['vehicle_id'] as String,
        serviceType: MaintenanceServiceTypeSql.fromSqlValue(
          json['service_type'] as String,
        ),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        odometer: json['odometer'] as int,
        totalCost: (json['total_cost'] as num).toDouble(),
        workshopName: json['workshop_name'] as String?,
        invoiceUrl: json['invoice_url'] as String?,
        notes: json['notes'] as String?,
      );
  final String id;
  final String vehicleId;
  final MaintenanceServiceType serviceType;
  final String category;
  final DateTime date;
  final int odometer;
  final double totalCost;
  final String? workshopName;
  final String? invoiceUrl;
  final String? notes;

  MaintenanceRecord copyWith({
    String? id,
    String? vehicleId,
    MaintenanceServiceType? serviceType,
    String? category,
    DateTime? date,
    int? odometer,
    double? totalCost,
    String? workshopName,
    String? invoiceUrl,
    String? notes,
  }) => MaintenanceRecord(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    serviceType: serviceType ?? this.serviceType,
    category: category ?? this.category,
    date: date ?? this.date,
    odometer: odometer ?? this.odometer,
    totalCost: totalCost ?? this.totalCost,
    workshopName: workshopName ?? this.workshopName,
    invoiceUrl: invoiceUrl ?? this.invoiceUrl,
    notes: notes ?? this.notes,
  );

  /// Representación completa de la fila (columnas `snake_case`). Igual que
  /// `FuelLog.toJson`, no hay ninguna columna controlada por la DB que haya
  /// que quitar antes de un `insert` — el `id` que se manda es el UUID
  /// generado en el cliente por `generateId()` (ver
  /// `register_maintenance_screen.dart`), no uno vacío que dependa del
  /// `DEFAULT gen_random_uuid()` de la tabla.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'vehicle_id': vehicleId,
    'service_type': serviceType.sqlValue,
    'category': category,
    'date': date.toIso8601String(),
    'odometer': odometer,
    'total_cost': totalCost,
    'workshop_name': workshopName,
    'invoice_url': invoiceUrl,
    'notes': notes,
  };

  /// Igualdad por valor (ver el comentario equivalente en `Vehicle`).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceRecord &&
          id == other.id &&
          vehicleId == other.vehicleId &&
          serviceType == other.serviceType &&
          category == other.category &&
          date == other.date &&
          odometer == other.odometer &&
          totalCost == other.totalCost &&
          workshopName == other.workshopName &&
          invoiceUrl == other.invoiceUrl &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    serviceType,
    category,
    date,
    odometer,
    totalCost,
    workshopName,
    invoiceUrl,
    notes,
  );
}
