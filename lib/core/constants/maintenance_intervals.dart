part of com.auto_log_mi_nave_ota_labs.app.core.constants;

/// Intervalos por defecto (en km) para las barras de vida útil de
/// Mantenimientos y Taller. Ajustables — no provienen del design_spec/tech_spec,
/// son valores de referencia razonables para un vehículo particular.
const int kOilChangeIntervalKm = 5000;
const int kTireRotationIntervalKm = 40000;
const int kBrakePadIntervalKm = 30000;

/// Palabras clave usadas para ubicar el `category` (VARCHAR libre en el
/// schema) de un `MaintenanceRecord` dentro de uno de los tres buckets de
/// vida útil que muestra el Dashboard/Taller.
const Map<MaintenanceLifespanCategory, List<String>> kLifespanCategoryKeywords =
    <MaintenanceLifespanCategory, List<String>>{
      MaintenanceLifespanCategory.oil: <String>['aceite', 'oil'],
      MaintenanceLifespanCategory.tires: <String>[
        'llanta',
        'neumático',
        'neumatico',
        'rotación',
        'rotacion',
      ],
      MaintenanceLifespanCategory.brakes: <String>['freno', 'pastilla'],
    };

int intervalKmFor(MaintenanceLifespanCategory category) {
  switch (category) {
    case MaintenanceLifespanCategory.oil:
      return kOilChangeIntervalKm;
    case MaintenanceLifespanCategory.tires:
      return kTireRotationIntervalKm;
    case MaintenanceLifespanCategory.brakes:
      return kBrakePadIntervalKm;
  }
}

String lifespanCategoryLabel(MaintenanceLifespanCategory category) {
  switch (category) {
    case MaintenanceLifespanCategory.oil:
      return 'Aceite';
    case MaintenanceLifespanCategory.tires:
      return 'Llantas';
    case MaintenanceLifespanCategory.brakes:
      return 'Frenos';
  }
}
