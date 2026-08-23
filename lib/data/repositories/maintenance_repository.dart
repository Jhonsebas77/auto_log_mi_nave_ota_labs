part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories;

abstract class MaintenanceRepository {
  Future<List<MaintenanceRecord>> getByVehicle(String vehicleId);
  Future<MaintenanceRecord> create(MaintenanceRecord record);
  Future<void> delete(String id);
}
