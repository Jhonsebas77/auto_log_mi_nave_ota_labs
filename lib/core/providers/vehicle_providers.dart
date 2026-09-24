part of com.auto_log_mi_nave_ota_labs.app.core.providers;

class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    String? userId = ref.watch(authControllerProvider).user?.id;
    if (userId == null) return const <Vehicle>[];
    return ref.read(vehicleRepositoryProvider).getByUser(userId);
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await ref.read(vehicleRepositoryProvider).create(vehicle);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await ref.read(vehicleRepositoryProvider).update(vehicle);
    ref.invalidateSelf();
    await future;
  }

  Future<void> bumpOdometer(String vehicleId, int odometer) async {
    await ref
        .read(vehicleRepositoryProvider)
        .bumpOdometerIfHigher(vehicleId, odometer);
    ref.invalidateSelf();
    await future;
  }
}

final AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>> vehiclesProvider =
    AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
      VehiclesNotifier.new,
    );

/// Vehículo del usuario. La app solo soporta un vehículo por usuario, así
/// que este es siempre el primero (y único) devuelto por [vehiclesProvider].
final Provider<Vehicle?> selectedVehicleProvider = Provider<Vehicle?>((
  Ref ref,
) {
  List<Vehicle> vehicles =
      ref.watch(vehiclesProvider).value ?? const <Vehicle>[];
  return vehicles.isEmpty ? null : vehicles.first;
});
