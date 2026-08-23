part of com.auto_log_mi_nave_ota_labs.app.core.providers;

// ignore: always_specify_types
final fuelLogsProvider = FutureProvider.family<List<FuelLog>, String>(
  (Ref ref, String vehicleId) =>
      ref.watch(fuelLogRepositoryProvider).getByVehicle(vehicleId),
);

// ignore: always_specify_types
final fuelMetricsProvider = Provider.family<FuelMetrics, String>((
  Ref ref,
  String vehicleId,
) {
  List<FuelLog> logs =
      ref.watch(fuelLogsProvider(vehicleId)).value ?? const <FuelLog>[];
  return calculateFuelMetrics(logs);
});

class FuelLogActions {
  FuelLogActions(this._ref);
  final Ref _ref;

  Future<void> create(FuelLog log) async {
    await _ref.read(fuelLogRepositoryProvider).create(log);
    await _ref
        .read(vehicleRepositoryProvider)
        .bumpOdometerIfHigher(log.vehicleId, log.odometer);
    _ref
      ..invalidate(fuelLogsProvider(log.vehicleId))
      ..invalidate(vehiclesProvider);
  }
}

final Provider<FuelLogActions> fuelLogActionsProvider =
    Provider<FuelLogActions>(FuelLogActions.new);
