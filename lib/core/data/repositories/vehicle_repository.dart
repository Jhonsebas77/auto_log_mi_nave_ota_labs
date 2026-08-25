part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories;

abstract class VehicleRepository {
  Future<List<Vehicle>> getByUser(String userId);
  Future<Vehicle> create(Vehicle vehicle);
  Future<Vehicle> update(Vehicle vehicle);
  Future<void> delete(String id);

  /// Actualiza el odómetro solo si [odometer] es mayor al actual.
  Future<Vehicle> bumpOdometerIfHigher(String vehicleId, int odometer);
}
