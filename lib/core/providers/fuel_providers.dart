part of com.auto_log_mi_nave_ota_labs.app.core.providers;

// ignore: always_specify_types
final fuelLogsProvider = FutureProvider.autoDispose
    .family<List<FuelLog>, String>(
      (Ref ref, String vehicleId) =>
          ref.watch(fuelLogRepositoryProvider).getByVehicle(vehicleId),
    );

// ignore: always_specify_types
final fuelMetricsProvider = Provider.autoDispose.family<FuelMetrics, String>((
  Ref ref,
  String vehicleId,
) {
  List<FuelLog> logs =
      ref.watch(fuelLogsProvider(vehicleId)).value ?? const <FuelLog>[];
  // Solo la capacidad del tanque: un cambio de odómetro (u otro campo) del
  // vehículo no debe recalcular las métricas.
  double? tankCapacityGallons = ref.watch(
    selectedVehicleProvider.select(
      (Vehicle? v) => v?.id == vehicleId ? v?.tankCapacityGallons : null,
    ),
  );
  return calculateFuelMetrics(logs, tankCapacityGallons: tankCapacityGallons);
});

class FuelLogActions {
  FuelLogActions(this._ref);
  final Ref _ref;

  /// El odómetro se sube vía `VehiclesNotifier.bumpOdometer`, que parchea
  /// el estado local con la fila devuelta en vez de volver a pedir todos
  /// los vehículos; solo el historial de tanqueos se vuelve a pedir (el
  /// orden ascendente por fecha lo garantiza el servidor).
  Future<void> create(FuelLog log) async {
    await _ref.read(fuelLogRepositoryProvider).create(log);
    await _ref
        .read(vehiclesProvider.notifier)
        .bumpOdometer(log.vehicleId, log.odometer);
    _ref.invalidate(fuelLogsProvider(log.vehicleId));
  }

  /// A propósito NO revierte `vehicle.currentOdometer` aunque se borre el
  /// tanqueo más reciente — reconstruir cuál era el odómetro "correcto"
  /// antes de ese tanqueo requeriría inspeccionar el resto del historial,
  /// y no es parte de este flujo.
  Future<void> delete(FuelLog log) async {
    await _ref.read(fuelLogRepositoryProvider).delete(log.id);
    _ref.invalidate(fuelLogsProvider(log.vehicleId));
  }
}

final Provider<FuelLogActions> fuelLogActionsProvider =
    Provider<FuelLogActions>(FuelLogActions.new);
