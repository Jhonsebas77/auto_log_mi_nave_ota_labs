part of com.auto_log_mi_nave_ota_labs.app.core.providers;

final FutureProviderFamily<List<MaintenanceRecord>, String>
maintenanceRecordsProvider =
    FutureProvider.family<List<MaintenanceRecord>, String>(
      (Ref ref, String vehicleId) =>
          ref.watch(maintenanceRepositoryProvider).getByVehicle(vehicleId),
    );

// ignore: always_specify_types
final lifespanProvider = Provider.family<List<LifespanStatus>, String>((
  Ref ref,
  String vehicleId,
) {
  List<MaintenanceRecord> records =
      ref.watch(maintenanceRecordsProvider(vehicleId)).value ??
      const <MaintenanceRecord>[];
  List<Vehicle> vehicles =
      ref.watch(vehiclesProvider).value ?? const <Vehicle>[];
  int odometer = 0;
  for (Vehicle v in vehicles) {
    if (v.id == vehicleId) {
      odometer = v.currentOdometer;
      break;
    }
  }
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
