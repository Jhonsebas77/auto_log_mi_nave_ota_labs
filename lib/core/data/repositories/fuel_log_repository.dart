part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories;

abstract class FuelLogRepository {
  Future<List<FuelLog>> getByVehicle(String vehicleId);
  Future<FuelLog> create(FuelLog log);
  Future<void> delete(String id);
}
