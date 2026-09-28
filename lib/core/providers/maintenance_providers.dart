part of com.auto_log_mi_nave_ota_labs.app.core.providers;

// ignore: always_specify_types
final maintenanceRecordsProvider = FutureProvider.autoDispose
    .family<List<MaintenanceRecord>, String>(
      (Ref ref, String vehicleId) =>
          ref.watch(maintenanceRepositoryProvider).getByVehicle(vehicleId),
    );

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
