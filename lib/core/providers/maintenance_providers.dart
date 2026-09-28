part of com.auto_log_mi_nave_ota_labs.app.core.providers;

const Logger _maintenanceLog = Logger('MaintenanceProviders');

/// Sin reintentos automáticos (Riverpod 3 reintenta por defecto con
/// backoff): mientras la tabla `maintenances` no esté disponible en
/// Supabase, cada reintento fallaría igual. El tab de Taller muestra un
/// estado de "no disponible" con un botón para reintentar a mano.
// ignore: always_specify_types
final maintenanceRecordsProvider = FutureProvider.autoDispose
    .family<List<MaintenanceRecord>, String>((Ref ref, String vehicleId) async {
      try {
        return await ref
            .watch(maintenanceRepositoryProvider)
            .getByVehicle(vehicleId);
      } catch (e) {
        _maintenanceLog.error('maintenanceRecordsProvider($vehicleId): $e');
        rethrow;
      }
    }, retry: (int retryCount, Object error) => null);

/// Si se puede registrar mantenimiento para el vehículo actual: solo
/// `true` cuando [maintenanceRecordsProvider] respondió con datos. Mientras
/// carga, o si falla (hoy, porque el módulo aún no está habilitado en
/// Supabase), es `false`, y las entradas al formulario (botón + de Taller y
/// la acción rápida) se ocultan — guardar fallaría igual.
final Provider<bool> maintenanceAvailableProvider = Provider.autoDispose<bool>((
  Ref ref,
) {
  String? vehicleId = ref.watch(
    selectedVehicleProvider.select((Vehicle? v) => v?.id),
  );
  if (vehicleId == null) return false;
  return ref.watch(maintenanceRecordsProvider(vehicleId)).hasValue;
});

// ignore: always_specify_types
final lifespanProvider = Provider.autoDispose
    .family<List<LifespanStatus>, String>((Ref ref, String vehicleId) {
      List<MaintenanceRecord> records =
          ref.watch(maintenanceRecordsProvider(vehicleId)).value ??
          const <MaintenanceRecord>[];
      // Solo el odómetro de este vehículo: otros cambios del vehículo (foto,
      // apodo, etc.) no deben recalcular la vida útil.
      int odometer = ref.watch(
        vehiclesProvider.select((AsyncValue<List<Vehicle>> vehicles) {
          for (Vehicle v in vehicles.value ?? const <Vehicle>[]) {
            if (v.id == vehicleId) return v.currentOdometer;
          }
          return 0;
        }),
      );
      return calculateLifespans(records: records, currentOdometer: odometer);
    });

class MaintenanceActions {
  MaintenanceActions(this._ref);
  final Ref _ref;

  Future<void> create(MaintenanceRecord record) async {
    await _ref.read(maintenanceRepositoryProvider).create(record);
    _ref.invalidate(maintenanceRecordsProvider(record.vehicleId));
  }
}

final Provider<MaintenanceActions> maintenanceActionsProvider =
    Provider<MaintenanceActions>(MaintenanceActions.new);
