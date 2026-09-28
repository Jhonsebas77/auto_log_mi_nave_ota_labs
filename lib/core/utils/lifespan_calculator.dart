part of com.auto_log_mi_nave_ota_labs.app.core.utils;

class LifespanStatus {
  const LifespanStatus({
    required this.category,
    required this.progress,
    required this.lastServiceOdometer,
  });
  final MaintenanceLifespanCategory category;
  final double progress;
  final int lastServiceOdometer;
}

MaintenanceLifespanCategory? _categoryForRecord(MaintenanceRecord record) {
  String categoryLower = record.category.toLowerCase();
  for (MapEntry<MaintenanceLifespanCategory, List<String>> entry
      in kLifespanCategoryKeywords.entries) {
    for (String keyword in entry.value) {
      if (categoryLower.contains(keyword)) return entry.key;
    }
  }
  return null;
}

/// Calcula el progreso de vida útil (Aceite/Llantas/Frenos) del vehículo:
/// busca el registro más reciente que matchee cada categoría por palabra
/// clave y compara contra el Odómetro actual.
List<LifespanStatus> calculateLifespans({
  required List<MaintenanceRecord> records,
  required int currentOdometer,
}) {
  // Una sola pasada: la categoría de cada registro se resuelve una vez (y
  // no una vez por categoría), guardando el mayor odómetro de cada una.
  Map<MaintenanceLifespanCategory, int> lastOdometers =
      <MaintenanceLifespanCategory, int>{};
  for (MaintenanceRecord record in records) {
    MaintenanceLifespanCategory? category = _categoryForRecord(record);
    if (category == null) continue;
    if (record.odometer > (lastOdometers[category] ?? 0)) {
      lastOdometers[category] = record.odometer;
    }
  }

  return <LifespanStatus>[
    for (MaintenanceLifespanCategory category
        in MaintenanceLifespanCategory.values)
      _lifespanFor(category, lastOdometers[category] ?? 0, currentOdometer),
  ];
}

LifespanStatus _lifespanFor(
  MaintenanceLifespanCategory category,
  int lastOdometer,
  int currentOdometer,
) {
  int interval = intervalKmFor(category);
  double progress = interval == 0
      ? 0.0
      : (currentOdometer - lastOdometer) / interval;
  return LifespanStatus(
    category: category,
    progress: progress,
    lastServiceOdometer: lastOdometer,
  );
}
