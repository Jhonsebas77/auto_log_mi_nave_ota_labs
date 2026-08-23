part of com.auto_log_mi_nave_ota_labs.app.core.models;

/// Mirrors the `maintenances` table in claude/tech_spec.md.
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
}
