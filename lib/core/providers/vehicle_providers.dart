part of com.auto_log_mi_nave_ota_labs.app.core.providers;

const Logger _vehiclesLog = Logger('VehiclesNotifier');

class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    String? userId = ref.watch(authControllerProvider).user?.id;
    if (userId == null) return const <Vehicle>[];
    try {
      return await ref.read(vehicleRepositoryProvider).getByUser(userId);
    } catch (e) {
      _vehiclesLog.error('getByUser($userId): $e');
      rethrow;
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    Vehicle created = await ref.read(vehicleRepositoryProvider).create(vehicle);
    await _upsert(created);
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    Vehicle updated = await ref.read(vehicleRepositoryProvider).update(vehicle);
    await _upsert(updated);
  }

  Future<void> bumpOdometer(String vehicleId, int odometer) async {
    Vehicle updated = await ref
        .read(vehicleRepositoryProvider)
        .bumpOdometerIfHigher(vehicleId, odometer);
    await _upsert(updated);
  }

  /// Los repositorios ya devuelven la fila guardada (`insert/update
  /// ...select()`), así que se parchea el estado local con ella en vez de
  /// invalidar y volver a pedir la lista completa a Supabase. Gracias al
  /// `==` de [Vehicle], si la fila no cambió (ej. un odómetro menor al
  /// actual) nadie se reconstruye.
  Future<void> _upsert(Vehicle vehicle) async {
    List<Vehicle> current = await future;
    int index = current.indexWhere((Vehicle v) => v.id == vehicle.id);
    List<Vehicle> next = <Vehicle>[...current];
    if (index == -1) {
      next.add(vehicle);
    } else {
      if (current[index] == vehicle) return;
      next[index] = vehicle;
    }
    state = AsyncData<List<Vehicle>>(next);
  }
}

final AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>> vehiclesProvider =
    AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
      VehiclesNotifier.new,
    );

/// Vehículo del usuario. La app solo soporta un vehículo por usuario, así
/// que este es siempre el primero (y único) devuelto por [vehiclesProvider].
///
/// Los consumidores que solo necesitan un campo deberían usar
/// `ref.watch(selectedVehicleProvider.select((Vehicle? v) => v?.campo))`
/// para no reconstruirse cuando cambia otro campo del vehículo.
final Provider<Vehicle?> selectedVehicleProvider = Provider<Vehicle?>((
  Ref ref,
) {
  List<Vehicle> vehicles =
      ref.watch(vehiclesProvider).value ?? const <Vehicle>[];
  return vehicles.isEmpty ? null : vehicles.first;
});
